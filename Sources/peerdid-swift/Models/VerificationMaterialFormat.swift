//
//  VerificationMaterialFormat.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import BaseX
import Foundation
import Multibase

public enum VerificationMaterialFormat: String, Codable {
    case jwk
    case base58
    case multibase
}

public enum VerificationMaterialType: RawRepresentable, Codable {
    
    public enum AgreementType: String, Codable {
        case jsonWebKey2020
        case x25519KeyAgreementKey2019
        case x25519KeyAgreementKey2020
    }
    
    public enum AuthenticationType: String, Codable {
        case jsonWebKey2020
        case ed25519VerificationKey2018
        case ed25519VerificationKey2020
    }
    
    case agreement(AgreementType)
    case authentication(AuthenticationType)
    
    public init?(rawValue: String) {
        if let agreementType = AgreementType(rawValue: rawValue) {
            self = .agreement(agreementType)
        } else if let autheticationType = AuthenticationType(rawValue: rawValue) {
            self = .authentication(autheticationType)
        }
        return nil
    }
    
    public var rawValue: String {
        switch self {
        case .agreement(let type):
            return type.rawValue
        case .authentication(let type):
            return type.rawValue
        }
    }
    
    var isAuthentication: Bool {
        switch self {
        case .agreement:
            return false
        case .authentication:
            return true
        }
    }
    
    var isAgreement: Bool {
        switch self {
        case .agreement:
            return true
        case .authentication:
            return false
        }
    }
}

public struct VerificationMaterial {
    public let format: VerificationMaterialFormat
    public let value: Data
    public let type: VerificationMaterialType
}

extension VerificationMaterial: Codable {}

extension VerificationMaterial {
    
    public init(format: VerificationMaterialFormat, key: Data, type: VerificationMaterialType) throws {
        self.format = format
        self.type = type
        switch format {
        case .jwk:
            let jwk = try JWK(key: key, type: type)
            let encoder = JSONEncoder()
            self.value = try encoder.encode(jwk)
        case .base58:
            guard let encoded = BaseX.encode(key, into: .base58BTC).data(using: .utf8) else {
                throw PeerDIDError.somethingWentWrong
            }
            self.value = encoded
        case .multibase:
            let multicodec = Multicodec().toMulticodec(value: key, keyType: type)
            guard let multibase = BaseEncoding.base58btc.encode(data: multicodec).data(using: .utf8) else {
                throw PeerDIDError.somethingWentWrong
            }
            self.value = multibase
        }
    }
    
    public func decodedKey() throws -> Data {
        switch format {
        case .jwk:
            let decoder = JSONDecoder()
            let jwk = try decoder.decode(JWK.self, from: value)
            guard let decoded = Data(base64URLEncoded: jwk.x) else {
                throw PeerDIDError.invalidBase64URLKey
            }
            return decoded
        case .base58:
            guard let base58Str = String(data: value, encoding: .utf8) else {
                throw PeerDIDError.invalidBase64URLKey
            }
            return try BaseX.decode(base58Str, as: .base58BTC)
        case .multibase:
            guard let multibaseStr = String(data: value, encoding: .utf8) else {
                throw PeerDIDError.invalidBase64URLKey
            }
            let multibaseDecoded = try BaseEncoding.decode(multibaseStr).data
            return try Multicodec().fromMulticodec(value: multibaseDecoded).data
        }
    }
}
