//
//  UpdateInnerTaskDetailsVM.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

class UpdateInnerTaskDetailsVM {
    
    var onSuccess: ((UpdateInnerTaskResponse) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func updateTask(request: UpdateInnerTaskRequest) {
        print("🔹 [UpdateInnerTaskDetailsVM] updateTask() called")
        
        guard let url = URL(string: "\(APIEndpoints.UpdateInnerTasks)") else {
            print("❌ [UpdateInnerTaskDetailsVM] Invalid URL: \(APIEndpoints.UpdateInnerTasks)")
            return
        }
        
        print("✅ [UpdateInnerTaskDetailsVM] URL: \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // If using authentication token
        if let token = UserDefaults.standard.string(forKey: "token") {
            urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
            print("🔐 [UpdateInnerTaskDetailsVM] Token added to headers")
        } else {
            print("⚠️ [UpdateInnerTaskDetailsVM] No token found in UserDefaults")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 [UpdateInnerTaskDetailsVM] Request Body JSON: \(jsonString)")
            }
        } catch {
            print("❌ [UpdateInnerTaskDetailsVM] Error encoding request: \(error.localizedDescription)")
            onFailure?("Failed to encode request.")
            return
        }
        
        print("🌐 [UpdateInnerTaskDetailsVM] Sending PATCH request...")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("⬅️ [UpdateInnerTaskDetailsVM] Received response from server")
            
            if let error = error {
                print("❌ [UpdateInnerTaskDetailsVM] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onFailure?(error.localizedDescription)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [UpdateInnerTaskDetailsVM] HTTP Status Code: \(httpResponse.statusCode)")
                print("📋 [UpdateInnerTaskDetailsVM] Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            guard let data = data else {
                print("❌ [UpdateInnerTaskDetailsVM] No data received")
                DispatchQueue.main.async {
                    self.onFailure?("No data received")
                }
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📩 [UpdateInnerTaskDetailsVM] Raw Response: \(rawResponse)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(UpdateInnerTaskResponse.self, from: data)
                print("✅ [UpdateInnerTaskDetailsVM] Successfully decoded response: \(decodedResponse)")
                
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        print("🎉 [UpdateInnerTaskDetailsVM] Update successful")
                        self.onSuccess?(decodedResponse)
                    } else {
                        print("⚠️ [UpdateInnerTaskDetailsVM] Update failed: \(decodedResponse.message)")
                        self.onFailure?(decodedResponse.message)
                    }
                }
            } catch {
                print("❌ [UpdateInnerTaskDetailsVM] Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onFailure?("Failed to parse response")
                }
            }
            
        }.resume()
    }
}
