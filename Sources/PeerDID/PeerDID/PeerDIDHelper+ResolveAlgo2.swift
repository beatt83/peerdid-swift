//
//  PeerDIDHelper+ResolveAlgo2.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import DIDCore
import Foundation

extension PeerDIDHelper {
    
    public func resolvePeerDIDAlgo2(peerDID: PeerDID, format: VerificationMaterialFormat) throws -> DIDDocument {
        let authenticationKeys = peerDID.algo2AuthenticationKeys
        let agreementKeys = peerDID.algo2KeyAgreementKeys
        let services = peerDID.algo2Service
        
        var keyIdCount = 1
        let authenticationVerificationMethods = try authenticationKeys
            .map { try decodeMultibaseEcnumbasis(ecnumbasis: $0, format: format) }
            .map {
                let method = try DIDDocument.VerificationMethod(
                    did: peerDID.string,
                    id: "key-\(keyIdCount)",
                    material: $0
                )
                keyIdCount+=1
                return method
            }
        
        let agreementVerificationMethods = try agreementKeys
            .map { try decodeMultibaseEcnumbasis(ecnumbasis: $0, format: format) }
            .map {
                let method = try DIDDocument.VerificationMethod(
                    did: peerDID.string,
                    id: "key-\(keyIdCount)",
                    material: $0
                )
                keyIdCount+=1
                return method
            }
        
        let documentServices = try services.enumerated().map {
            try decodedPeerDIDService(did: peerDID.string, serviceString: $0.element, index: $0.offset)
        }
        
        return DIDDocument(
            id: peerDID.string,
            verificationMethods: authenticationVerificationMethods + agreementVerificationMethods,
            services: documentServices
        )
    }
}
