//
//  File.swift
//  
//
//  Created by Martin Lukacs on 29/09/2021.
//

import Foundation
 
extension Dictionary where Key: ExpressibleByStringLiteral {
    
    /// Encodes the contents of the dictionary
    ///
    /// - Returns: Returns the parameters in using URL-enconding, for example ["username": "Michael", "age": 20] will become "username=Michael&age=20".
    /// - Throws: Returns an error if it wasn't able to encode the dictionary.
    func urlEncodedString() throws -> String {
        
        let pairs = try reduce([]) { current, keyValuePair -> [String] in
            if let encodedValue = "\(keyValuePair.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) {
                return current + ["\(keyValuePair.key)=\(encodedValue)"]
            } else {
                throw JoltNetworkErrors.genericError("Couldn't encode \(keyValuePair.value)")
            }
        }
        
        let converted = pairs.joined(separator: "&")
        
        return converted
    }
}
