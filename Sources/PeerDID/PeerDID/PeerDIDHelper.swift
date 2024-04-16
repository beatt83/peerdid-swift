//
//  PeerDID.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import BaseX
import DIDCore
import Foundation
import Multibase

public struct PeerDIDHelper {
    
    public static func createAlgo0(key: PeerDIDVerificationMaterial) throws -> PeerDID {
        let keyEcnumbasis = try PeerDIDHelper().createMultibaseEncnumbasis(material: key)
        return PeerDID(
            algo: ._0,
            methodId: "0\(keyEcnumbasis)"
        )
    }
    
    public static func createAlgo2(
        authenticationKeys: [PeerDIDVerificationMaterial],
        agreementKeys: [PeerDIDVerificationMaterial],
        services: [AnyCodable]
    ) throws -> PeerDID {
        
        let encodedAgreementsStrings = try agreementKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { "E\($0)" }
        
        let encodedAuthenticationsStrings = try authenticationKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { "V\($0)" }
        
        let encodedServiceStrs = try services.map { try PeerDIDHelper().encodePeerDIDServices(service: $0) }
        let methodId = (["2"] + encodedAgreementsStrings + encodedAuthenticationsStrings + encodedServiceStrs)
            .compactMap { $0 }
            .joined(separator: ".")
        
        return PeerDID(
            algo: ._2,
            methodId: methodId
        )
    }
    
    public static func resolve(peerDIDStr: String, format: VerificationMaterialFormat = .multibase) throws -> DIDDocument {
        guard !peerDIDStr.isEmpty else { throw PeerDIDError.invalidPeerDIDString }
        let peerDID = try PeerDID(didString: peerDIDStr)
        switch peerDID.algo {
        case ._0:
            return try PeerDIDHelper().resolvePeerDIDAlgo0(peerDID: peerDID, format: format)
        case ._2:
            return try PeerDIDHelper().resolvePeerDIDAlgo2(peerDID: peerDID, format: format)
        }
    }
}

// MARK: Ecnumbasis
public extension PeerDIDHelper {
    func createMultibaseEncnumbasis(material: PeerDIDVerificationMaterial) throws -> String {
        let encodedCodec = Multicodec().toMulticodec(
            value: try material.decodedKey(),
            keyType: material.type
        )
        let encodedMultibase = BaseEncoding.base58btc.encode(data: encodedCodec)
        return encodedMultibase
    }

    func decodeMultibaseEcnumbasis(
        ecnumbasis: String,
        format: VerificationMaterialFormat
    ) throws -> PeerDIDVerificationMaterial {
        let (_, decodedMultibase) = try BaseEncoding.decode(ecnumbasis)
        let (codec, decodedMulticodec) = try Multicodec().fromMulticodec(value: decodedMultibase)
        
        try decodedMulticodec.validateKeyLength()
        
        let material: PeerDIDVerificationMaterial
        
        switch (format, codec) {
        case (.jwk, .X25519):
            let type = KnownVerificationMaterialType.agreement(.jsonWebKey2020)
            material = try .init(
                format: format,
                key: decodedMulticodec,
                type: type
            )
        case (.jwk, .ED25519):
            let type = KnownVerificationMaterialType.authentication(.jsonWebKey2020)
            material = try .init(
                format: format,
                key: decodedMulticodec,
                type: type
            )
        case (.base58, .X25519):
            material = try .init(
                format: format,
                key: decodedMulticodec,
                type: .agreement(.x25519KeyAgreementKey2019)
            )
        case (.base58, .ED25519):
            material = try .init(
                format: format,
                key: decodedMulticodec,
                type: .authentication(.ed25519VerificationKey2018)
            )
        case (.multibase, .X25519):
            material = try .init(
                format: format,
                key: decodedMulticodec,
                type: .agreement(.x25519KeyAgreementKey2020)
            )
        case (.multibase, .ED25519):
            material = try .init(
                format: format,
                key: decodedMulticodec,
                type: .authentication(.ed25519VerificationKey2020)
            )
        }
        
        return material
    }
}

// MARK: Service encoding/decoding

extension PeerDIDHelper {
    
