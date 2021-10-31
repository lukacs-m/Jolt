//
//  NetworkSessionHeaderConfiguring.swift
//  
//
//  Created by Martin Lukacs on 26/09/2021.
//

public protocol NetworkSessionHeaderConfiguring {
    func setSessionHeader(with params: [String: String])
    func addParamInSessionHeader(with params: [String: String])
}
