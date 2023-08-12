//
//  Errors.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import Foundation

enum PeerDIDError: LocalizedError {
    case somethingWentWrong
    case invalidKeySize
    case couldNotCreateEcnumbasis(derivedError: LocalizedError? = nil)
    case couldNotDecodeEcnumbasis
    case invalidPeerDIDService
    case invalidBase64URLKey
    case invalidBase58Key
    case invalidMulticodec
    case invalidMaterialType(String)
    case invalidJWKMaterialType(VerificationMaterialType)
    case unsupportedPeerDIDAlgo(String)
    case invalidPeerDIDString
}
