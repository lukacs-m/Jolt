//
//  File.swift
//  
//
//  Created by Martin Lukacs on 08/10/2021.
//

import Foundation

struct RequestConfigs {
    let requestAction: HttpActions
    let path: String
    let parameterType: RequestParameterType?
    let parameters: Any?
    var parts: [FormDataPart]? = nil
    var boundary = ""
    var responseType: RequestResponseType = .json
    
    func jsonSerializedParams() throws -> Data? {
        var data: Data?
        if let parameters = parameters {
            do {
                data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw JoltNetworkErrors.jsonParamSerialisation
            }
        }
        return data
    }
    
    func formURLEncodedSerializedParams() throws -> String {
        guard let parametersDictionary = parameters as? [String: Any] else {
            throw JoltNetworkErrors.nonValidParamDictionary
        }
        do {
            let formattedParameters = try parametersDictionary.urlEncodedString()
            return formattedParameters
        } catch let error {
            throw error
        }
    }
}
