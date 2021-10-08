//
//  File.swift
//  
//
//  Created by Martin Lukacs on 14/09/2021.
//

import Foundation

extension Data {
    func decodeToString(with encodingType: String.Encoding = .utf8) -> String {
        String(data: self, encoding: encodingType) ?? ""
    }
    
    static func multipartFormData(with paramConfig: RequestConfigs, and boundary: String) -> Data {
        var bodyData = Data()
        
        if let parameters = paramConfig.parameters as? [String: Any] {
            bodyData = parameters.buildBodyPart(boundary: boundary)
        }

        if let parts = paramConfig.parts {
            for var part in parts {
                part.boundary = boundary
                bodyData.append(part.formData)
            }
        }
        
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return bodyData
    }
}
