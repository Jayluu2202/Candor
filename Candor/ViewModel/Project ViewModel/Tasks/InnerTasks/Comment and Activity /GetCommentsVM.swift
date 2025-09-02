//
//  GetCommentsVM.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

class GetCommentsVM {
    
    var comments: [GetComment] = []
    var pageInformation: GetCommentsPageInformation?
    var onCommentsFetched: (() -> Void)?
    var onError: ((String) -> Void)?
    
    func fetchComments(taskId: Int, page: Int = 1, limit: Int = 10) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onError?("Invalid token")
            return
        }
        
        var urlComponents = URLComponents(string: APIEndpoints.GetComments)
        urlComponents?.queryItems = [
            URLQueryItem(name: "task_id", value: String(taskId)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = urlComponents?.url else {
            onError?("Invalid URL")
            return
        }
        
        print("🔵 API URL: \(url)")
        print("🔐 Token: \(token)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    let errorMessage = "Server returned status code: \(httpResponse.statusCode)"
                    print("❌ \(errorMessage)")
                    DispatchQueue.main.async {
                        self.onError?(errorMessage)
                    }
                    return
                }
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.onError?("No data received")
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw Comments Response: \(responseString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(GetCommentsResponse.self, from: data)
                print("✅ Comments API Success: \(decodedResponse.message)")
                print("📝 Found \(decodedResponse.data.pageData.count) comments")
                
                self.comments = decodedResponse.data.pageData
                self.pageInformation = decodedResponse.data.pageInformation
                
                DispatchQueue.main.async {
                    self.onCommentsFetched?()
                }
            } catch let decodingError {
                print("❌ Comments Decoding Error: \(decodingError)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Failed Response: \(responseString)")
                }
                DispatchQueue.main.async {
                    self.onError?("Failed to parse comments: \(decodingError.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    func loadMoreComments(taskId: Int, nextPage: Int, limit: Int = 10) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onError?("Invalid token")
            return
        }
        
        var urlComponents = URLComponents(string: APIEndpoints.GetComments)
        urlComponents?.queryItems = [
            URLQueryItem(name: "task_id", value: String(taskId)),
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = urlComponents?.url else {
            onError?("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.onError?("No data received")
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(GetCommentsResponse.self, from: data)
                
                // Append new comments to existing ones
                self.comments.append(contentsOf: decodedResponse.data.pageData)
                self.pageInformation = decodedResponse.data.pageInformation
                
                DispatchQueue.main.async {
                    self.onCommentsFetched?()
                }
            } catch let decodingError {
                DispatchQueue.main.async {
                    self.onError?("Failed to parse comments: \(decodingError.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
