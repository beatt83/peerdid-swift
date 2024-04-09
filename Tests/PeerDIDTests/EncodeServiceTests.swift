//
//  EncodeEcnumbasisTests.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import DIDCore
@testable import PeerDID
import XCTest

final class EncodeEcnumbasisTests: XCTestCase {

    func testEncodeService() throws {
        let service = DIDDocument.Service(
            id: "did:test:abc#didcommmessaging-1",
            type: "DIDCommMessaging",
            serviceEndpoint: AnyCodable(
                dictionaryLiteral: ("uri","https://example.com/endpoint"), ("routingKeys", ["did:example:somemediator#somekey"]), ("accept", ["didcomm/v2", "didcomm/aip2;env=rfc587"]))
        )
        
        let expect = "SeyJzIjp7ImEiOlsiZGlkY29tbS92MiIsImRpZGNvbW0vYWlwMjtlbnY9cmZjNTg3Il0sInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(service: service))
    }

    func testEncodeToLegacyService() throws {
        let service = DIDDocument.Service(
            id: "did:test:abc#didcommmessaging-1",
            type: "DIDCommMessaging",
            serviceEndpoint: AnyCodable(
                dictionaryLiteral: ("uri","https://example.com/endpoint"), ("routingKeys", ["did:example:somemediator#somekey"]), ("accept", ["didcomm/v2", "didcomm/aip2;env=rfc587"]))
        )
        
        let expect = "SeyJhIjpbImRpZGNvbW0vdjIiLCJkaWRjb21tL2FpcDI7ZW52PXJmYzU4NyJdLCJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwidCI6ImRtIn0"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(service: service, recipientKeys: []))
    }

    func testEncodeToLegacyServiceNoAccept() throws {
        let service = DIDDocument.Service(
            id: "test",
            type: "DIDCommMessaging",
            serviceEndpoint: AnyCodable(
                dictionaryLiteral: ("uri","https://example.com/endpoint"), ("routingKeys", ["did:example:somemediator#somekey"]))
            )
        
        let expect = "SeyJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwidCI6ImRtIn0"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(service: service, recipientKeys: []))
    }

    func testDecodeService() throws {
        let did = "did:test:abc"
        let legacyService = "eyJ0IjoiZG0iLCJzIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCIsInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXX0"
        let legacyServiceSorted = "eyJhIjpbImRpZGNvbW0vdjIiLCJkaWRjb21tL2FpcDI7ZW52PXJmYzU4NyJdLCJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwidCI6ImRtIn0"
        let service = "eyJzIjp7ImEiOlsiZGlkY29tbS92MiIsImRpZGNvbW0vYWlwMjtlbnY9cmZjNTg3Il0sInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"
        
        let expected = DIDDocument.Service(
            id: "did:test:abc#didcommmessaging-1",
            type: "DIDCommMessaging",
            serviceEndpoint: AnyCodable(
                dictionaryLiteral: ("uri","https://example.com/endpoint"), ("routingKeys", ["did:example:somemediator#somekey"]), ("accept", ["didcomm/v2", "didcomm/aip2;env=rfc587"]))
        )
        
        XCTAssertEqual(expected, try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: service, index: 0))
        XCTAssertEqual(expected, try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: legacyService, index: 0))
        XCTAssertEqual(expected, try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: legacyServiceSorted, index: 0))
    }
}

extension DIDDocument.Service: Equatable {
    public static func == (lhs: DIDDocument.Service, rhs: DIDDocument.Service) -> Bool {
        guard 
            let lhsS = lhs.serviceEndpoint.value as? [String: Any],
            let rhsS = rhs.serviceEndpoint.value as? [String: Any]
        else {
            return false
        }
        return lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        (lhsS["uri"] as! String) == (rhsS["uri"] as! String) &&
        (lhsS["accept"] as? [String]) == (rhsS["accept"] as? [String]) &&
        (lhsS["routingKeys"]  as? [String]) == (rhsS["routingKeys"] as? [String])
    }
}
