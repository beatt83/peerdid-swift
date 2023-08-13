//
//  ResolvePeerDIDAlgo0Tests.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

@testable import peerdid_swift
import XCTest

final class ResolvePeerDIDAlgo0Tests: XCTestCase {
    
    let validDid = "did:peer:0z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V"
    
    func testResolvePeerDIDAlgo0Base58() throws {
        let did = try PeerDID(didString: validDid)
        let document = try PeerDIDHelper().resolvePeerDIDAlgo0(
            peerDID: did,
            format: .base58
        )
        
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let encodedDocument = String(data: try encoder.encode(document), encoding: .utf8)!
        XCTAssertTrue(encodedDocument.contains("\"publicKeyBase58\":\"ByHnpUCFb1vAfh9CFZ8ZkmUZguURW8nSw889hy6rD8L7\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"did:peer:0z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V#z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V)\""))
    }
    
    func testResolvePeerDIDAlgo0JWK() throws {
        let did = try PeerDID(didString: validDid)
        let document = try PeerDIDHelper().resolvePeerDIDAlgo0(
            peerDID: did,
            format: .jwk
        )
        
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let encodedDocument = String(data: try encoder.encode(document), encoding: .utf8)!
        XCTAssertTrue(encodedDocument.contains("\"publicKeyJwk\":{\"crv\":\"Ed25519\",\"kty\":\"OKP\",\"x\":\"owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA\"}"))
        XCTAssertTrue(encodedDocument.contains("\"crv\":\"Ed25519\""))
        XCTAssertTrue(encodedDocument.contains("\"x\":\"owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA\""))
        XCTAssertTrue(encodedDocument.contains("\"type\":\"jsonWebKey2020\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"did:peer:0z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V#z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V)\""))
    }
    
    func testResolvePeerDIDAlgo0Multibase() throws {
        let did = try PeerDID(didString: validDid)
        let document = try PeerDIDHelper().resolvePeerDIDAlgo0(
            peerDID: did,
            format: .multibase
        )
        
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let encodedDocument = String(data: try encoder.encode(document), encoding: .utf8)!
        XCTAssertTrue(encodedDocument.contains("\"publicKeyMultibase\":\"z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"did:peer:0z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V#z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V)\""))
    }
}
