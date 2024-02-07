//
//  PeerDIDHelper+ResolveAlgo0.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import DIDCore
import Foundation

extension PeerDIDHelper {
    
    public func resolvePeerDIDAlgo0(peerDID: PeerDID, format: VerificationMaterialFormat) throws -> DIDDocument {
        let keyStr = String(peerDID.methodId.dropFirst())
        let decoded = try PeerDIDHelper().decodeMultibaseEcnumbasis(ecnumbasis: keyStr, format: format)
        return DIDDocument(
            id: peerDID.string,
            verificationMethods: [
                try .init(
                    did: peerDID.string,
                    id: keyStr,
                    material: decoded
                )
            ],
            services: []
        )
    }
}
