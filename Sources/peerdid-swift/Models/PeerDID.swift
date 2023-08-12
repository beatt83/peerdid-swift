//
//  DID.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import Foundation

struct PeerDID {
    
    enum Algorithm: String {
        case _0 = "0"
        case _2 = "2"
        
        enum Algo2Prefix: String {
            case authentication = "V"
            case agreement = "E"
            case service = "S"
        }
    }
    
    let algo: Algorithm
    let schema: String = "did"
    let method: String = "peer"
    let methodId: String
    
    init(algo: Algorithm, methodId: String) {
        self.algo = algo
        self.methodId = methodId
    }
    
    init(didString: String) throws {
        let pattern = #"^did:peer:([0-9a-zA-Z])([0-9a-zA-Z]+)$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(
            in: didString,
            options: [],
            range: NSRange(location: 0, length: didString.count)
        )

        guard let match = matches?.first else {
            throw PeerDIDError.invalidPeerDIDString
        }

        let algoStr = (didString as NSString).substring(with: match.range(at: 1))
        let methodId = (didString as NSString).substring(with: match.range(at: 2))
        self.methodId = algoStr + methodId
        
        guard let algo = Algorithm(rawValue: algoStr) else {
            throw PeerDIDError.unsupportedPeerDIDAlgo(String(methodId.prefix(1)))
        }
        self.algo = algo
    }
    
    var string: String {
        "\(schema):\(method):\(methodId)"
    }
    
    var methodIdWithoutAlgo: String {
        String(methodId.dropFirst())
    }
    
    var allAttributes: [String] {
        methodIdWithoutAlgo.components(separatedBy: ".")
    }
    
    var algo2AuthenticationKeys: [String] {
        guard algo == ._2 else { return [] }
        return allAttributes
            .filter { $0.hasPrefix(Algorithm.Algo2Prefix.authentication.rawValue) }
            .map { String($0.dropFirst()) }
    }
    
    var algo2KeyAgreementKeys: [String] {
        guard algo == ._2 else { return [] }
        return allAttributes
            .filter { $0.hasPrefix(Algorithm.Algo2Prefix.agreement.rawValue) }
            .map { String($0.dropFirst()) }
    }
    
    var algo2Service: [String] {
        guard algo == ._2 else { return [] }
        return allAttributes
            .filter { $0.hasPrefix(Algorithm.Algo2Prefix.service.rawValue) }
            .map { String($0.dropFirst()) }
    }
}
