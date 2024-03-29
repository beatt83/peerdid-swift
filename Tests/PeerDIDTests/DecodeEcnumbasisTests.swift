//
//  DecodeEcnumbasisTest.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//
import DIDCore
@testable import PeerDID
import XCTest

final class DecodeEcnumbasisTest: XCTestCase {
    func testDecodeFormatBase58KeyED25519() throws {
        let expected = PeerDIDVerificationMaterial(
            format: .base58,
            value: "ByHnpUCFb1vAfh9CFZ8ZkmUZguURW8nSw889hy6rD8L7".data(using: .utf8)!,
            type: .authentication(.ed25519VerificationKey2018)
        )
        
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(
            ecnumbasis: "z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V",
            format: .base58
        )
        
        XCTAssertEqual(expected, decoded)
    }
    
    func testDecodeFormatBase58KeyX25519() throws {
        let expected = PeerDIDVerificationMaterial(
            format: .base58,
            value: "JhNWeSVLMYccCk7iopQW4guaSJTojqpMEELgSLhKwRr".data(using: .utf8)!,
            type: .agreement(.x25519KeyAgreementKey2019)
        )
        
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(
            ecnumbasis: "z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc",
            format: .base58
        )
        
        XCTAssertEqual(expected, decoded)
    }
    
    func testDecodeFormatMultibaseKeyEd25519() throws {
        let expected = PeerDIDVerificationMaterial(
            format: .multibase,
            value: "z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V".data(using: .utf8)!,
            type: .authentication(.ed25519VerificationKey2020)
        )
        
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(
            ecnumbasis: "z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V",
            format: .multibase
        )
        
        XCTAssertEqual(expected, decoded)
    }
    
    func testDecodeFormatMultibaseKeyX25519() throws {
        let expected = PeerDIDVerificationMaterial(
            format: .multibase,
            value: "z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc".data(using: .utf8)!,
            type: .agreement(.x25519KeyAgreementKey2020)
        )
        
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(
            ecnumbasis: "z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc",
            format: .multibase
        )
        
        XCTAssertEqual(expected, decoded)
    }
    
    func testDecodeFormatJWKKeyEd25519() throws {
        let expectedJWK = JWK(
            kty: "OKP",
            crv: "Ed25519",
            x: "owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA"
        )
        let encoder = JSONEncoder.peerDIDEncoder()
        let encodedJWK = try encoder.encode(expectedJWK)
        
        let expected = PeerDIDVerificationMaterial(
            format: .jwk,
            value: encodedJWK,
            type: .authentication(.jsonWebKey2020)
        )
        
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(
            ecnumbasis: "z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V",
            format: .jwk
        )
        
        XCTAssertEqual(expected, decoded)
    }
    
    func testDecodeFormatJWKKeyX25519() throws {
        let expectedJWK = JWK(
            kty: "OKP",
            crv: "X25519",
            x: "BIiFcQEn3dfvB2pjlhOQQour6jXy9d5s2FKEJNTOJik"
        )
        let encoder = JSONEncoder.peerDIDEncoder()
        let encodedJWK = try encoder.encode(expectedJWK)
        
        let expected = PeerDIDVerificationMaterial(
            format: .jwk,
            value: encodedJWK,
            type: .agreement(.jsonWebKey2020)
        )
        
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(
            ecnumbasis: "z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc",
            format: .jwk
        )
        
        XCTAssertEqual(expected, decoded)
    }
}

extension PeerDIDVerificationMaterial: Equatable {
    public static func == (lhs: PeerDIDVerificationMaterial, rhs: PeerDIDVerificationMaterial) -> Bool {
        lhs.format == rhs.format && lhs.value == rhs.value && lhs.type == rhs.type
    }
    
}
