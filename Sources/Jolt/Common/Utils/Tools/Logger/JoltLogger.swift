//
//  File.swift
//  
//
//  Created by Martin Lukacs on 13/09/2021.
//

import OSLog

public protocol JoltLogging {
    func log(request: URLRequest)
    func log(response: URLResponse, and data: Data?)
    func setLoggingLevel(with level: LogLevel)
}

public final class JoltNetworkLogger: JoltLogging {
    private var logLevel = LogLevel.none
    
    public func log(request: URLRequest) {
        guard logLevel != .none else {
            return
        }
        
        logRequest(for: request)
        logCurl(for: request)
    }
    
    public func log(response: URLResponse, and data: Data?) {
        guard logLevel != .none else {
            return
        }
        
        logResponse(for: response)
        logData(for: data)
    }
    
    public func setLoggingLevel(with level: LogLevel) {
        logLevel = level
    }
}

// MARK: - Utils
private extension JoltNetworkLogger {
    func logCurl(for urlRequest: URLRequest) {
        guard logLevel == .debugVerbose else {
            return
        }
        Logger.joltNetworking.debug("\(urlRequest.curlString)")
    }
    
    func logRequest(for urlRequest: URLRequest) {
        if let httpAction = urlRequest.httpMethod,
           let url = urlRequest.url {
            Logger.joltNetworking.debug("Request action: \(httpAction), to url: \(url.absoluteString)")
        }
        
        if let headerFields = urlRequest.allHTTPHeaderFields {
            let fields = headerFields.map{ "\($0.key) : \($0.value)" }.joined(separator: " \\\n\t")
            Logger.joltNetworking.debug("Header Fields are: \(fields)")
        }
        
        if let requestBody = urlRequest.httpBody {
            Logger.joltNetworking.debug("Request body: \(requestBody.decodeToString())")
        }
    }
    
    func logResponse(for response: URLResponse) {
        guard let urlResponse = response as? HTTPURLResponse,
              let url = urlResponse.url else {
            return
        }
        
        Logger.joltNetworking.debug("Response status code: \(urlResponse.statusCode) for url: \(url.absoluteString)")
        
    }
    
    func logData(for data: Data?) {
        guard let data = data, logLevel == .debugVerbose else {
            return
        }
        Logger.joltNetworking.debug("Response data: \(data.decodeToString())")
    }
}
