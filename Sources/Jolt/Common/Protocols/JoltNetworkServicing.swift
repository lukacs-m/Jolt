//
//  JoltNetworkServicing.swift
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
    
    // MARK: - Decodable return type
    func get<ReturnType: Decodable>(_ path: String, parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.get(path, parameters: parameters)
    }
    
    func post<ReturnType: Decodable>(_ path: String,
                                     parameterType: RequestParameterType = .json,
                                     parameters: Any? = nil,
                                     parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.post(path, parameterType: parameterType, parameters: parameters, parts: parts)
    }
    
    func patch<ReturnType: Decodable>(_ path: String,
                                      parameterType: RequestParameterType = .json,
                                      parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.patch(path, parameterType: parameterType, parameters: parameters)
    }
    
    func put<ReturnType: Decodable>(_ path: String,
                                    parameterType: RequestParameterType = .json,
                                    parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.put(path, parameterType: parameterType, parameters: parameters)
    }
    
    func delete<ReturnType: Decodable>(_ path: String,
                                       parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.delete(path, parameters: parameters)
    }
    
    // MARK: - Any return type
    func get<ReturnType>(_ path: String, parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.get(path, parameters: parameters)
    }
    
    func post<ReturnType>(_ path: String,
                          parameterType: RequestParameterType = .json,
                          parameters: Any? = nil,
                          parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.post(path, parameterType: parameterType, parameters: parameters, parts: parts)
    }
   
    func patch<ReturnType>(_ path: String,
                           parameterType: RequestParameterType = .json,
                           parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.patch(path, parameterType: parameterType, parameters: parameters)
    }
    
    func put<ReturnType>(_ path: String,
                         parameterType: RequestParameterType = .json,
                         parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.put(path, parameterType: parameterType, parameters: parameters)
    }
    
    func delete<ReturnType>(_ path: String,
                            parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        joltNetworkClient.delete(path, parameters: parameters)
    }
}
