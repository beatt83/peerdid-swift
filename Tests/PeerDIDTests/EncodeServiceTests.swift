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
        let service = [
            "id": "did:test:abc#didcommmessaging-1",
            "type": "DIDCommMessaging",
            "serviceEndpoint": [
                "uri": "https://example.com/endpoint",
                "routingKeys": ["did:example:somemediator#somekey"],
                "accept": ["didcomm/v2", "didcomm/aip2;env=rfc587"]
            ]
        ] as [String: Any]
        
        let expect = "SeyJzIjp7ImEiOlsiZGlkY29tbS92MiIsImRpZGNvbW0vYWlwMjtlbnY9cmZjNTg3Il0sInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(service: AnyCodable(service)))
    }
    
    func testEncodeServiceLegacy() throws {
        let service = [
            "id": "did:test:abc#didcommmessaging-1",
            "type": "DIDCommMessaging",
            "serviceEndpoint": "https://example.com/endpoint",
            "routingKeys": ["did:example:somemediator#somekey"],
            "accept": ["didcomm/v2", "didcomm/aip2;env=rfc587"]
        ] as [String: Any]
        
        let expect = "SeyJhIjpbImRpZGNvbW0vdjIiLCJkaWRjb21tL2FpcDI7ZW52PXJmYzU4NyJdLCJyIjpbImRpZDpleGFtcGxlOnNvbWVtZWRpYXRvciNzb21la2V5Il0sInMiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50IiwidCI6ImRtIn0"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(service: AnyCodable(service)))
    }
    
    func testEncodeServiceExtensions() throws {
        let service = [
            "id": "did:test:abc#didcommmessaging-1",
            "type": "DIDCommMessaging",
            "serviceEndpoint": [
                "uri": "https://example.com/endpoint",
                "routingKeys": ["did:example:somemediator#somekey"],
                "accept": ["didcomm/v2", "didcomm/aip2;env=rfc587"]
            ],
            "extension1": "testExtension",
            "extension2": ["testExtension"],
            "extension3": ["testKey": "test"],
        ] as [String: Any]
        
        let expect = "SeyJleHRlbnNpb24xIjoidGVzdEV4dGVuc2lvbiIsImV4dGVuc2lvbjIiOlsidGVzdEV4dGVuc2lvbiJdLCJleHRlbnNpb24zIjp7InRlc3RLZXkiOiJ0ZXN0In0sInMiOnsiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXSwiciI6WyJkaWQ6ZXhhbXBsZTpzb21lbWVkaWF0b3Ijc29tZWtleSJdLCJ1cmkiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50In0sInQiOiJkbSJ9"
        
        XCTAssertEqual(expect, try PeerDIDHelper().encodePeerDIDServices(service: AnyCodable(service)))
    }
    
    func testDecodeServiceLegacy() throws {
        let did = "did:test:abc"
        let service = "eyJ0IjoiZG0iLCJzIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCIsInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXX0"
        
        let decoded = try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: service, index: 0).value as! [String: Any]
        
        XCTAssertEqual("DIDCommMessaging", decoded["type"] as? String)
        XCTAssertEqual("did:test:abc#didcommmessaging-1", decoded["id"] as? String)
        XCTAssertEqual("https://example.com/endpoint", decoded["serviceEndpoint"] as? String)
        XCTAssertEqual(["did:example:somemediator#somekey"], decoded["routingKeys"] as? [String])
        XCTAssertEqual(["didcomm/v2", "didcomm/aip2;env=rfc587"], decoded["accept"] as? [String])
    }
    
    func testDecodeService() throws {
        let did = "did:test:abc"
        let service = "eyJzIjp7ImEiOlsiZGlkY29tbS92MiIsImRpZGNvbW0vYWlwMjtlbnY9cmZjNTg3Il0sInIiOlsiZGlkOmV4YW1wbGU6c29tZW1lZGlhdG9yI3NvbWVrZXkiXSwidXJpIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9lbmRwb2ludCJ9LCJ0IjoiZG0ifQ"
        
        let decoded = try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: service, index: 0).value as! [String: Any]
        
        XCTAssertEqual("DIDCommMessaging", decoded["type"] as? String)
        XCTAssertEqual("did:test:abc#didcommmessaging-1", decoded["id"] as? String)
        
        let serviceEndpoint = decoded["serviceEndpoint"] as! [String: Any]
        
        XCTAssertEqual(["did:example:somemediator#somekey"], serviceEndpoint["routingKeys"] as? [String])
        XCTAssertEqual(["didcomm/v2", "didcomm/aip2;env=rfc587"], serviceEndpoint["accept"] as? [String])
    }
    
    func testDecodeServiceWithExtensions() throws {
        let did = "did:test:abc"
        let service = "eyJleHRlbnNpb24xIjoidGVzdEV4dGVuc2lvbiIsImV4dGVuc2lvbjIiOlsidGVzdEV4dGVuc2lvbiJdLCJleHRlbnNpb24zIjp7InRlc3RLZXkiOiJ0ZXN0In0sInMiOnsiYSI6WyJkaWRjb21tL3YyIiwiZGlkY29tbS9haXAyO2Vudj1yZmM1ODciXSwiciI6WyJkaWQ6ZXhhbXBsZTpzb21lbWVkaWF0b3Ijc29tZWtleSJdLCJ1cmkiOiJodHRwczovL2V4YW1wbGUuY29tL2VuZHBvaW50In0sInQiOiJkbSJ9"
        
        let decoded = try PeerDIDHelper().decodedPeerDIDService(did: did, serviceString: service, index: 0).value as! [String: Any]

        XCTAssertEqual("testExtension", decoded["extension1"] as? String)
        XCTAssertEqual(["testExtension"], decoded["extension2"] as? [String])
        XCTAssertEqual(["testKey": "test"], decoded["extension3"] as? [String: String])
        XCTAssertEqual("DIDCommMessaging", decoded["type"] as? String)
        XCTAssertEqual("did:test:abc#didcommmessaging-1", decoded["id"] as? String)
        
        let serviceEndpoint = decoded["serviceEndpoint"] as! [String: Any]
        
        XCTAssertEqual(["did:example:somemediator#somekey"], serviceEndpoint["routingKeys"] as? [String])
        XCTAssertEqual(["didcomm/v2", "didcomm/aip2;env=rfc587"], serviceEndpoint["accept"] as? [String])
    }
}
