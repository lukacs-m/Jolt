//
//  JoltNetwork.swift
//  
//
//  Created by Martin Lukacs on 01/10/2021.
//

import Combine

// MARK: - Request actions
extension JoltNetwork {
    // MARK: - Get requests
    public func get<ReturnType>(_ path: String, parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let parameterType: RequestParameterType = parameters != nil ? .formURLEncoded : .none
        
        let requestConfigs = RequestConfigs(requestAction: .get,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeNonDecodableRequest(with: requestConfigs)
    }
    
    public func get<ReturnType: Decodable>(_ path: String, parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let parameterType: RequestParameterType = parameters != nil ? .formURLEncoded : .none
        
        let requestConfigs = RequestConfigs(requestAction: .get,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeDecodableRequest(with: requestConfigs)
    }
    
    // MARK: - Post requests
    public func post<ReturnType: Decodable>(_ path: String,
                                            parameterType: RequestParameterType = .json,
                                            parameters: Any? = nil,
                                            parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error> {
        
        let requestConfigs = RequestConfigs(requestAction: .post,
                                            path: path,
                                            parameterType: parts != nil ? .multipartFormData : parameterType,
                                            parameters: parameters,
                                            parts: parts)
        return executeDecodableRequest(with: requestConfigs)
    }
    
    public func post<ReturnType>(_ path: String,
                                 parameterType: RequestParameterType = .json,
                                 parameters: Any? = nil,
                                 parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error> {
        
        let requestConfigs = RequestConfigs(requestAction: .post,
                                            path: path,
                                            parameterType: parts != nil ? .multipartFormData : parameterType,
                                            parameters: parameters,
                                            parts: parts)
        return executeNonDecodableRequest(with: requestConfigs)
    }
    
    // MARK: - Patch
    public func patch<ReturnType: Decodable>(_ path: String,
                                             parameterType: RequestParameterType = .json,
                                             parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let requestConfigs = RequestConfigs(requestAction: .patch,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeDecodableRequest(with: requestConfigs)
    }
    
    public func patch<ReturnType>(_ path: String,
                                  parameterType: RequestParameterType = .json,
                                  parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let requestConfigs = RequestConfigs(requestAction: .patch,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeNonDecodableRequest(with: requestConfigs)
    }
    
    // MARK: - Put
    public func put<ReturnType: Decodable>(_ path: String,
                                           parameterType: RequestParameterType = .json,
                                           parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let requestConfigs = RequestConfigs(requestAction: .put,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeDecodableRequest(with: requestConfigs)
    }
    
    public func put<ReturnType>(_ path: String,
                                parameterType: RequestParameterType = .json,
                                parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let requestConfigs = RequestConfigs(requestAction: .put,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeNonDecodableRequest(with: requestConfigs)
    }
    
    // MARK: - Delete
    public func delete<ReturnType: Decodable>(_ path: String,
                                              parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let parameterType: RequestParameterType = parameters != nil ? .formURLEncoded : .none
        let requestConfigs = RequestConfigs(requestAction: .delete,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeDecodableRequest(with: requestConfigs)
    }
    
    public func delete<ReturnType>(_ path: String,
                                   parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let parameterType: RequestParameterType = parameters != nil ? .formURLEncoded : .none
        let requestConfigs = RequestConfigs(requestAction: .delete,
                                            path: path,
                                            parameterType: parameterType,
                                            parameters: parameters)
        return executeNonDecodableRequest(with: requestConfigs)
    }
}
