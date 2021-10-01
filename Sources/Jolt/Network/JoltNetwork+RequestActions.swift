//
//  File.swift
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
        
        return executeNonDecodableRequest(.get,
                                          for: path,
                                          parameterType: parameterType,
                                          parameters: parameters,
                                          responseType: .json)
    }
    
    public func get<ReturnType: Decodable>(_ path: String, parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let parameterType: RequestParameterType = parameters != nil ? .formURLEncoded : .none
        
        return executeDecodableRequest(.get,
                                       for: path,
                                       parameterType: parameterType,
                                       parameters: parameters,
                                       responseType: .json)
    }
    
    // MARK: - Post requests
    public func post<ReturnType: Decodable>(_ path: String,
                                            parameterType: RequestParameterType = .json,
                                            parameters: Any? = nil,
                                            parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error> {
        
        return executeDecodableRequest(.post,
                                       for: path,
                                       parameterType: parts != nil ? .multipartFormData : parameterType,
                                       parameters: parameters,
                                       parts: parts,
                                       responseType: .json)
    }
    
    public func post<ReturnType>(_ path: String,
                                 parameterType: RequestParameterType = .json,
                                 parameters: Any? = nil,
                                 parts: [FormDataPart]? = nil) -> AnyPublisher<ReturnType, Error>  {
        
        return executeNonDecodableRequest(.post,
                                          for: path,
                                          parameterType: parts != nil ? .multipartFormData : parameterType,
                                          parameters: parameters,
                                          parts: parts,
                                          responseType: .json)
    }
    
//    func post<ReturnType: Decodable>(_ path: String,
//                                     parameters: Any? = nil,
//                                     parts: [FormDataPart]) -> AnyPublisher<ReturnType, Error> {
//        return executeDecodableRequest(.post,
//                                       for: path,
//                                       parameterType: .multipartFormData,
//                                       parameters: parameters,
//                                       parts: parts,
//                                       responseType: .json)
//    }
//
//    func post<ReturnType>(_ path: String,
//                          parameters: Any? = nil,
//                          parts: [FormDataPart]) -> AnyPublisher<ReturnType, Error> {
//        return executeNonDecodableRequest(.post,
//                                          for: path,
//                                          parameterType: .multipartFormData,
//                                          parameters: parameters,
//                                          parts: parts,
//                                          responseType: .json)
//    }
    
    // MARK: - Patch
    public func patch<ReturnType: Decodable>(_ path: String,
                                             parameterType: RequestParameterType = .json,
                                             parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        return executeDecodableRequest(.patch,
                                       for: path,
                                       parameterType: parameterType,
                                       parameters: parameters,
                                       responseType: .json)
    }
    
    public func patch<ReturnType>(_ path: String,
                                  parameterType: RequestParameterType = .json,
                                  parameters: Any? = nil) -> AnyPublisher<ReturnType, Error>  {
        
        return executeNonDecodableRequest(.patch,
                                          for: path,
                                          parameterType: parameterType,
                                          parameters: parameters,
                                          responseType: .json)
    }
    
    
    // MARK: - Put
    
    public func put<ReturnType: Decodable>(_ path: String,
                                             parameterType: RequestParameterType = .json,
                                             parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        return executeDecodableRequest(.put,
                                       for: path,
                                       parameterType: parameterType,
                                       parameters: parameters,
                                       responseType: .json)
    }
    

    public func put<ReturnType>(_ path: String,
                                  parameterType: RequestParameterType = .json,
                                  parameters: Any? = nil) -> AnyPublisher<ReturnType, Error>  {
        
        return executeNonDecodableRequest(.put,
                                          for: path,
                                          parameterType: parameterType,
                                          parameters: parameters,
                                          responseType: .json)
    }
 
    // MARK: - Delete
    public func delete<ReturnType: Decodable>(_ path: String,
                                             parameters: Any? = nil) -> AnyPublisher<ReturnType, Error> {
        let parameterType: RequestParameterType = parameters != nil ? .formURLEncoded : .none

        return executeDecodableRequest(.delete,
                                       for: path,
                                       parameterType: parameterType,
                                       parameters: parameters,
                                       responseType: .json)
    }
    

    public func delete<ReturnType>(_ path: String,
                                  parameters: Any? = nil) -> AnyPublisher<ReturnType, Error>  {
        let parameterType: RequestParameterType = parameters != nil ? .formURLEncoded : .none

        return executeNonDecodableRequest(.delete,
                                          for: path,
                                          parameterType: parameterType,
                                          parameters: parameters,
                                          responseType: .json)
    }
}
