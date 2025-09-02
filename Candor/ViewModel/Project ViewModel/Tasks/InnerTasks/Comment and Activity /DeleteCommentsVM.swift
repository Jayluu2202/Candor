//
//  DeleteCommentsVM.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

class DeleteCommentsVM {

    // MARK: - Properties
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Delete Comment API Call
    func deleteComment(commentId: Int) {
        
        var urlComponents = URLComponents(string: APIEndpoints.DeleteComments)
        urlComponents?.queryItems = [
            URLQueryItem(name: "comment_id", value: String(commentId))
        ]
        
        guard let url = urlComponents?.url else {
            onError?("Invalid URL")
            return
        }
        
        print("🔵 DELETE URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.addValue(token, forHTTPHeaderField: "Authorization")
            print("🔐 Authorization token added")
        }
        
        // API Call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
                return
            }
            
            // Check HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Status Code: \(httpResponse.statusCode)")
                
                // Handle different status codes
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        self.onError?("Comment not found or already deleted")
                    }
                    return
                } else if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.onError?("Server error: \(httpResponse.statusCode)")
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
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw Response: \(responseString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(DeleteCommentResponse.self, from: data)
                print("✅ Decoded Response: Success=\(decodedResponse.success), Message=\(decodedResponse.message)")
                
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        self.onSuccess?(decodedResponse.message)
                    } else {
                        self.onError?(decodedResponse.message)
                    }
                }
            } catch let decodingError {
                print("❌ Decoding Error: \(decodingError.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?("Failed to decode response: \(decodingError.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
