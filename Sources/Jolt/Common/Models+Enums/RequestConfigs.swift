//
//  File.swift
//  
//
//  Created by Martin Lukacs on 08/10/2021.
//

struct RequestConfigs {
    let requestAction: HttpActions
    let path: String
    let parameterType: RequestParameterType?
    let parameters: Any?
    var parts: [FormDataPart]? = nil
    var boundary = ""
    var responseType: RequestResponseType = .json
}
