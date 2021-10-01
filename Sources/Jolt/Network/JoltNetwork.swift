//
//  File.swift
//  
//
//  Created by Martin Lukacs on 14/09/2021.
//

import Foundation
import Combine

//public protocol NetworkSessionRequestsActions {
//    func get<AnyReturnType>(_ path: String, parameters: Any?) -> AnyPublisher<AnyReturnType, Error>
//    func get<ReturnType>(_ path: String, parameters: Any?) -> AnyPublisher<ReturnType, Error> where ReturnType: Decodable
//}

public class JoltNetwork: NSObject, URLSessionDelegate {
    private let baseURL: String
    private var timeout: TimeInterval?
    private let logger: JoltLogging
    private let sessionConfiguration: URLSessionConfiguration
    private var sessionHeader = [String: String]()
    private var session: URLSession!
    private var authHeader: AuthentificationHeader?
    let multipartBoundary = "Boundary-\(UUID().uuidString)"
    
    public init(baseURL: String, configuration: JoltNetworkConfigurationInitialising) {
        self.baseURL = baseURL
        self.logger = configuration.logger
        self.timeout = configuration.timeout
        self.sessionConfiguration = configuration.sessionConfiguration
        super.init()
        self.session = URLSession(configuration: sessionConfiguration,
                                  delegate: self, delegateQueue: nil)
    }
    
    public convenience init(baseURL: String) {
        self.init(baseURL: baseURL, configuration: JoltNetworkConfigurationInitializer.default)
    }
}

// MARK: - Session loggin configuration
extension JoltNetwork: LogConfiguring {
    /**
     Log network calls to the console and log console.
     Values Available are .None, debugInformative and debugVerbose.
     Default is None
     */
    public func setLogLevel(with logLevel: LogLevel) {
        logger.setLoggingLevel(with: logLevel)
    }
}

// MARK: - Session header configuration
extension JoltNetwork: NetworkSessionHeaderConfiguring {
    public func setSessionHeader(with params: [String: String]) {
        sessionHeader = params
    }
    
    public func addParamInSessionHeader(with params: [String: String]) {
        sessionHeader = sessionHeader.merging(params) { $1 }
    }
}

// MARK: - Session authentification configuration
extension JoltNetwork: NetworkSessionAuthentificationConfiguring {
    /// Authenticates using Basic Authentication, it converts username:password to Base64 then sets the Authorization header to "Basic \(Base64(username:password))".
    ///
    /// - Parameters:
    ///   - username: The username to be used.
    ///   - password: The password to be used.
    public func setAuthentificationHeader(username: String, password: String) {
        let credentialsString = "\(username):\(password)"
        if let credentialsData = credentialsString.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString(options: [])
            let authString = "Basic \(base64Credentials)"
            
            authHeader = AuthentificationHeader(with: authString, and: JoltConfigs.Keys.authentificationHeaderKey)
        }
    }
    
    /// Authenticates using a Bearer token, sets the Authorization header to "Bearer \(token)".
    ///
    /// - Parameter token: The token to be used.
    public func setAuthentificationHeader(token: String) {
        let authString = "Bearer \(token)"
        authHeader = AuthentificationHeader(with: authString, and: JoltConfigs.Keys.authentificationHeaderKey)
    }
    
    /// Authenticates using a custom HTTP Authorization header.
    ///
    /// - Parameters:
    ///   - headerKey: Sets this value as the key for the HTTP `Authorization` header
    ///   - headerValue: Sets this value to the HTTP `Authorization` header or to the `headerKey` if you provided that.
    public func setAuthorizationHeader(headerKey: String, headerValue: String) {
        authHeader = AuthentificationHeader(with: headerValue, and: headerKey)
    }
}


