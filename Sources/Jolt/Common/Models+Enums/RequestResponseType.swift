//
//  File.swift
//  
//
//  Created by Martin Lukacs on 29/09/2021.
//

import Foundation

public enum RequestResponseType {
    case json
    case data
    
    public var accept: String? {
        switch self {
        case .json:
            return "application/json"
        default:
            return nil
        }
    }
}
