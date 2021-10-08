//
//  File.swift
//  
//
//  Created by Martin Lukacs on 29/09/2021.
//

import Foundation

extension String {
    func encodeUTF8() -> String? {
        if let _ = URL(string: self) {
            return self
        }
        
        var components = self.components(separatedBy: "/")
        guard let lastComponent = components.popLast(),
              let endcodedLastComponent =
                lastComponent.addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) else {
                  return nil
              }
        
        return (components + [endcodedLastComponent]).joined(separator: "/")
    }
    
    func urlEncoded(with params: String) -> String {
        let urlEncodedPath: String
        if self.contains("?") {
            if let lastCharacter = self.last, lastCharacter == "?" {
                urlEncodedPath = self + params
            } else {
                urlEncodedPath = self + "&" + params
            }
        } else {
            urlEncodedPath = self + "?" + params
        }
        return urlEncodedPath
    }
}
