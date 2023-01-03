//
//  Node.swift
//  TelegraphPrinter
//
//  Created by Airat K on 3/1/2023.
//

enum Tag: String, Codable {
    
    case a
    case aside
    case b
    case blockquote
    case br
    case code
    case em
    case figcaption
    case figure
    case h3
    case h4
    case hr
    case i
    case iframe
    case img
    case li
    case ol
    case p
    case pre
    case s
    case strong
    case u
    case ul
    case video
    
}

enum Attribute: String, Codable {
    
    case href
    case src
    
}


class NodeElement: Codable {
    
    var tag: String
    
    var attrs: [Attribute: String]?
    var children: [String]?
    
}


enum Node: Codable {
    
    case string(String)
    case nodeElement(NodeElement)
    
}
