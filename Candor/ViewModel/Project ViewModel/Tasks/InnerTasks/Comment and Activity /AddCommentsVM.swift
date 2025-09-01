//
//  AddCommentsVM.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

class AddCommentsVM {
    
    var onSuccess: ((AddCommentResponse) -> Void)?
    var onError: ((String) -> Void)?
    
    func addComment(taskId: String,
                    message: String,
                    files: [URL],
                    mentionUsers: [[String: Any]],
                    completion: @escaping (Result<AddCommentResponse, Error>) -> Void) {
        
        guard let url = URL(string: "\(APIEndpoints.AddComments)") else {
            onError?("Invalid URL")
            return
        }
        
        print("📌 [DEBUG] API URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let token = UserDefaults.standard.string(forKey: "token") ?? ""
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add task_id
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"task_id\"\r\n\r\n")
        body.append("\(taskId)\r\n")
        
        // Add message
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"message\"\r\n\r\n")
        body.append("\(message)\r\n")
        
        // Add mention_users (convert to JSON string)
        if let jsonData = try? JSONSerialization.data(withJSONObject: mentionUsers, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"mention_users\"\r\n\r\n")
            body.append("\(jsonString)\r\n")
        }
        
        // Add files
        for fileURL in files {
            let filename = fileURL.lastPathComponent
            let mimetype = "image/jpeg" // or detect dynamically
            
            if let fileData = try? Data(contentsOf: fileURL) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
                body.append("Content-Type: \(mimetype)\r\n\r\n")
                body.append(fileData)
                body.append("\r\n")
            }
        }
        
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        // ✅ Debug headers
        print("📌 [DEBUG] HTTP Method: \(request.httpMethod ?? "")")
        print("📌 [DEBUG] Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // ✅ Debug body size
        print("📌 [DEBUG] Body Size: \(body.count) bytes")
        
        // ✅ (Optional) Print first 500 characters of the body (avoid large data printing)
        if let bodyPreview = String(data: body.prefix(500), encoding: .utf8) {
            print("📌 [DEBUG] Body Preview:\n\(bodyPreview)...")
        }
        
        // Perform request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            // ✅ Debug network response
            if let httpResponse = response as? HTTPURLResponse {
                print("📌 [DEBUG] Status Code: \(httpResponse.statusCode)")
                print("📌 [DEBUG] Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let error = error {
                print("❌ [DEBUG] Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.onError?(error.localizedDescription)
                }
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ [DEBUG] No data received from API")
                let noDataError = NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    self?.onError?("No data received")
                }
                completion(.failure(noDataError))
                return
            }
            
            // ✅ Debug raw response data as String
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📌 [DEBUG] Raw Response:\n\(rawResponse)")
            } else {
                print("⚠️ [DEBUG] Unable to convert response to string")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(AddCommentResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        print("✅ [DEBUG] Decoding Success: \(decodedResponse)")
                        self?.onSuccess?(decodedResponse)
                    } else {
                        print("⚠️ [DEBUG] API Returned Error: \(decodedResponse.message)")
                        self?.onError?(decodedResponse.message)
                    }
                }
                
                completion(.success(decodedResponse))
                
            } catch {
                print("❌ [DEBUG] JSON Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.onError?(error.localizedDescription)
                }
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
