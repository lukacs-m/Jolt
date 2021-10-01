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
}
