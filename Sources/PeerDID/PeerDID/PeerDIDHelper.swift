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
        services: [DIDDocument.Service]
    ) throws -> PeerDID {
        
        let encodedAgreementsStrings = try agreementKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { "E\($0)" }
        
        let encodedAuthenticationsStrings = try authenticationKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { "V\($0)" }
        
        let encodedServiceStr = try PeerDIDHelper().encodePeerDIDServices(services: services)
        let methodId = (["2"] + encodedAgreementsStrings + encodedAuthenticationsStrings + [encodedServiceStr])
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
            return DIDDocument(id: "", verificationMethods: [], services: [])
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
        let (base, decodedMultibase) = try BaseEncoding.decode(ecnumbasis)
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
        
        let t: String // Type
        let s: String // Service Endpoint
        let r: [String]? // Routing keys
        let a: [String]? // Accept
        
        init(t: String, s: String, r: [String], a: [String]) {
            self.t = t
            self.s = s
            self.r = r
            self.a = a
        }
        
        init(from: DIDDocument.Service) throws {
            self.t = from.type
            self.s = try from.serviceEndpoint.getJsonString() ?? ""
            self.r = from.routingKeys
            self.a = from.accept
        }
        
        func toDIDDocumentService(did: String, index: Int) throws -> DIDDocument.Service {
            let serviceEndpoint: DIDDocument.Service.ServiceEndpoint
            if let s = try? parseServiceEndpoint(serviceEndpoint: s) {
                serviceEndpoint = s
            } else {
                serviceEndpoint = try parseServiceEndpoint(serviceEndpoint: "\"\(s)\"")
            }
            return .init(
                id: "\(did)#\(t.lowercased())-\(index+1)",
                type: t,
                serviceEndpoint: serviceEndpoint,
                routingKeys: r,
                accept: a
            )
        }
        
        private func parseServiceEndpoint(serviceEndpoint: String) throws -> DIDDocument.Service.ServiceEndpoint {
            guard let serviceData = serviceEndpoint.data(using: .utf8) else {
                throw PeerDIDError.somethingWentWrong
            }
            return try JSONDecoder().decode(DIDDocument.Service.ServiceEndpoint.self, from: serviceData)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: PeerDIDHelper.PeerDIDService.CodingKeys.self)
            try container.encode(self.s, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.s)
            try container.encode(self.r, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.r)
            try container.encodeIfPresent(self.a, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.a)
            try container.encodeIfPresent(self.t, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.t)
        }
        
        enum CodingKeys: CodingKey {
            case t
            case s
            case r
            case a
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<PeerDIDHelper.PeerDIDService.CodingKeys> = try decoder.container(keyedBy: PeerDIDHelper.PeerDIDService.CodingKeys.self)
            self.t = try container.decode(String.self, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.t)
            self.s = try container.decode(String.self, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.s)
            self.r = try container.decodeIfPresent([String].self, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.r)
            self.a = try container.decodeIfPresent([String].self, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.a)
        }
    }
    
    public func encodePeerDIDServices(services: [DIDDocument.Service]) throws -> String? {
        guard !services.isEmpty else { return nil }
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let parsingStr: String
        
        if services.count > 1 {
            let peerDidServices = try services.map { try PeerDIDService(from: $0) }
            guard let jsonStr = String(data: try encoder.encode(peerDidServices), encoding: .utf8) else {
                throw PeerDIDError.somethingWentWrong
            }
            parsingStr = jsonStr
        } else if let service = services.first {
            let peerDIDService = try PeerDIDService(from: service)
            guard let jsonStr = String(data: try encoder.encode(peerDIDService), encoding: .utf8) else {
                throw PeerDIDError.somethingWentWrong
            }
            parsingStr = jsonStr
        } else {
            throw PeerDIDError.somethingWentWrong // This should never happen since we handle all the cases
        }
        
        let parsedService = parsingStr
            .replacingOccurrences(of: "[\n\t\\s]*", with: "", options: .regularExpression)
            .replacingOccurrences(of: "DIDCommMessaging", with: "dm")
        
        guard let encodedService = parsedService.data(using: .utf8)?.base64URLEncoded(padded: false) else {
            throw PeerDIDError.somethingWentWrong
        }
        
        return "S\(encodedService)"
    }
    
    public func decodedPeerDIDService(did: String, serviceString: String) throws -> [DIDDocument.Service] {
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
                PeerDIDService.self,
                from: peerDIDServiceData
            )
        {
            return [try service.toDIDDocumentService(did: did, index: 0)]
        } else {
            let services = try decoder.decode(
                [PeerDIDService].self,
                from: peerDIDServiceData
            )
            
            return try Dictionary(grouping: services, by: \.t)
                .mapValues { try $0.enumerated().map { try $0.element.toDIDDocumentService(did: did, index: $0.offset) } }
                .flatMap { $0.value }
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
extension DIDDocument.Service.ServiceEndpoint {
    
    func getJsonString() throws -> String? {
        let encoder = JSONEncoder.peerDIDEncoder()
        return String(data: try encoder.encode(self), encoding: .utf8)
    }
}
