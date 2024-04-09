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
        services: [DIDDocument.Service],
        recipientKeys: [[String]]? = nil
    ) throws -> PeerDID {
        if recipientKeys != nil && recipientKeys!.count != services.count {
            throw PeerDIDError.invalidPeerDIDService
        }
        
        let encodedAgreementsStrings = try agreementKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { "E\($0)" }
        
        let encodedAuthenticationsStrings = try authenticationKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { "V\($0)" }
        
        let encodedServiceStrs = try services.enumerated().map { index, service in
            try PeerDIDHelper().encodePeerDIDServices(service: service, recipientKeys: recipientKeys?[index])
        }
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
    
    struct PeerDIDService: Codable {
        
        struct ServiceEndpoint: Codable {
            let uri: String
            let r: [String]? // Routing keys
            let a: [String]? // Accept
        }
        
        let t: String // Type
        let s: ServiceEndpoint // Service Endpoint
        
        init(from: DIDDocument.Service) throws {
            self.t = from.type
            guard
                let dic = from.serviceEndpoint.value as? [String: Any],
                let uri = dic["uri"] as? String
            else {
                throw PeerDIDError.invalidPeerDIDService
            }
            self.s = .init(
                uri: uri,
                r: dic["routingKeys"] as? [String],
                a: dic["accept"] as? [String]
            )
        }
        
        func toDIDDocumentService(did: String, index: Int) throws -> DIDDocument.Service {
            return .init(
                id: "\(did)#\(t.lowercased())-\(index+1)",
                type: t,
                serviceEndpoint: AnyCodable(
                    dictionaryLiteral: ("uri", s.uri), ("accept", s.a ?? []), ("routingKeys", s.r ?? [])
                )
            )
        }
    }
    
    struct PeerDIDServiceLegacy: Codable {
        
        let t: String // Type
        let s: String // Service Endpoint
        let recipientKeys: [String]? // Recipient keys
        let r: [String]? // Routing keys
        let a: [String]? // Accept
        
        init(t: String, s: String, recipientKeys: [String]?, r: [String]?, a: [String]?) {
            self.t = t
            self.s = s
            self.recipientKeys = recipientKeys
            self.r = r
            self.a = a
        }
        
        init(from: DIDDocument.Service, recipientKeys: [String]) throws {
            self.t = from.type
            if recipientKeys.isEmpty {
                self.recipientKeys = nil
            } else {
                self.recipientKeys = recipientKeys
            }
            if 
                let uri = from.serviceEndpoint.value as? String
            {
                self.s = uri
                self.r = []
                self.a = []
            } else {
                guard
                    let dic = from.serviceEndpoint.value as? [String: Any],
                    let uri = dic["uri"] as? String
                else {
                    throw PeerDIDError.invalidPeerDIDService
                }
                self.s = uri
                self.r = dic["routingKeys"] as? [String]
                self.a = dic["accept"] as? [String]
            }
        }
        
        func toDIDDocumentService(did: String, index: Int) throws -> DIDDocument.Service {
            var serviceEndpoint: [String: Any] = ["uri": s]
            a.map { serviceEndpoint["accept"] = $0 }
            r.map { serviceEndpoint["routingKeys"] = $0 }
            
            return .init(
                id: "\(did)#\(t.lowercased())-\(index+1)",
                type: t,
                serviceEndpoint: AnyCodable(dictionaryLiteral: ("uri", s), ("accept", a ?? []), ("routingKeys", r ?? []))
            )
        }
    }
    
    public func encodePeerDIDServices(service: DIDDocument.Service, recipientKeys: [String]? = nil) throws -> String {
        let encoder = JSONEncoder.peerDIDEncoder()
        
        var parsingStr: String!
        if recipientKeys == nil {
            let peerDIDService = try PeerDIDService(from: service)
            guard let jsonStr = String(data: try encoder.encode(peerDIDService), encoding: .utf8) else {
                throw PeerDIDError.somethingWentWrong
            }
            parsingStr = jsonStr
        } else {
            let peerDIDService = try PeerDIDServiceLegacy(from: service, recipientKeys: recipientKeys!)
            guard let jsonStr = String(data: try encoder.encode(peerDIDService), encoding: .utf8) else {
                throw PeerDIDError.somethingWentWrong
            }
            parsingStr = jsonStr
        }
        
        let parsedService = parsingStr
            .replacingOccurrences(of: "[\n\t\\s]*", with: "", options: .regularExpression)
            .replacingOccurrences(of: "DIDCommMessaging", with: "dm")
        
        guard let encodedService = parsedService.data(using: .utf8)?.base64URLEncoded(padded: false) else {
            throw PeerDIDError.somethingWentWrong
        }
        
        return "S\(encodedService)"
    }
    
    public func decodedPeerDIDService(did: String, serviceString: String, index: Int) throws -> DIDDocument.Service {
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
        let decoder = JSONDecoder()
        if
            let service = try? decoder.decode(
                PeerDIDServiceLegacy.self,
                from: peerDIDServiceData
            )
        {
            return try service.toDIDDocumentService(did: did, index: index)
        } else {
            let service = try decoder.decode(
                PeerDIDService.self,
                from: peerDIDServiceData
            )
            return try service.toDIDDocumentService(did: did, index: index)
        }
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
extension DIDDocument.Service {
    
    func getJsonString() throws -> String? {
        let encoder = JSONEncoder.peerDIDEncoder()
        return String(data: try encoder.encode(self), encoding: .utf8)
    }
}
