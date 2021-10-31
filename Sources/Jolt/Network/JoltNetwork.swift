//
//  JoltNetwork.swift
//  
//
//  Created by Martin Lukacs on 14/09/2021.
//

import Foundation
import Combine

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

// MARK: - Session Settings

extension JoltNetwork: JoltNetworkSettings {
    public func setSessionRequestTimout(with timeout: TimeInterval) {
        self.timeout = timeout
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
    /// Authenticates using Basic Authentication,
    /// it converts username:password to Base64 then sets the Authorization header to "Basic \(Base64(username:password))".
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
    
    func executeDecodableRequest<ReturnType: Decodable>(with requestConfigs: RequestConfigs) -> AnyPublisher<ReturnType, Error> {
        do {
            let request = try createRequest(with: requestConfigs)
            return session.dataTaskPublisher(for: request)
                .logURLResponse(with: logger)
                .validateDataResponse()
                .logError(with: logger, request: request, and: requestConfigs)
                .decode()
                .mapError { error -> JoltNetworkErrors in
                    return JoltNetworkErrors.decodeError(error.localizedDescription)
                }
                .eraseToAnyPublisher()
        } catch let error {
            return .isFailing(with: error)
        }
    }
    
    func executeNonDecodableRequest<ReturnType>(with requestConfigs: RequestConfigs) -> AnyPublisher<ReturnType, Error> {
        do {
            let request = try createRequest(with: requestConfigs)
            return session.dataTaskPublisher(for: request)
                .logURLResponse(with: logger)
                .validateGenericResponse()
                .logError(with: logger, request: request, and: requestConfigs)
                .eraseToAnyPublisher()
        } catch let error {
            return .isFailing(with: error)
        }
    }
}

// MARK: - Utils
private extension JoltNetwork {
    
    func createRequest(with requestConfigs: RequestConfigs) throws -> URLRequest {
        guard let url = composedURL(with: requestConfigs.path) else {
            throw JoltNetworkErrors.unableToComposeUrl
        }
        var request = URLRequest(url: url,
                                 requestAction: requestConfigs.requestAction,
                                 parameterType: requestConfigs.parameterType,
                                 responseType: requestConfigs.responseType,
                                 boundary: multipartBoundary,
                                 authHeader: authHeader,
                                 headerFields: sessionHeader)
        
        if let timeout = timeout {
            request.timeoutInterval = timeout
        }
        
        do {
            request = try addParams(to: request, with: requestConfigs)
        } catch let error {
            throw error
        }
        return request
    }
    
    func addParams(to request: URLRequest,
                   with paramConfig: RequestConfigs) throws -> URLRequest {
        guard let parameterType = paramConfig.parameterType else {
            return request
        }
        var updatedRequest = request
        do {
            switch parameterType {
            case .none: break
            case .json:
                updatedRequest.httpBody = try paramConfig.jsonSerializedParams()
            case .formURLEncoded:
                let formattedParameters = try paramConfig.formURLEncodedSerializedParams()
                switch paramConfig.requestAction {
                case .get, .delete:
                    let urlEncodedPath = paramConfig.path.urlEncoded(with: formattedParameters)
                    updatedRequest.url = composedURL(with: urlEncodedPath)
                case .post, .put, .patch:
                    updatedRequest.httpBody = formattedParameters.data(using: .utf8)
                }
            case .multipartFormData:
                updatedRequest.httpBody = Data.multipartFormData(with: paramConfig, and: multipartBoundary)
            case .custom:
                updatedRequest.httpBody = paramConfig.parameters as? Data
            }
        } catch let error {
            throw error
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
