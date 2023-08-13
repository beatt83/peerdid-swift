//
//  EncodeEcnumbasisTests.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

@testable import PeerDID
import XCTest

final class EncodeEcnumbasisTests: XCTestCase {

    func testEncodeService() throws {
        let service = DIDDocument.Service(
            id: "test",
            type: "DIDCommMessaging",
            serviceEndpoint: "https://example.com/endpoint",
            routingKeys: ["did:example:somemediator#somekey"],
            accept: ["didcomm/v2", "didcomm/aip2;env=rfc587"]
        )
        
        let expect = "SeyJhIjpbImRpZGNvbW0vdjIiLCJkaWRjb21tL2FpcDI7ZW52PXJmYzU4NyJdLCJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwidCI6ImRtIn0"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(services: [service]))
    }
    
    func testDecodeService() throws {
        let did = "did:test:abc"
        let service = "eyJ0IjoiZG0iLCJzIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCIsInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXX0"
        
        let expected = [DIDDocument.Service(
            id: "\(did)#didcommmessaging-0",
            type: "DIDCommMessaging",
            serviceEndpoint: "https://example.com/endpoint",
            routingKeys: ["did:example:somemediator#somekey"],
            accept: ["didcomm/v2", "didcomm/aip2;env=rfc587"]
        )]
        
        XCTAssertEqual(expected, try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: service))
    }
}

extension DIDDocument.Service: Equatable {
    public static func == (lhs: DIDDocument.Service, rhs: DIDDocument.Service) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.serviceEndpoint == rhs.serviceEndpoint &&
        lhs.routingKeys == rhs.routingKeys &&
        lhs.accept == rhs.accept
    }
}
