//
//  File.swift
//  
//
//  Created by Martin Lukacs on 26/09/2021.
//

import Foundation

public struct AuthentificationHeader {
    public let value: String
    public let key: String
    
    public init(with value: String,
                and key: String) {
        self.key = key
        self.value = value
    }
}
