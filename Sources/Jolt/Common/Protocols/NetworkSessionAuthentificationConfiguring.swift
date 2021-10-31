//
//  NetworkSessionAuthentificationConfiguring.swift
//  
//
//  Created by Martin Lukacs on 26/09/2021.
//

public protocol NetworkSessionAuthentificationConfiguring {
    func setAuthentificationHeader(username: String, password: String)
    func setAuthentificationHeader(token: String)
    func setAuthorizationHeader(headerKey: String, headerValue: String)
}
