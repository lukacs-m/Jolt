//
//  File.swift
//  
//
//  Created by Martin Lukacs on 26/09/2021.
//

import Foundation

/// Sets the rules to serialize your parameters, also sets the `Content-Type` header.
///
/// - none: No Content-Type header
/// - json: Serializes your parameters using `JSONSerialization` and sets your `Content-Type` to `application/json`.
/// - formURLEncoded: Serializes your parameters using `Percent-encoding` and sets your `Content-Type` to `application/x-www-form-urlencoded`.
/// - multipartFormData: Serializes your parameters and parts as multipart and sets your `Content-Type` to `multipart/form-data`.
/// - custom: Sends your parameters as plain data, sets your `Content-Type` to the value inside `custom`.
public enum RequestParameterType {
    case none, json, formURLEncoded, multipartFormData, custom(String)

    func contentType(_ boundary: String) -> String? {
        switch self {
        case .none:
            return nil
        case .json:
            return "application/json"
        case .formURLEncoded:
            return "application/x-www-form-urlencoded"
        case .multipartFormData:
            return "multipart/form-data; boundary=\(boundary)"
        case let .custom(value):
            return value
        }
    }
}
