//
//  Page.swift
//  TelegraphPrinter
//
//  Created by Airat K on 3/1/2023.
//

class Page: Codable {
    
    var path: String
    var url: String
    var title: String
    var description: String
    var views: Int
    
    var authorName: String?
    var authorUrl: String?
    var imageUrl: String?
    var content: [NodeElement]?
    var canEdit: Bool?
    
}
