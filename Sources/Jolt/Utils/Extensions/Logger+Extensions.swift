//
//  File.swift
//  
//
//  Created by Martin Lukacs on 14/09/2021.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the networking calls.
    static let joltNetworking = Logger(subsystem: subsystem, category: "joltNetworking")
}

