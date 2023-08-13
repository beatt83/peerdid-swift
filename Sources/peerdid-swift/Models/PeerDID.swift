//
//  DID.swift
//  
//
//  Created by Gonçalo Frade on 12/08/2023.
//

import Foundation

public struct PeerDID {
    
    public enum Algorithm: String {
        case _0 = "0"
        case _2 = "2"
        
        enum Algo2Prefix: String {
            case authentication = "V"
            case agreement = "E"
            case service = "S"
        }
    }
    
    public let algo: Algorithm
    public let schema: String = "did"
    public let method: String = "peer"
    public let methodId: String
    
    public init(algo: Algorithm, methodId: String) {
        self.algo = algo
        self.methodId = methodId
    }
    
    public init(didString: String) throws {
        var components = didString.components(separatedBy: ":")
        guard
            components.count >= 3,
            components.removeFirst() == "did", // removed schema and check if its did
            components.removeFirst() == "peer" // removed method and check if it is peer
        else { throw PeerDIDError.invalidPeerDIDString }
        
        let methodId = components.joined()
        let algoString = String(methodId.prefix(1))
        self.methodId = methodId
        
        guard let algo = Algorithm(rawValue: algoString) else {
            throw PeerDIDError.unsupportedPeerDIDAlgo(String(methodId.prefix(1)))
        }
        self.algo = algo
    }
    
    public var string: String {
        "\(schema):\(method):\(methodId)"
    }
    
    public var methodIdWithoutAlgo: String {
        String(methodId.dropFirst())
    }
    
    public var allAttributes: [String] {
        methodIdWithoutAlgo.components(separatedBy: ".")
    }
    
    public var algo2AuthenticationKeys: [String] {
        guard algo == ._2 else { return [] }
        return allAttributes
            .filter { $0.hasPrefix(Algorithm.Algo2Prefix.authentication.rawValue) }
            .map { String($0.dropFirst()) }
    }
    
    public var algo2KeyAgreementKeys: [String] {
        guard algo == ._2 else { return [] }
        return allAttributes
            .filter { $0.hasPrefix(Algorithm.Algo2Prefix.agreement.rawValue) }
            .map { String($0.dropFirst()) }
    }
    
    public var algo2Service: String? {
        guard algo == ._2 else { return nil }
        return allAttributes
            .filter { $0.hasPrefix(Algorithm.Algo2Prefix.service.rawValue) }
            .first.map { String($0.dropFirst()) }
    }
}
