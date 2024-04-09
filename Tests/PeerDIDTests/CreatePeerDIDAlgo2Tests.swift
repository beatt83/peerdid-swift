//
//  CreatePeerDIDAlgo2.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//
import DIDCore
@testable import PeerDID
import XCTest

final class CreatePeerDIDAlgo2Tests: XCTestCase {
    
    let valid_ed25519_key1_base58 = PeerDIDVerificationMaterial(
        format: .base58,
        value: "ByHnpUCFb1vAfh9CFZ8ZkmUZguURW8nSw889hy6rD8L7".data(using: .utf8)!,
        type: .authentication(.ed25519VerificationKey2018)
    )
    
    let valid_ed25519_key2_base58 = PeerDIDVerificationMaterial(
        format: .base58,
        value: "3M5RCDjPTWPkKSN3sxUmmMqHbmRPegYP1tjcKyrDbt9J".data(using: .utf8)!,
        type: .authentication(.ed25519VerificationKey2018)
    )
    
    let valid_ed25519_key1_multibase = PeerDIDVerificationMaterial(
        format: .multibase,
        value: "z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V".data(using: .utf8)!,
        type: .authentication(.ed25519VerificationKey2020)
    )
    
    let valid_ed25519_key2_multibase = PeerDIDVerificationMaterial(
        format: .multibase,
        value: "z6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg".data(using: .utf8)!,
        type: .authentication(.ed25519VerificationKey2020)
    )
    
    let valid_ed25519_key1_jwk = PeerDIDVerificationMaterial(
        format: .jwk,
        value: JWK.testableData(),
        type: .authentication(.jsonWebKey2020)
    )
    
    let valid_ed25519_key2_jwk = PeerDIDVerificationMaterial(
        format: .jwk,
        value: JWK.testableData(x: "Itv8B__b1-Jos3LCpUe8EdTFGTCa_Dza6_3848P3R70"),
        type: .authentication(.jsonWebKey2020)
    )
    
    let valid_x25519_key_base58 = PeerDIDVerificationMaterial(
        format: .base58,
        value: "JhNWeSVLMYccCk7iopQW4guaSJTojqpMEELgSLhKwRr".data(using: .utf8)!,
        type: .agreement(.x25519KeyAgreementKey2019)
    )
    
    let valid_x25519_key_multibase = PeerDIDVerificationMaterial(
        format: .multibase,
        value: "z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc".data(using: .utf8)!,
        type: .agreement(.x25519KeyAgreementKey2020)
    )
    
    let valid_x25519_key_jwk = PeerDIDVerificationMaterial(
        format: .jwk,
        value: JWK.testableData(crv: "X25519", x: "BIiFcQEn3dfvB2pjlhOQQour6jXy9d5s2FKEJNTOJik"),
        type: .agreement(.jsonWebKey2020)
    )
    
    let validService = DIDDocument.Service(
        id: "test",
        type: "DIDCommMessaging",
        serviceEndpoint: AnyCodable(
            dictionaryLiteral: ("uri","https://example.com/endpoint"), ("routingKeys", ["did:example:somemediator#somekey"]))
    )
    
    func testCreatePeerDIDAlgo2Base58() throws {
        let peerDID = try PeerDIDHelper.createAlgo2(
            authenticationKeys: [valid_ed25519_key1_base58, valid_ed25519_key2_base58],
            agreementKeys: [valid_x25519_key_base58],
            services: [validService]
        )
        
        XCTAssertEqual("did:peer:2.Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V.Vz6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ", peerDID.string)
        
        XCTAssertTrue(peerDID.algo2KeyAgreementKeys.contains("z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg"))
        XCTAssertTrue(peerDID.algo2Service.contains("eyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"))
    }
    
    func testCreatePeerDIDAlgo2Legacy() throws {
        let peerDID = try PeerDIDHelper.createAlgo2(
            authenticationKeys: [valid_ed25519_key1_base58, valid_ed25519_key2_base58],
            agreementKeys: [valid_x25519_key_base58],
            services: [validService],
            recipientKeys: [[]]
        )
        
        XCTAssertEqual("did:peer:2.Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V.Vz6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg.SeyJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwidCI6ImRtIn0", peerDID.string)
        
        XCTAssertTrue(peerDID.algo2KeyAgreementKeys.contains("z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg"))
        XCTAssertTrue(peerDID.algo2Service.contains("eyJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwidCI6ImRtIn0"))
    }

    func testCreatePeerDIDAlgo2Multibase() throws {
        let peerDID = try PeerDIDHelper.createAlgo2(
            authenticationKeys: [valid_ed25519_key1_multibase, valid_ed25519_key2_multibase],
            agreementKeys: [valid_x25519_key_multibase],
            services: [validService]
        )
        
        XCTAssertEqual("did:peer:2.Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V.Vz6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ", peerDID.string)
        
        XCTAssertTrue(peerDID.algo2KeyAgreementKeys.contains("z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg"))
        XCTAssertTrue(peerDID.algo2Service.contains("eyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"))
    }
    
    func testCreatePeerDIDAlgo2JWK() throws {
        let peerDID = try PeerDIDHelper.createAlgo2(
            authenticationKeys: [valid_ed25519_key1_jwk, valid_ed25519_key2_jwk],
            agreementKeys: [valid_x25519_key_jwk],
            services: [validService]
        )
        
        XCTAssertEqual("did:peer:2.Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V.Vz6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ", peerDID.string)
        
        XCTAssertTrue(peerDID.algo2KeyAgreementKeys.contains("z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V"))
        XCTAssertTrue(peerDID.algo2AuthenticationKeys.contains("z6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg"))
        XCTAssertTrue(peerDID.algo2Service.contains("eyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"))
    }
    
    func testCreatePeerDIDAlgo2MultipleServices() throws {
        let peerDID = try PeerDIDHelper.createAlgo2(
            authenticationKeys: [valid_ed25519_key1_jwk],
            agreementKeys: [valid_x25519_key_jwk],
            services: [validService, validService]
        )
        
        XCTAssertEqual("did:peer:2.Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ", peerDID.string)
        
        XCTAssertTrue(peerDID.algo2Service.contains("eyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"))
    }
    
    func testCreatePeerDIDAlgo2NoServices() throws {
        let peerDID = try PeerDIDHelper.createAlgo2(
            authenticationKeys: [valid_ed25519_key1_jwk],
            agreementKeys: [valid_x25519_key_jwk],
            services: []
        )
        
        XCTAssertEqual("did:peer:2.Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V", peerDID.string)
    }
}
