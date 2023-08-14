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
            id: "test",
            type: "DIDCommMessaging",
            serviceEndpoint: .string("https://example.com/endpoint"),
            routingKeys: ["did:example:somemediator#somekey"],
            accept: ["didcomm/v2", "didcomm/aip2;env=rfc587"]
        )
        
        let expect = "SeyJhIjpbImRpZGNvbW0vdjIiLCJkaWRjb21tL2FpcDI7ZW52PXJmYzU4NyJdLCJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJcImh0dHBzOi8vZXhhbXBsZS5jb20vZW5kcG9pbnRcIiIsInQiOiJkbSJ9"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(services: [service]))
    }
    
    func testDecodeService() throws {
        let did = "did:test:abc"
        let service = "eyJ0IjoiZG0iLCJzIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCIsInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXX0"
        
        let expected = [DIDDocument.Service(
            id: "\(did)#didcommmessaging-1",
            type: "DIDCommMessaging",
            serviceEndpoint: .string("https://example.com/endpoint"),
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

extension DIDDocument.Service.ServiceEndpoint: Equatable {
    public static func == (lhs: DIDDocument.Service.ServiceEndpoint, rhs: DIDDocument.Service.ServiceEndpoint) -> Bool {
        switch (lhs, rhs) {
        case let (.string(lhsValue), .string(rhsValue)):
            return lhsValue == rhsValue
        case let (.set(lhsValue), .set(rhsValue)):
            return lhsValue == rhsValue
        case let (.map(lhsValue), .map(rhsValue)):
            return lhsValue == rhsValue
        case let (.combo(lhsValue), .combo(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension DIDDocument.Service.ServiceEndpoint.EndpointElement: Equatable {
    public static func == (
        lhs: DIDDocument.Service.ServiceEndpoint.EndpointElement,
        rhs: DIDDocument.Service.ServiceEndpoint.EndpointElement
    ) -> Bool {
        switch (lhs, rhs) {
        case let (.mapValue(lhsValue), .mapValue(rhsValue)):
            return lhsValue == rhsValue
        case let (.stringValue(lhsValue), .stringValue(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
