//
//  AddSubTasksVM.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

class AddSubTasksVM {
    
    var onSuccess: ((AddSubTaskResponse) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func addSubTask(request: AddSubTaskRequest) {
        // ✅ Debug: API Call started
        print("🔍 [DEBUG] Starting API call to add sub-task...")
        
        guard let url = URL(string: "\(APIEndpoints.CreateSubTasks)") else {
            print("❌ [DEBUG] Invalid URL.")
            onFailure?("Invalid URL")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = UserDefaults.standard.string(forKey: "token") {
                urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
                print("🔍 [DEBUG] Authorization token added.")
            }
            
            urlRequest.httpBody = jsonData
            
            print("📤 [DEBUG] Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                
                if let error = error {
                    print("❌ [DEBUG] Network error: \(error.localizedDescription)")
                    self.onFailure?("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ [DEBUG] Invalid response object.")
                    self.onFailure?("Invalid response")
                    return
                }
                
                print("🔍 [DEBUG] HTTP Status Code: \(httpResponse.statusCode)")
                
                guard let data = data else {
                    print("❌ [DEBUG] No data received from API.")
                    self.onFailure?("No data received")
                    return
                }
                
                print("📥 [DEBUG] Raw Response: \(String(data: data, encoding: .utf8) ?? "")")
                
                do {
                    let decodedResponse = try JSONDecoder().decode(AddSubTaskResponse.self, from: data)
                    
                    if decodedResponse.success {
                        print("✅ [DEBUG] Task added successfully: \(decodedResponse)")
                        DispatchQueue.main.async {
                            self.onSuccess?(decodedResponse)
                        }
                    } else {
                        print("⚠️ [DEBUG] API returned failure: \(decodedResponse.message)")
                        DispatchQueue.main.async {
                            self.onFailure?(decodedResponse.message)
                        }
                    }
                    
                } catch {
                    print("❌ [DEBUG] JSON Decoding error: \(error.localizedDescription)")
                    self.onFailure?("Decoding error: \(error.localizedDescription)")
                }
            }
            
            task.resume()
            
        } catch {
            print("❌ [DEBUG] Encoding request failed: \(error.localizedDescription)")
            onFailure?("Encoding request failed")
        }
    }
}
