//
//  CreatePeerDIDAlgo0Tests.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import DIDCore
@testable import PeerDID
import XCTest

final class CreatePeerDIDAlgo0Tests: XCTestCase {

    func testCreatePeerDIDAlgo0Base58Key() throws {
        let material = PeerDIDVerificationMaterial(
            format: .base58,
            value: "ByHnpUCFb1vAfh9CFZ8ZkmUZguURW8nSw889hy6rD8L7".data(using: .utf8)!,
            type: .authentication(.ed25519VerificationKey2018)
        )
        let peerDID = try PeerDIDHelper.createAlgo0(key: material)
        XCTAssertEqual("did:peer:0z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V", peerDID.string)
    }
    
    func testCreatePeerDIDAlgo0MultibaseKey() throws {
        let material = PeerDIDVerificationMaterial(
            format: .multibase,
            value: "z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V".data(using: .utf8)!,
            type: .authentication(.ed25519VerificationKey2020)
        )
        let peerDID = try PeerDIDHelper.createAlgo0(key: material)
        XCTAssertEqual("did:peer:0z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V", peerDID.string)
    }
    
    func testCreatePeerDIDAlgo0JWKKey() throws {
        let jwk = JWK(
            kty: "OKP", 
            crv: "Ed25519",
            x: "owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA"
        )
        
        let encoder = JSONEncoder.peerDIDEncoder()
        let encodedJWK = try encoder.encode(jwk)
        
        let material = PeerDIDVerificationMaterial(
            format: .jwk,
            value: encodedJWK,
            type: .authentication(.jsonWebKey2020)
        )
        let peerDID = try PeerDIDHelper.createAlgo0(key: material)
        XCTAssertEqual("did:peer:0z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V", peerDID.string)
    }
}
