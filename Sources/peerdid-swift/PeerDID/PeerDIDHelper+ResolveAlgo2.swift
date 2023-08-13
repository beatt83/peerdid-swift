//
//  PeerDIDHelper+ResolveAlgo2.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import Foundation

extension PeerDIDHelper {
    
    public func resolvePeerDIDAlgo2(peerDID: PeerDID, format: VerificationMaterialFormat) throws -> DIDDocument {
        let authenticationKeys = peerDID.algo2AuthenticationKeys
        let agreementKeys = peerDID.algo2KeyAgreementKeys
        let service = peerDID.algo2Service
        
        let authenticationVerificationMethods = try authenticationKeys
            .map { (try decodeMultibaseEcnumbasis(ecnumbasis: $0, format: format), $0) }
            .map { try DIDDocument.VerificationMethod(
                did: peerDID.string,
                ecnumbasis: String($1.dropFirst()),
                material: $0.material
            ) }
        
        let agreementVerificationMethods = try agreementKeys
            .map { (try decodeMultibaseEcnumbasis(ecnumbasis: $0, format: format), $0) }
            .map { try DIDDocument.VerificationMethod(
                did: peerDID.string,
                ecnumbasis: String($1.dropFirst()),
                material: $0.material
            ) }
        
        let documentService = try service
            .map { try decodedPeerDIDService(did: peerDID.string, serviceString: $0) }
        
        return DIDDocument(
            did: peerDID.string,
            verificationMethods: authenticationVerificationMethods + agreementVerificationMethods,
            services: documentService
        )
    }
}
