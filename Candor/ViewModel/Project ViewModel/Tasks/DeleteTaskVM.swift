//
//  DeleteTaskVM.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import Foundation

class DeleteTaskVM {
    
    // MARK: - Callbacks
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Delete Task Function
    func deleteTask(taskId: Int) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found in UserDefaults")
            onError?("Authentication token missing")
            return
        }
        
        let urlString = "\(APIEndpoints.deleteTask)?task_id=\(taskId)"
        print("🌐 Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            onError?("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        print("📡 Sending DELETE request for taskId: \(taskId)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.onError?(error.localizedDescription) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📩 Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async { self.onError?("No data received") }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(DeleteTaskResponse.self, from: data)
                print("✅ Decoded Response: \(decodedResponse)")
                
                if decodedResponse.success {
                    DispatchQueue.main.async { self.onSuccess?(decodedResponse.message) }
                } else {
                    DispatchQueue.main.async { self.onError?(decodedResponse.message) }
                }
            } catch {
                print("❌ Decoding Error: \(error)")
                DispatchQueue.main.async { self.onError?("Failed to parse response") }
            }
        }.resume()
    }
}
