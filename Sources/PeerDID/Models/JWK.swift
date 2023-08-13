//
//  JWK.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import Base64
import Foundation

public struct JWK {
    public let kty = "OKP"
    public let crv: String
    public let x: String
}

extension JWK: Codable {}

extension JWK {
    init(key: Data, type: VerificationMaterialType) throws {
        self.x = key.base64URLEncoded(padded: false)
        switch type {
        case .agreement(.jsonWebKey2020):
            self.crv = "X25519"
        case .authentication(.jsonWebKey2020):
            self.crv = "Ed25519"
        default:
            throw PeerDIDError.invalidJWKMaterialType(type)
        }
    }
}
