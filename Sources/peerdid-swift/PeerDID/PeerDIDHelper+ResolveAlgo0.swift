//
//  PeerDIDHelper+ResolveAlgo0.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import Foundation

extension PeerDIDHelper {
    
    public func resolvePeerDIDAlgo0(peerDID: PeerDID, format: VerificationMaterialFormat) throws -> DIDDocument {
        let keyStr = String(peerDID.methodId.dropFirst())
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(ecnumbasis: keyStr, format: format)
        return DIDDocument(
            did: peerDID.string,
            verificationMethods: [.init(
                id: "\(peerDID.string)#\(keyStr))",
                controller: peerDID.string,
                material: decoded.material
            )],
            services: []
        )
    }
}
