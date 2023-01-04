//
//  TelegraphService.swift
//  TelegraphPrinter
//
//  Created by Airat K on 3/1/2023.
//

import Foundation


class TelegraphService {
    
    public let telegraphUrl = "https://telegra.ph/"
    
    private let telegraphApiUrl = "https://api.telegra.ph/"
    private let accessToken = {
        guard
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let accessToken = keys["TELEGRAPH_ACCESS_TOKEN"] as? String
        else { return "" }
        
        return accessToken
    }()
    private let jsonDecoder = {
        let jsonDecoder = JSONDecoder()
        
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return jsonDecoder
    }()
    
    
    func createPage(title: String, content: [[String: Any]],
            _ completion: @escaping (Page?, String?) -> Void) {
        let apiMethod = "createPage"
        let urlString = self.makeEndpoint(fromApiMethod: apiMethod)
        
        guard let url = URL(string: urlString) else {
            completion(nil, "Неверная ссылка запроса:\n\n\(urlString)")
            return
        }
        
        let request = self.makePostRequest(fromUrl: url)
        let payload = self.makePayload(fromDictionary: [
            "access_token": self.accessToken,
            "title": title,
            "content": String(data: try! JSONSerialization.data(withJSONObject: content), encoding: .utf8)!,
            "return_content": "true"
        ])
        
        URLSession.shared.uploadTask(with: request, from: payload) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async { completion(nil, error.localizedDescription) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(nil, "Телеграф ответил кодом \((response as! HTTPURLResponse).statusCode) и пустым блоком данных") }
                return
            }
            
            guard let response = try? self.jsonDecoder.decode(Response.self, from: data) else {
                DispatchQueue.main.async { completion(nil, "Не удалось обработать ответ Телеграфа") }
                return
            }
            
            let isFloodLimitExceeded = response.error?.starts(with: "FLOOD_WAIT_") ?? false
            
            guard response.ok || isFloodLimitExceeded else {
                DispatchQueue.main.async { completion(nil, response.error) }
                return
            }
            
            guard !isFloodLimitExceeded else {
                let waitSeconds = Double(response.error!.replacingOccurrences(of: "FLOOD_WAIT_", with: ""))!
                
                DispatchQueue.main.asyncAfter(deadline: .now() + waitSeconds) {
                    self.createPage(title: title, content: content, completion)
                }
                return
            }
            
            DispatchQueue.main.async { completion(response.result, nil) }
        } .resume()
    }
    
    
    private func makeEndpoint(fromApiMethod apiMethod: String) -> String {
        return self.telegraphApiUrl + apiMethod
    }
    
    private func makePostRequest(fromUrl url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        return request
    }
    
    private func makePayload(fromDictionary dictionary: [String: String]) -> Data? {
        var urlComponents = URLComponents()
        
        urlComponents.queryItems = dictionary.compactMap { URLQueryItem(name: $0, value: $1) }
        
        return urlComponents.percentEncodedQuery?.data(using: .utf8)
    }
    
}
