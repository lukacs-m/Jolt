//
//  File.swift
//  
//
//  Created by Martin Lukacs on 15/09/2021.
//

enum JoltNetworkErrors: Error {
    case unableToComposeUrl
    case unableToParseRequest
    case jsonParamSerialisation
    case nonValidParamDictionary
    case mismatchErrorInReturnType
    case network(String)
    case genericError(String)
    
     func getError(from error: Error) -> JoltNetworkErrors {
         guard let error = error as? JoltNetworkErrors else {
             return .genericError("An error Occured")
         }
        switch error {
        case .unableToComposeUrl:
            return .unableToComposeUrl
        case .unableToParseRequest:
            return .unableToParseRequest
        default:
            return .genericError("An error Occured")
        }
    }
}
