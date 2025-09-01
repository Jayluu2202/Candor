//
//  AddProjectTaskSectionNameVM.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import Foundation

class AddTaskStatusSectionVM {
    
    // MARK: - Callbacks
    var onSuccess: ((String) -> Void)?
    var onFailure: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Add Task Status
    func addTaskStatus(projectId: Int, title: String) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onFailure?("No authentication token found")
            print("❌ Debug: No token found in UserDefaults")
            return
        }
        
        let urlString = "\(APIEndpoints.AddProjectTaskSectionsName)"
        guard let url = URL(string: urlString) else {
            onFailure?("Invalid URL")
            print("❌ Debug: Invalid URL \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let requestBody = TaskStatusRequest(projectId: projectId, title: title)
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 Debug: Request Body -> \(jsonString)")
            }
        } catch {
            onFailure?("Failed to encode request body")
            print("❌ Debug: JSON Encoding failed - \(error.localizedDescription)")
            return
        }
        
        onLoading?(true)
        print("🌍 Debug: Sending request to \(urlString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            DispatchQueue.main.async {
                self?.onLoading?(false)
            }
            
            if let error = error {
                self?.onFailure?(error.localizedDescription)
                print("❌ Debug: Network Error - \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Debug: Status Code -> \(httpResponse.statusCode)")
                print("📡 Debug: Headers -> \(httpResponse.allHeaderFields)")
            }
            
            guard let data = data else {
                self?.onFailure?("No data received")
                print("❌ Debug: Response data is nil")
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("📥 Debug: Raw Response -> \(rawResponse)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TaskStatusResponse.self, from: data)
                
                if decodedResponse.success {
                    self?.onSuccess?(decodedResponse.message)
                    print("✅ Debug: Success -> \(decodedResponse.message)")
                } else {
                    self?.onFailure?(decodedResponse.message)
                    print("⚠️ Debug: Failure -> \(decodedResponse.message)")
                }
            } catch {
                self?.onFailure?("Failed to decode response")
                print("❌ Debug: JSON Decoding failed - \(error.localizedDescription)")
            }
            
        }.resume()
    }
}
