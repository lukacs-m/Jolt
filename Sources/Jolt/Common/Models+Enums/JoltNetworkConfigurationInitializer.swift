//
//  File.swift
//  
//
//  Created by Martin Lukacs on 14/09/2021.
//

import Foundation

public struct JoltNetworkConfigurationInitializer: JoltNetworkConfigurationInitialising {
    public let timeout: TimeInterval?
    public let logger: JoltLogging
    public let sessionConfiguration: URLSessionConfiguration

    public init(timeout: TimeInterval?,
                logger: JoltLogging,
                sessionConfiguration: URLSessionConfiguration) {
        self.logger = logger
        self.timeout = timeout
        self.sessionConfiguration = sessionConfiguration
    }

    public static var `default`: JoltNetworkConfigurationInitialising {
        return JoltNetworkConfigurationInitializer(
            timeout: nil,
            logger: JoltNetworkLogger(),
            sessionConfiguration: .default
        )
    }
}
