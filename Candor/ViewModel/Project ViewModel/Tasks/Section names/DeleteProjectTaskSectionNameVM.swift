//
//  DeleteProjectTaskSectionNameVM.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import Foundation

class DeleteTaskStatusSectionVM {
    
    // MARK: - Callbacks
    var onSuccess: ((String) -> Void)?
    var onFailure: ((String) -> Void)?
    
    // MARK: - API Call
    func deleteTaskStatus(taskStatusId: Int) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No authentication token found")
            onFailure?("No authentication token found")
            return
        }
        
        let urlString = "\(APIEndpoints.DeleteProjectTaskSectionsName)?task_status_id=\(taskStatusId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            onFailure?("Invalid URL")
            return
        }
        
        print("📡 DELETE request to: \(urlString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error: \(error.localizedDescription)")
                self.onFailure?("Request error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                self.onFailure?("Invalid response")
                return
            }
            
            print("📡 Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                self.onFailure?("No data received")
                return
            }
            
            print("🔍 Raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            do {
                let decodedResponse = try JSONDecoder().decode(DeleteTaskStatusResponse.self, from: data)
                if decodedResponse.success {
                    print("✅ Success: \(decodedResponse.message)")
                    self.onSuccess?(decodedResponse.message)
                } else {
                    print("⚠️ Failure: \(decodedResponse.message)")
                    self.onFailure?(decodedResponse.message)
                }
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
                self.onFailure?("Decoding error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
