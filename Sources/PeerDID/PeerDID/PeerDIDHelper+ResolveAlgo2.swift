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
        let keys = peerDID.algo2Keys
        let services = peerDID.algo2Service
        
        var keyIdCount = 1
        let verificationMethods = try keys
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
        
        let keyAgreements = verificationMethods.filter {
            guard let type = KnownVerificationMaterialType(rawValue: $0.type) else {
                return false
            }
            
            if case .agreement = type {
                return true
            }
            return false
        }.map(\.id)
        
        let authenticationAgreements = verificationMethods.filter {
            guard let type = KnownVerificationMaterialType(rawValue: $0.type) else {
                return false
            }
            
            if case .authentication = type {
                return true
            }
            return false
        }.map(\.id)
        
        let documentServices = try services.enumerated().map {
            try decodedPeerDIDService(did: peerDID.string, serviceString: $0.element, index: $0.offset)
        }
        
        return DIDDocument(
            id: peerDID.string,
            verificationMethods: verificationMethods,
            authentication: authenticationAgreements.map { .stringValue($0) },
            keyAgreement: keyAgreements.map { .stringValue($0) },
            services: documentServices
        )
    }
}
