//
//  ReselvePeerDIDAlgo2Tests.swift
//  
//
//  Created by Gonçalo Frade on 13/08/2023.
//

@testable import PeerDID
import XCTest

final class ReselvePeerDIDAlgo2Tests: XCTestCase {
    let validDid = "did:peer:2" +
    ".Ez6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc" +
    ".Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V" +
    ".Vz6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg" +
    ".SeyJ0IjoiZG0iLCJzIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCIsInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXX0"
    
    let validDid2Services = "did:peer:2" +
    ".Ez6LSpSrLxbAhg2SHwKk7kwpsH7DM7QjFS5iK6qP87eViohud" +
    ".Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V" +
    ".SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ" +
    ".SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"
    
    func testResolvePeerDIDAlgo2Base58() throws {
        let did = try PeerDID(didString: validDid)
        let document = try PeerDIDHelper().resolvePeerDIDAlgo2(peerDID: did, format: .base58)
        
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let encodedDocument = String(data: try encoder.encode(document), encoding: .utf8)!
        
        print(encodedDocument)
        XCTAssertTrue(encodedDocument.contains("\"publicKeyBase58\":\"ByHnpUCFb1vAfh9CFZ8ZkmUZguURW8nSw889hy6rD8L7\""))
        XCTAssertTrue(encodedDocument.contains("\"publicKeyBase58\":\"3M5RCDjPTWPkKSN3sxUmmMqHbmRPegYP1tjcKyrDbt9J\""))
        XCTAssertTrue(encodedDocument.contains("\"publicKeyBase58\":\"JhNWeSVLMYccCk7iopQW4guaSJTojqpMEELgSLhKwRr\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-1\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-2\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-3\""))
        XCTAssertTrue(encodedDocument.contains("\"type\":\"Ed25519VerificationKey2018\""))
        XCTAssertTrue(encodedDocument.contains("\"type\":\"X25519KeyAgreementKey2019\""))
    }
    
    func testResolvePeerDIDAlgo2JWK() throws {
        let did = try PeerDID(didString: validDid)
        let document = try PeerDIDHelper().resolvePeerDIDAlgo2(peerDID: did, format: .jwk)
        
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let encodedDocument = String(data: try encoder.encode(document), encoding: .utf8)!
        
        print(encodedDocument)
        XCTAssertTrue(encodedDocument.contains("\"publicKeyJwk\":{\"crv\":\"Ed25519\",\"kty\":\"OKP\",\"x\":\"owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA\"}"))
        XCTAssertTrue(encodedDocument.contains("\"publicKeyJwk\":{\"crv\":\"Ed25519\",\"kty\":\"OKP\",\"x\":\"Itv8B__b1-Jos3LCpUe8EdTFGTCa_Dza6_3848P3R70\"}"))
        XCTAssertTrue(encodedDocument.contains("\"publicKeyJwk\":{\"crv\":\"X25519\",\"kty\":\"OKP\",\"x\":\"BIiFcQEn3dfvB2pjlhOQQour6jXy9d5s2FKEJNTOJik\"}"))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-1\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-2\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-3\""))
        XCTAssertTrue(encodedDocument.contains("\"type\":\"JsonWebKey2020\""))
        XCTAssertTrue(encodedDocument.contains("\"type\":\"JsonWebKey2020\""))
    }
    
    func testResolvePeerDIDAlgo2Multibase() throws {
        let did = try PeerDID(didString: validDid)
        let document = try PeerDIDHelper().resolvePeerDIDAlgo2(peerDID: did, format: .multibase)
        
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let encodedDocument = String(data: try encoder.encode(document), encoding: .utf8)!
        
        print(encodedDocument)
        XCTAssertTrue(encodedDocument.contains("\"publicKeyMultibase\":\"z6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V\""))
        XCTAssertTrue(encodedDocument.contains("\"publicKeyMultibase\":\"z6MkgoLTnTypo3tDRwCkZXSccTPHRLhF4ZnjhueYAFpEX6vg\""))
        XCTAssertTrue(encodedDocument.contains("\"publicKeyMultibase\":\"z6LSbysY2xFMRpGMhb7tFTLMpeuPRaqaWM1yECx2AtzE3KCc\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-1\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-2\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"\(validDid)#key-3\""))
        XCTAssertTrue(encodedDocument.contains("\"type\":\"Ed25519VerificationKey2020\""))
        XCTAssertTrue(encodedDocument.contains("\"type\":\"X25519KeyAgreementKey2020\""))
    }
    
    func testResolvePeerDIDAlgo2MultipleServices() throws {
        let did = try PeerDID(didString: validDid2Services)
        let document = try PeerDIDHelper().resolvePeerDIDAlgo2(peerDID: did, format: .multibase)
        
        let encoder = JSONEncoder.peerDIDEncoder()
        
        let encodedDocument = String(data: try encoder.encode(document), encoding: .utf8)!
        print(encodedDocument)
        
        XCTAssertTrue(encodedDocument.contains("\"id\":\"did:peer:2.Ez6LSpSrLxbAhg2SHwKk7kwpsH7DM7QjFS5iK6qP87eViohud.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ#didcommmessaging-1\""))
        XCTAssertTrue(encodedDocument.contains("\"id\":\"did:peer:2.Ez6LSpSrLxbAhg2SHwKk7kwpsH7DM7QjFS5iK6qP87eViohud.Vz6MkqRYqQiSgvZQdnBytw86Qbs2ZWUkGv22od935YF4s8M7V.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ.SeyJzIjp7InIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ#didcommmessaging-2\""))
    }
}
