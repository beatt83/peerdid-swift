//
//  PeerDID.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import BaseX
import Foundation
import Multibase

public struct PeerDIDHelper {
    
    public static func createAlgo0(key: VerificationMaterial) throws -> PeerDID {
        let keyEcnumbasis = try PeerDIDHelper().createMultibaseEncnumbasis(material: key)
        return PeerDID(
            algo: ._0,
            methodId: "0\(keyEcnumbasis)"
        )
    }
    
    public static func createAlgo2(
        authenticationKeys: [VerificationMaterial],
        agreementKeys: [VerificationMaterial],
        service: DIDDocument.Service?
    ) throws -> PeerDID {
        let encodedAgreementsStr = try agreementKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { ".E\($0)" }
            .joined()
        
        let encodedAuthenticationsStr = try authenticationKeys
            .map { try PeerDIDHelper().createMultibaseEncnumbasis(material: $0) }
            .map { ".V\($0)" }
            .joined()
        
        let encodedServiceStr = try service.map { try PeerDIDHelper().encodePeerDIDService(service: $0) } ?? ""
        
        return PeerDID(
            algo: ._2,
            methodId: "2\(encodedAgreementsStr)\(encodedAuthenticationsStr).\(encodedServiceStr)"
        )
    }
    
    public static func resolve(peerDIDStr: String, format: VerificationMaterialFormat = .multibase) throws -> DIDDocument {
        guard !peerDIDStr.isEmpty else { throw PeerDIDError.invalidPeerDIDString }
        let peerDID = try PeerDID(didString: peerDIDStr)
        switch peerDID.algo {
        case ._0:
            return try PeerDIDHelper().resolvePeerDIDAlgo0(peerDID: peerDID, format: format)
        case ._2:
            return DIDDocument(did: "", verificationMethods: [], services: [])
        }
    }
}

// MARK: Ecnumbasis
public extension PeerDIDHelper {
    func createMultibaseEncnumbasis(material: VerificationMaterial) throws -> String {
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
    ) throws -> (ecnumbasis: String, material: VerificationMaterial) {
        let (base, decodedMultibase) = try BaseEncoding.decode(ecnumbasis)
        let (codec, decodedMulticodec) = try Multicodec().fromMulticodec(value: decodedMultibase)
        
        try decodedMulticodec.validateKeyLength()
        
        let material: VerificationMaterial
        
        switch (format, codec) {
        case (.jwk, .X25519):
            let type = VerificationMaterialType.agreement(.jsonWebKey2020)
            material = try .init(
                format: format,
                key: decodedMulticodec,
                type: type
            )
        case (.jwk, .ED25519):
            let type = VerificationMaterialType.authentication(.jsonWebKey2020)
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
        
        return (base.charPrefix, material)
    }
}

// MARK: Service encoding/decoding

extension PeerDIDHelper {
    
    struct PeerDIDService: Codable {
        let t: String // Type
        let s: String // Service Endpoint
        let r: [String] // Routing keys
        let a: [String] // Accept
        
        init(t: String, s: String, r: [String], a: [String]) {
            self.t = t
            self.s = s
            self.r = r
            self.a = a
        }
        
        init(from: DIDDocument.Service) {
            self.t = from.type
            self.s = from.serviceEndpoint
            self.r = from.routingKeys
            self.a = from.accept
        }
        
        func toDIDDocumentService(did: String) -> DIDDocument.Service {
            .init(
                id: "\(did)#didcommmessaging-0",
                type: t,
                serviceEndpoint: s,
                routingKeys: r,
                accept: a
            )
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: PeerDIDHelper.PeerDIDService.CodingKeys.self)
            try container.encode(self.s, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.s)
            try container.encode(self.r, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.r)
            try container.encode(self.a, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.a)
            try container.encode(self.t, forKey: PeerDIDHelper.PeerDIDService.CodingKeys.t)
        }
    }
    
    public func encodePeerDIDService(service: DIDDocument.Service) throws -> String {
        let encoder = JSONEncoder.peerDIDEncoder()
        let peerDIDService = PeerDIDService(from: service)
        guard let jsonStr = String(data: try encoder.encode(peerDIDService), encoding: .utf8) else {
            throw PeerDIDError.somethingWentWrong
        }
        
        let parsedService = jsonStr
            .replacingOccurrences(of: "[\n\t\\s]*", with: "", options: .regularExpression)
            .replacingOccurrences(of: "DIDCommMessaging", with: "dm")
        
        guard let encodedService = parsedService.data(using: .utf8)?.base64URLEncoded(padded: false) else {
            throw PeerDIDError.somethingWentWrong
        }
        
        return "S\(encodedService)"
    }
    
    public func decodedPeerDIDService(did: String, serviceString: String) throws -> DIDDocument.Service {
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
        return try decoder.decode(
            PeerDIDService.self,
            from: peerDIDServiceData
        ).toDIDDocumentService(did: did)
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
    
    public init(did: String, ecnumbasis: String, material: VerificationMaterial) throws {
        self.id = did + "#\(ecnumbasis)"
        self.controller = did
        self.material = material
    }
}
