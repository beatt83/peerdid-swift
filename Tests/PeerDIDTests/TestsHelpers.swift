//
//  File.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

@testable import PeerDID
import Foundation

extension JWK {
    static func testable(crv: String = "Ed25519", x: String = "owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA") -> JWK {
        return JWK(crv: crv, x: x)
    }
    
    static func testableData(crv: String = "Ed25519", x: String = "owBhCbktDjkfS6PdQddT0D3yjSitaSysP3YimJ_YgmA") -> Data {
        let encoder = JSONEncoder.peerDIDEncoder()
        return try! encoder.encode(testable(crv: crv, x: x))
    }
}