extension JoltNetwork {
    func executeDecodableRequest<ReturnType: Decodable>(_ action: HttpActions,
                                                        for path: String,
                                                        parameterType: RequestParameterType,
                                                        parameters: Any?,
                                                        parts: [FormDataPart]? = nil,
                                                        responseType: RequestResponseType) -> AnyPublisher<ReturnType, Error>  {
        let request: URLRequest
        do {
            request = try createRequest(action,
                                        path: path,
                                        parameterType: parameterType,
                                        parameters: parameters,
                                        parts: parts,
                                        responseType: responseType)
        } catch let error {
            return .isFailing(with: error)
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { (data: Data, response: URLResponse) -> Data in
                self.logger.log(response: response, and: data)
                if let httpURLResponse = response as? HTTPURLResponse,
                   !(200...299 ~= httpURLResponse.statusCode){
                    throw JoltNetworkErrors.network("\(httpURLResponse.statusCode)")
                }
                return data
            }
            .decode()
            .mapError { error -> JoltNetworkErrors in
                return JoltNetworkErrors.network(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func executeNonDecodableRequest<ReturnType>(_ action: HttpActions,
                                                for path: String,
                                                parameterType: RequestParameterType,
                                                parameters: Any?,
                                                parts: [FormDataPart]? = nil,
                                                responseType: RequestResponseType) -> AnyPublisher<ReturnType, Error>  {
        let request: URLRequest
        do {
            request = try createRequest(action,
                                        path: path,
                                        parameterType: parameterType,
                                        parameters: parameters,
                                        parts: parts,
                                        responseType: responseType)
        } catch let error {
            return .isFailing(with: error)
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { (data: Data, response: URLResponse) -> ReturnType in
                self.logger.log(response: response, and: data)
                if let httpURLResponse = response as? HTTPURLResponse,
                   !(200...299 ~= httpURLResponse.statusCode){
                    throw JoltNetworkErrors.network("\(httpURLResponse.statusCode)")
                }
                if ReturnType.self is Void.Type {
                    return Void() as! ReturnType
                } else if ReturnType.self is Data.Type {
                    return data as! ReturnType
                }
                guard let returnObject = try JSONSerialization.jsonObject(with: data, options: []) as? ReturnType else {
                    throw JoltNetworkErrors.mismatchErrorInReturnType
                }
                
                return returnObject
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Utils
private extension JoltNetwork {
    struct ParamConfigs {
        let requestAction: HttpActions
        let path: String
        let parameterType: RequestParameterType?
        let parameters: Any?
        var parts: [FormDataPart]? = nil
        let boundary = ""
    }
    
    func createRequest(_ requestAction: HttpActions,
                       path: String,
                       parameterType: RequestParameterType?,
                       parameters: Any?,
                       parts: [FormDataPart]? = nil,
                       responseType: RequestResponseType) throws -> URLRequest {
        guard let url = composedURL(with: path) else {
            throw JoltNetworkErrors.unableToComposeUrl
        }
        var request = URLRequest(url: url,
                                 requestAction: requestAction,
                                 parameterType: parameterType,
                                 responseType: responseType,
                                 boundary: multipartBoundary,
                                 authHeader: authHeader,
                                 headerFields: sessionHeader)
        do {
            let paramConfig = ParamConfigs(requestAction: requestAction,
                                           path: path,
                                           parameterType: parameterType,
                                           parameters: parameters,
                                           parts: parts)
            
            request = try addParams(to: request, with: paramConfig)
        } catch let error {
            throw error
        }
        return request
    }
    
    func addParams(to request: URLRequest,
                   with paramConfig: ParamConfigs) throws -> URLRequest {
        guard let  parameterType = paramConfig.parameterType else {
            return request
        }
        var updatedRequest = request
        switch parameterType {
        case .none: break
        case .json:
            if let parameters = paramConfig.parameters {
                do {
                    updatedRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch {
                    throw JoltNetworkErrors.jsonParamSerialisation
                }
            }
        case .formURLEncoded:
            guard let parametersDictionary = paramConfig.parameters as? [String: Any] else {
                throw JoltNetworkErrors.nonValidParamDictionary
            }
            do {
                let formattedParameters = try parametersDictionary.urlEncodedString()
                switch paramConfig.requestAction {
                case .get, .delete:
                    let urlEncodedPath: String
                    if paramConfig.path.contains("?") {
                        if let lastCharacter = paramConfig.path.last, lastCharacter == "?" {
                            urlEncodedPath = paramConfig.path + formattedParameters
                        } else {
                            urlEncodedPath = paramConfig.path + "&" + formattedParameters
                        }
                    } else {
                        urlEncodedPath = paramConfig.path + "?" + formattedParameters
                    }
                    updatedRequest.url = composedURL(with: urlEncodedPath)
                case .post, .put, .patch:
                    updatedRequest.httpBody = formattedParameters.data(using: .utf8)
                }
            } catch let error as NSError {
                print(error)
            }
        case .multipartFormData:
            var bodyData = Data()
            
            if let parameters = paramConfig.parameters as? [String: Any] {
                for (key, value) in parameters {
                    let usedValue: Any = value is NSNull ? "null" : value
                    var body = ""
                    body += "--\(multipartBoundary)\r\n"
                    body += "Content-Disposition: form-data; name=\"\(key)\""
                    body += "\r\n\r\n\(usedValue)\r\n"
                    bodyData.append(body.data(using: .utf8)!)
                }
            }
            
            if let parts = paramConfig.parts {
                for var part in parts {
                    part.boundary = multipartBoundary
                    bodyData.append(part.formData as Data)
                }
            }
            
            bodyData.append("--\(multipartBoundary)--\r\n".data(using: .utf8)!)
            updatedRequest.httpBody = bodyData as Data
        case .custom:
            updatedRequest.httpBody = paramConfig.parameters as? Data
        }
        
        return updatedRequest
    }
    
    /// Returns a URL by appending the provided path to the Networking's base URL.
    ///
    /// - Parameter path: The path to be appended to the base URL.
    /// - Returns: A URL generated after appending the path to the base URL.
    /// - Throws: An error if the URL couldn't be created.
    func composedURL(with path: String) -> URL? {
        let encodedPath = path.encodeUTF8() ?? path
        guard let url = URL(string: baseURL + encodedPath) else {
            return nil
        }
        return url
    }
}
