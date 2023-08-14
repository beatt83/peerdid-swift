//
//  VerificationMaterialFormat.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import DIDCore
import BaseX
import Foundation
import Multibase

public struct PeerDIDVerificationMaterial {
    public let format: VerificationMaterialFormat
    public let value: Data
    public let type: KnownVerificationMaterialType
}

extension PeerDIDVerificationMaterial: Codable {}

extension PeerDIDVerificationMaterial {
    
    public init(format: VerificationMaterialFormat, key: Data, type: KnownVerificationMaterialType) throws {
        self.format = format
        self.type = type
        switch format {
        case .jwk:
            let jwk = try JWK(key: key, type: type)
            let encoder = JSONEncoder.peerDIDEncoder()
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
    
    public func convertToBase58() throws -> PeerDIDVerificationMaterial {
        guard self.format != .base58 else { return self }
        
        let newType: KnownVerificationMaterialType
        switch type {
        case .agreement:
            newType = .agreement(.x25519KeyAgreementKey2019)
        case .authentication:
            newType = .authentication(.ed25519VerificationKey2018)
        }
        
        return try .init(format: .base58, key: try self.decodedKey(), type: newType)
    }
    
    public func convertToJWK() throws -> PeerDIDVerificationMaterial {
        guard self.format != .jwk else { return self }
        
        let newType: KnownVerificationMaterialType
        switch type {
        case .agreement:
            newType = .agreement(.jsonWebKey2020)
        case .authentication:
            newType = .authentication(.jsonWebKey2020)
        }
        
        return try .init(format: .jwk, key: try self.decodedKey(), type: newType)
    }
    
    public func convertToMultibase() throws -> PeerDIDVerificationMaterial {
        guard self.format != .multibase else { return self }
        
        let newType: KnownVerificationMaterialType
        switch type {
        case .agreement:
            newType = .agreement(.x25519KeyAgreementKey2020)
        case .authentication:
            newType = .authentication(.ed25519VerificationKey2020)
        }
        
        return try .init(format: .multibase, key: try self.decodedKey(), type: newType)
    }
}
