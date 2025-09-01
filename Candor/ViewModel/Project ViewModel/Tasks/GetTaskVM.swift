//
//  GetTaskVM.swift
//  Candor
//
//  Created by mac on 25/08/25.
//

import Foundation

class GetTaskVM {
    var tasks : [ProjectTask] = []
    var onSuccess: (([ProjectTask]) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func getTasks(projectId: Int, assignedTo: Int?, priority: String?) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onFailure?("No authentication token found")
            return
        }
        
        let urlString = "\(APIEndpoints.getTasksInTable)?project_id=\(projectId)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.onFailure?("Error in the url")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.onFailure?("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.onFailure?("Invalid response")
                return
            }
            print("📡 Status Code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(data: data ?? Data(), encoding: .utf8) ?? "No server message"
                print("❌ Server Error: \(serverMessage)")
                self.onFailure?("Server error: \(httpResponse.statusCode) - \(serverMessage)")
                return
            }
            
            guard let data = data else {
                self.onFailure?("No data received")
                return
            }
            print("🔍 Raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            do {
                let decoder = JSONDecoder()
                // Removed keyDecodingStrategy since we're using exact JSON keys
                
                let response = try decoder.decode(GetTasksResponse.self, from: data)
                print("✅ Decoded response successfully")
                print("🔍 Number of tasks: \(response.data.count)")
                
                // Extract tasks from page_data
                DispatchQueue.main.async {
                    self.onSuccess?(response.data)
                }
            } catch {
                let raw = String(data: data, encoding: .utf8) ?? "nil"
                print("❌ Decoding error: \(error.localizedDescription)")
                print("🔍 Error details: \(error)")
                print("Raw response: \(raw)")
                self.onFailure?("Error decoding tasks: \(error.localizedDescription)")
            }
        }.resume()
    }
}
