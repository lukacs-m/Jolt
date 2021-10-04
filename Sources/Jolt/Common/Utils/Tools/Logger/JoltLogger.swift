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
    func logError(parameterType: RequestParameterType?,
                  parameters: Any?,
                  data: Data?,
                  request: URLRequest?,
                  response: URLResponse?,
                  error: NSError?)
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
    
    public func logError(parameterType: RequestParameterType?,
                  parameters: Any? = nil,
                  data: Data?,
                  request: URLRequest?,
                  response: URLResponse?,
                  error: NSError?) {
        guard logLevel != .none else {
            return
        }
        
        guard let error = error else { return }
        var errorInfos = "========== Networking Error =========="

        print(start)

        let isCancelled = error.code == NSURLErrorCancelled
        if isCancelled {
            if let request = request, let url = request.url {
                errorInfos = errorInfos + "\r\nCancelled request: \(url.absoluteString)"
            }
        } else {
            errorInfos = errorInfos + "\r\n*** Request ***"
            + "\r\nError \(error.code): \(error.description)"

            if let request = request, let url = request.url {
                errorInfos = errorInfos + "\r\nURL: \(url.absoluteString)"
            }

            if let headers = request?.allHTTPHeaderFields {
                errorInfos = errorInfos + "\r\nHeaders: \(headers)"
            }

            if let parameterType = parameterType, let parameters = parameters {
                switch parameterType {
                case .json:
                    do {
                        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                        let string = String(data: data, encoding: .utf8)
                        if let string = string {
                            errorInfos = errorInfos + "\r\nParameters: \(string)"
                        }
                    } catch let error as NSError {
                        errorInfos = errorInfos + "\r\nFailed pretty printing parameters: \(parameters), error: \(error)"
                    }
                case .formURLEncoded:
                    guard let parametersDictionary = parameters as? [String: Any] else {
                        fatalError("Couldn't cast parameters as dictionary: \(parameters)")
                    }
                    do {
                        let formattedParameters = try parametersDictionary.urlEncodedString()
                        errorInfos = errorInfos + "\r\nParameters: \(formattedParameters)"
                    } catch let error as NSError {
                        errorInfos = errorInfos + "F\r\nailed parsing Parameters: \(parametersDictionary) — \(error)"
                    }
                default: break
                }
            }

            if let data = data, let stringData = String(data: data, encoding: .utf8) {
                errorInfos = errorInfos + "\r\nData: \(stringData)"
            }

            if let response = response as? HTTPURLResponse {
                errorInfos = errorInfos + "\r\n*** Response ***"
                + "\r\nHeaders: \(response.allHeaderFields)"
                + "\r\nStatus code: \(response.statusCode) — \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))"
            }
        }
        errorInfos = errorInfos + "\r\n================= ~ =================="
        Logger.joltNetworking.debug(errorInfos)
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
