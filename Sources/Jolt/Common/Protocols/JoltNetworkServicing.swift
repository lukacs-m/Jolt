//
//  File.swift
//  
//
//  Created by Martin Lukacs on 14/09/2021.
//

import Foundation
import Combine

public protocol JoltNetworkServicing {
    var joltNetworkClient: JoltNetwork { get }
}

// MARK: - Helper functions that just forward calls to underlying network client
public extension JoltNetworkServicing {
    func get<ReturnType: Decodable>(_ path: String, parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.get(path, parameters: parameters)
    }
    
    func get<ReturnType>(_ path: String, parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.get(path, parameters: parameters)
    }
    
    func post<ReturnType: Decodable>(_ path: String,
                                     parameterType: RequestParameterType = .json,
                                     parameters: Any? = nil,
                                     parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.post(path, parameterType: parameterType, parameters: parameters, parts: parts)
    }
    
    func post<ReturnType>(_ path: String,
                                     parameterType: RequestParameterType = .json,
                                     parameters: Any? = nil,
                                     parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.post(path, parameterType: parameterType, parameters: parameters, parts: parts)
    }

}
