//
//  DIDDocument.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//
import BaseX
import Foundation

public struct DIDDocument {
    
    public struct VerificationMethod {
        public let id: String
        public let controller: String
        public let material: VerificationMaterial
    }
    
    public struct Service {
        public let id: String
        public let type: String
        public let serviceEndpoint: String
        public let routingKeys: [String]?
        public let accept: [String]?
    }
    
    public let did: String
    public let verificationMethods: [VerificationMethod]
    public let services: [Service]
    
    public var authentication: [VerificationMethod] {
        verificationMethods.filter { $0.material.type.isAuthentication }
    }
    
    public var keyAgreement: [VerificationMethod] {
        verificationMethods.filter { $0.material.type.isAgreement }
    }
}

extension DIDDocument: Codable {}
extension DIDDocument.Service: Codable {}

extension DIDDocument.VerificationMethod: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case controller
        case type
        case publicKeyBase58
        case publicKeyMultibase
        case publicKeyJwk
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        controller = try container.decode(String.self, forKey: .controller)
        let typ = try container.decode(String.self, forKey: .type)
        guard let materialType = VerificationMaterialType(rawValue: typ) else {
            throw DecodingError
                .dataCorrupted(.init(
                    codingPath: [CodingKeys.type],
                    debugDescription: "Unsupported material type: \(typ)"
                ))
        }
        if
            let base58 = try container.decodeIfPresent(String.self, forKey: .publicKeyBase58),
            let data = Data(base64URLEncoded: base58)
        {
            material = VerificationMaterial(
                format: .base58,
                value: data,
                type: materialType
            )
        } else if
            let jwk = try container.decodeIfPresent(String.self, forKey: .publicKeyJwk),
            let data = Data(base64URLEncoded: jwk)
        {
            material = VerificationMaterial(
                format: .jwk,
                value: data,
                type: materialType
            )
        } else if
            let multibase = try container.decodeIfPresent(String.self, forKey: .publicKeyMultibase),
            let data = Data(base64URLEncoded: multibase)
        {
            material = VerificationMaterial(
                format: .multibase,
                value: data,
                type: materialType
            )
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [
                    CodingKeys.publicKeyBase58,
                    CodingKeys.publicKeyJwk,
                    CodingKeys.publicKeyMultibase
                ], debugDescription: "A valid key type was not found"
            ))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(controller, forKey: .controller)
        try container.encode(material.type.rawValue, forKey: .type)
        
        switch material.format {
        case .base58:
            try container.encode(String(data: try material.convertToBase58().value, encoding: .utf8), forKey: .publicKeyBase58)
        case .jwk:
            try container.encode(try material.getJWKValue(), forKey: .publicKeyJwk)
        case .multibase:
            try container.encode(String(data: try material.convertToMultibase().value, encoding: .utf8), forKey: .publicKeyMultibase)
        }
    }
}

extension VerificationMaterialFormat {
    
    init(fromKey: String) throws {
        switch fromKey {
        case "publicKeyBase58":
            self = .base58
        case "publicKeyMultibase":
            self = .multibase
        case "publicKeyJwk":
            self = .jwk
        default:
            throw PeerDIDError.invalidMaterialType(fromKey)
        }
    }
    
    var keyString: String {
        switch self {
        case .base58: return "publicKeyBase58"
        case .jwk: return "publicKeyMultibase"
        case .multibase: return "publicKeyJwk"
        }
    }
}

private extension VerificationMaterial {
    func getJWKValue() throws -> JWK {
        let jwkConverted = try convertToJWK()
        let decoder = JSONDecoder()
        return try decoder.decode(JWK.self, from: jwkConverted.value)
    }
}
