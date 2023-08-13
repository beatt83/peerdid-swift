//
//  Multicodec.swift
//  
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import Foundation

struct Multicodec {
    enum Codec: Int {
        case X25519 = 0xEC
        case ED25519 = 0xED
    }

    func toMulticodec(value: Data, keyType: VerificationMaterialType) -> Data {
        let prefix = getCodec(keyType: keyType).rawValue
        var data = Data(putUVarInt(UInt64(prefix)))
        data.append(value)
        return data
    }

    func fromMulticodec(value: Data) throws -> (codec: Codec, data: Data) {
        let (prefix, bytesRead) = uVarInt(Array(value))
        guard let codec = Codec(rawValue: Int(prefix)) else {
            throw PeerDIDError.invalidMulticodec
        }
        return (codec, value.dropFirst(bytesRead))
    }

    private func getCodec(keyType: VerificationMaterialType) -> Codec {
        switch keyType {
        case .authentication:
            return .ED25519
        case .agreement:
            return .X25519
        }
    }

    private func getCodec(prefix: Int) -> Codec? {
        return Codec(rawValue: prefix)
    }
}
