//
//  Response.swift
//  TelegraphPrinter
//
//  Created by Airat K on 3/1/2023.
//

typealias Result = Page


class Response: Codable {
    
    var ok: Bool
    var error: String?
    var result: Result?
    
}
