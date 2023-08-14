//
//  Errors.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import DIDCore
import Foundation

public enum PeerDIDError: LocalizedError {
    case somethingWentWrong
    case invalidKeySize
    case couldNotCreateEcnumbasis(derivedError: LocalizedError? = nil)
    case couldNotDecodeEcnumbasis
    case invalidPeerDIDService
    case invalidBase64URLKey
    case invalidBase58Key
    case invalidMulticodec
    case invalidMaterialType(String)
    case invalidJWKMaterialType(KnownVerificationMaterialType)
    case unsupportedPeerDIDAlgo(String)
    case invalidPeerDIDString
}
