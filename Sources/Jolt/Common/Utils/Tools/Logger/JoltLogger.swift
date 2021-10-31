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
    func logError(requestConfig: RequestLogInfos, error: Error?)
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
    
    public func logError(requestConfig: RequestLogInfos,
                  error: Error?) {
        guard logLevel == .debugVerbose else {
            return
        }
        
        guard let error = error else { return }
        var errorInfos = "========== Networking Error =========="
        
        let isCancelled = error._code == NSURLErrorCancelled
        if isCancelled {
            if let request = requestConfig.request, let url = request.url {
                errorInfos += "\r\nCancelled request: \(url.absoluteString)"
            }
        } else {
            errorInfos += "\r\n*** Request ***"
            + "\r\nError \(error._code): \(error.localizedDescription)"
            
            if let request = requestConfig.request, let url = request.url {
                errorInfos += "\r\nURL: \(url.absoluteString)"
            }
            
            if let headers = requestConfig.request?.allHTTPHeaderFields {
                errorInfos += "\r\nHeaders: \(headers)"
            }
            
            if let parameterType = requestConfig.parameterType, let parameters = requestConfig.parameters {
                switch parameterType {
                case .json:
                    do {
                        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                        let string = String(data: data, encoding: .utf8)
                        if let string = string {
                            errorInfos += "\r\nParameters: \(string)"
                        }
                    } catch let error as NSError {
                        errorInfos += "\r\nFailed pretty printing parameters: \(parameters), error: \(error)"
                    }
                case .formURLEncoded:
                    guard let parametersDictionary = parameters as? [String: Any] else {
                        fatalError("Couldn't cast parameters as dictionary: \(parameters)")
                    }
                    do {
                        let formattedParameters = try parametersDictionary.urlEncodedString()
                        errorInfos += "\r\nParameters: \(formattedParameters)"
                    } catch let error as NSError {
                        errorInfos += "F\r\nailed parsing Parameters: \(parametersDictionary) — \(error)"
                    }
                default: break
                }
            }
        }
        errorInfos += "\r\n================= ~ =================="
        Logger.joltNetworking.debug("\(errorInfos)")
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
