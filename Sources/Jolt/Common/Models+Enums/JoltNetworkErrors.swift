//
//  File.swift
//  
//
//  Created by Martin Lukacs on 15/09/2021.
//

public enum JoltNetworkErrors: Error {
    case unableToComposeUrl
    case jsonParamSerialisation
    case nonValidParamDictionary
    case paramsEncodingError
    case mismatchErrorInReturnType
    case network(String)
    case decodeError(String)
    case genericError(String)
    
     public func getError(from error: Error) -> JoltNetworkErrors {
         guard let error = error as? JoltNetworkErrors else {
             return .genericError("An error Occured")
         }
        switch error {
        case .unableToComposeUrl:
            return .unableToComposeUrl
        default:
            return .genericError("An error Occured")
        }
    }
    
    public func getErrorDescription(from error: Error) -> String {
        guard let error = error as? JoltNetworkErrors else {
            return "An error Occured"
        }
       switch error {
       case .unableToComposeUrl:
           return "An error occured while creating the URL"
       case .jsonParamSerialisation:
           return "An error occured while serialiting the parameters"
       case .nonValidParamDictionary:
           return "The request parameters are not valid"
       case .paramsEncodingError:
           return "An error occured while encoding the parameters"
       case .mismatchErrorInReturnType:
           return "There was a mismatch with the return types"
       case .network(let errorDescription):
           return "An error occured during the network process. Error: \(errorDescription)"
       case .decodeError(let errorDescription):
           return "An error occured trying to decode the returned data. Error: \(errorDescription)"
       case .genericError(let errorDescription):
           return "An error occured. Error: \(errorDescription)"
       }
   }
}
