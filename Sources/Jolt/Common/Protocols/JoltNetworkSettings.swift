//
//  File.swift
//  
//
//  Created by Martin Lukacs on 01/11/2021.
//

import Foundation

public protocol JoltNetworkSettings {
    func setSessionRequestTimout(with timeout: TimeInterval)
}
