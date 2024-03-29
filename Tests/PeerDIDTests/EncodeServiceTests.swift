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
                dictionaryLiteral: ("uri","https://example.com/endpoint"), ("routing_keys", ["did:example:somemediator#somekey"]), ("accept", ["didcomm/v2", "didcomm/aip2;env=rfc587"]))
        )
        
        let expect = "SeyJzIjp7ImEiOlsiZGlkY29tbS92MiIsImRpZGNvbW0vYWlwMjtlbnY9cmZjNTg3Il0sInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(service: service))
    }
    
    func testDecodeService() throws {
        let did = "did:test:abc"
        let service = "eyJ0IjoiZG0iLCJzIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCIsInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXX0"
        
        let expected = DIDDocument.Service(
            id: "did:test:abc#didcommmessaging-1",
            type: "DIDCommMessaging",
            serviceEndpoint: AnyCodable(
                dictionaryLiteral: ("uri","https://example.com/endpoint"), ("routing_keys", ["did:example:somemediator#somekey"]), ("accept", ["didcomm/v2", "didcomm/aip2;env=rfc587"]))
        )
        
        XCTAssertEqual(expected, try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: service, index: 0))
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
        (lhsS["routing_keys"]  as? [String]) == (rhsS["routing_keys"] as? [String])
    }
}
