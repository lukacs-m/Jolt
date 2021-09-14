//
//  File.swift
//  
//
//  Created by Martin Lukacs on 13/09/2021.
//

import Foundation

extension URLRequest {

    /**
     Returns a cURL command representation of this URL request.
     It comes from:  https://gist.github.com/shaps80/ba6a1e2d477af0383e8f19b87f53661d
     */
    public var curlString: String {
        guard let url = url else { return "" }
        #if swift(>=5.0)
          var baseCommand = #"curl "\#(url.absoluteString)""#
        #else
          var baseCommand = "curl \"\(url.absoluteString)\""
        #endif

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }

}
