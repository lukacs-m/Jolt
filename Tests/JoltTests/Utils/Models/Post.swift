//
//  File.swift
//  
//
//  Created by Martin Lukacs on 29/09/2021.
//

import Foundation

struct Post: Decodable {
    let identifier: Int
    let userId: Int
    let title: String
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userId
        case title
        case body
    }
}
