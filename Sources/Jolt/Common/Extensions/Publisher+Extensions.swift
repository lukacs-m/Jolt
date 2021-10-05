//
//  File.swift
//  
//
//  Created by Martin Lukacs on 15/09/2021.
//

import Foundation
import Combine

extension Publisher where Output == Data {
    /// Helper decode function that inferres the decoding type
    /// - Parameters:
    ///   - type: Type returned by the publisher. This type must conform to Decodable protocol.
    ///   - decoder: The Json Decoder to process the decoding
    /// - Returns: A publisher containing a value of the returnedType
    public func decode<ReturnType: Decodable>(as type: ReturnType.Type = ReturnType.self,
                                              using decoder: JSONDecoder = .init()) -> Publishers.Decode<Self, ReturnType, JSONDecoder> {
        decode(type: type, decoder: decoder)
    }
}
