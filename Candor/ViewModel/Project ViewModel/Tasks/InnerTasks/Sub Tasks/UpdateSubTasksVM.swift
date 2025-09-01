//
//  UpdateSubTasksVM.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

class UpdateSubTasksVM {
    
    var onSuccess: ((String) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func updateSubTask(request: UpdateSubTaskRequest) {
        
        guard let url = URL(string: APIEndpoints.UpdateSubTasks) else {
            print("❌ [DEBUG] Invalid URL")
            onFailure?("Invalid URL")
            return
        }
        
        print("\n🌐 [DEBUG] API Request Started")
        print("➡️ URL: \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH" // or "PUT" based on API
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            print("🔐 [DEBUG] Authorization Token: \(token)")
        } else {
            print("⚠️ [DEBUG] No token found in UserDefaults")
        }
        
        // ✅ Debug Headers
        print("📦 [DEBUG] Request Headers:")
        if let headers = urlRequest.allHTTPHeaderFields {
            for (key, value) in headers {
                print("   \(key): \(value)")
            }
        }
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            // ✅ Debug Request Body
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📝 [DEBUG] Request JSON Body: \(jsonString)")
            }
            
        } catch {
            print("❌ [DEBUG] JSON Encoding Error: \(error.localizedDescription)")
            onFailure?("Failed to encode request")
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            print("\n📡 [DEBUG] API Response Received")
            
            // ✅ Debug Network Error
            if let error = error {
                print("❌ [DEBUG] Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            // ✅ Debug HTTP Response
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [DEBUG] HTTP Status Code: \(httpResponse.statusCode)")
                print("📦 [DEBUG] Response Headers:")
                for (key, value) in httpResponse.allHeaderFields {
                    print("   \(key): \(value)")
                }
            }
            
            // ✅ Debug Response Data
            guard let data = data else {
                print("❌ [DEBUG] No Data Received")
                DispatchQueue.main.async {
                    self.onFailure?("No response data")
                }
                return
            }
            
            // ✅ Raw Response String
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📥 [DEBUG] Raw Response: \(rawResponse)")
            }
            
            // ✅ Try Decoding
            do {
                let decodedResponse = try JSONDecoder().decode(UpdateSubTaskResponse.self, from: data)
                
                print("✅ [DEBUG] Decoded Response: \(decodedResponse)")
                
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        self.onSuccess?(decodedResponse.message)
                    } else {
                        self.onFailure?(decodedResponse.message)
                    }
                }
                
            } catch {
                print("❌ [DEBUG] JSON Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onFailure?("Failed to decode response")
                }
            }
        }
        
        task.resume()
    }
}