    func parseServiceToPeerDID(_ service: AnyCodable) throws -> AnyCodable {
        guard var value = service.value as? [String: Any] else {
            throw PeerDIDError.invalidPeerDIDService
        }
        
        if var serviceEndpoint = value["serviceEndpoint"] as? [String: Any] {
            replaceServiceDictionaryKey(dic: &serviceEndpoint, from: "accept", to: "a")
            replaceServiceDictionaryKey(dic: &serviceEndpoint, from: "routingKeys", to: "r")
            value["serviceEndpoint"] = serviceEndpoint
        }
        
        replaceServiceDictionaryKey(dic: &value, from: "type", to: "t")
        replaceServiceDictionaryKey(dic: &value, from: "serviceEndpoint", to: "s")
        replaceServiceDictionaryKey(dic: &value, from: "accept", to: "a")
        replaceServiceDictionaryKey(dic: &value, from: "routingKeys", to: "r")
        
        value.removeValue(forKey: "id")
        
        return AnyCodable(value)
    }
    
    func parsePeerDIDServiceToService(_ service: AnyCodable, did: String, index: Int) throws -> AnyCodable {
        guard var value = service.value as? [String: Any], let type = value["t"] as? String else {
            throw PeerDIDError.invalidPeerDIDService
        }
        
        replaceServiceDictionaryKey(dic: &value, from: "t", to: "type")
        replaceServiceDictionaryKey(dic: &value, from: "s", to: "serviceEndpoint")
        replaceServiceDictionaryKey(dic: &value, from: "a", to: "accept")
        replaceServiceDictionaryKey(dic: &value, from: "r", to: "routingKeys")
        
        if var serviceEndpoint = value["serviceEndpoint"] as? [String: Any] {
            replaceServiceDictionaryKey(dic: &serviceEndpoint, from: "a", to: "accept")
            replaceServiceDictionaryKey(dic: &serviceEndpoint, from: "r", to: "routingKeys")
            value["serviceEndpoint"] = serviceEndpoint
        }
        
        value["id"] = "\(did)#\(type.lowercased())-\(index+1)"
        return AnyCodable(value)
    }
    
    private func replaceServiceDictionaryKey(dic: inout [String: Any], from: String, to: String) {
        if let value = dic[from] {
            dic[to] = value
            dic.removeValue(forKey: from)
        }
    }
    
    public func encodePeerDIDServices(service: AnyCodable) throws -> String {
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let peerDIDService = try parseServiceToPeerDID(service)
        guard let jsonStr = String(data: try encoder.encode(peerDIDService), encoding: .utf8) else {
            throw PeerDIDError.somethingWentWrong
        }
        let parsingStr = jsonStr
        
        let parsedService = parsingStr
            .replacingOccurrences(of: "[\n\t\\s]*", with: "", options: .regularExpression)
            .replacingOccurrences(of: "DIDCommMessaging", with: "dm")
        
        guard let encodedService = parsedService.data(using: .utf8)?.base64URLEncoded(padded: false) else {
            throw PeerDIDError.somethingWentWrong
        }
        
        return "S\(encodedService)"
    }
    
    public func decodedPeerDIDService(did: String, serviceString: String, index: Int) throws -> AnyCodable {
        guard
            let serviceBase64Data = Data(base64URLEncoded: serviceString),
            let serviceStr = String(data: serviceBase64Data, encoding: .utf8)
        else {
            throw PeerDIDError.invalidPeerDIDService
        }
        
        let parsedService = serviceStr.replacingOccurrences(of: "\"dm\"", with: "\"DIDCommMessaging\"")
        guard
            let peerDIDServiceData = parsedService.data(using: .utf8)
        else {
            throw PeerDIDError.invalidPeerDIDService
        }
        let serviceObject = try JSONDecoder().decode(AnyCodable.self, from: peerDIDServiceData)
        return try parsePeerDIDServiceToService(serviceObject, did: did, index: index)
    }
}

private extension Data {
    func validateKeyLength() throws {
        guard count == 32 else {
            throw PeerDIDError.couldNotCreateEcnumbasis(derivedError: PeerDIDError.invalidKeySize)
        }
    }
}

extension DIDDocument.VerificationMethod {
    
    init(did: String, id: String, material: PeerDIDVerificationMaterial) throws {
        self.init(
            id: did + "#\(id)",
            controller: did,
            type: material.type.rawValue,
            material: .init(format: material.format, value: material.value)
        )
    }
}
