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

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func validateDataResponse() -> Publishers.TryMap<Self, Data> {
        tryMap { element -> Data in
            guard let httpResponse = element.response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode
            else {
                throw JoltNetworkErrors.network("\((element.response as? HTTPURLResponse)?.statusCode ?? -42)")
            }
            return element.data
        }
    }
    
    func validateGenericResponse<ReturnType>() -> Publishers.TryMap<Self, ReturnType> {
        tryMap { element -> ReturnType in
            guard let httpResponse = element.response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode
            else {
                throw JoltNetworkErrors.network("\((element.response as? HTTPURLResponse)?.statusCode ?? -42)")
            }
            if ReturnType.self is Void.Type {
                return Void() as! ReturnType
            } else if ReturnType.self is Data.Type {
                return element.data as! ReturnType
            }
            guard let returnObject = try JSONSerialization.jsonObject(with: element.data, options: []) as? ReturnType else {
                throw JoltNetworkErrors.mismatchErrorInReturnType
            }
            
            return returnObject
        }
    }
    
    func logURLResponse(with logger: JoltLogging) -> Publishers.Map<Self, URLSession.DataTaskPublisher.Output> {
        map { element -> URLSession.DataTaskPublisher.Output in
            logger.log(response: element.response, and: element.data)
            return element
        }
    }
}

extension Publisher {
    func logError(with logger: JoltLogging, request: URLRequest, and requestConfig: RequestConfigs)
    -> Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                let requestInfos = RequestLogInfos(parameterType: requestConfig.parameterType,
                                                   parameters: requestConfig.parameters,
                                                   request: request)
                logger.logError(requestConfig: requestInfos, error: error)
            case .finished:
                break
            }
        })
    }
}
