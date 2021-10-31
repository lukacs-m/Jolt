//
//  JoltNetworkConfigurationInitialising.swift
//  
//
//  Created by Martin Lukacs on 14/09/2021.
//

import Foundation

public protocol JoltNetworkConfigurationInitialising {
    var logger: JoltLogging { get }
    var timeout: TimeInterval? { get }
    var sessionConfiguration: URLSessionConfiguration { get }
}
