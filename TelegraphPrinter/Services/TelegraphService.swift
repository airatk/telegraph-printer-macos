//
//  TelegraphService.swift
//  TelegraphPrinter
//
//  Created by Airat K on 3/1/2023.
//

import Foundation


class TelegraphService {
    
    private var accessToken: String = "c7bc0dbc804c2d4ee36baeb85df9175328e3c422cf0224181d33ad18434d"
    private var telegraphUrl: String = "https://api.telegra.ph/"
    
    
    public func createPage(title: String, content: [String], _ completion: @escaping (Page?, String?) -> Void) {
        let apiMethod: String = "createPage"
        let parameters: String = "?" + [
            "access_token": self.accessToken,
            "title": title,
            "content": String(data: try! JSONSerialization.data(withJSONObject: content), encoding: .utf8)!,
            "return_content": true
        ].map {
            "\($0.key)=\($0.value)"
        } .joined(separator: "&")
        let urlString: String = self.telegraphUrl + apiMethod + parameters
        
        guard let url = URL(string: urlString) else {
            completion(nil, "Неверная ссылка запроса:\n\(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil,
                  (200...299) ~= response.statusCode else {
                DispatchQueue.main.async { completion(nil, "Telegraph не отвечает, причина не известна") }
                return
            }
            
            guard let page = try? JSONDecoder().decode(Page.self, from: data) else {
                DispatchQueue.main.async { completion(nil, "Не удалось обработать полученные данные") }
                return
            }
            
            DispatchQueue.main.async { completion(page, nil) }
        } .resume()
    }
    
}
