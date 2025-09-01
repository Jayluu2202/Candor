//
//  UpdateTaskVM.swift
//  Candor
//
//  Created by mac on 28/08/25.
//

import Foundation

class UpdateTaskVM {
    
    var onSuccess: ((String) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func updateTask(taskId: Int, assignedTo: Int?, priority: String?, statusId: Int?) {
        
        // ✅ Check API endpoint correctness
        guard let url = URL(string: APIEndpoints.updateTask) else {
            onFailure?("Invalid URL") // ❗ If this prints, verify APIEndpoints.updateTask
            return
        }
        
        // ✅ Check if token exists in UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onFailure?("No authentication token found") // ❗ If this prints, ensure token is saved after login
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH" // ✅ Ensure your API supports PATCH method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(token, forHTTPHeaderField: "Authorization") // ✅ Ensure token format matches API requirement (Bearer prefix?)
        
        // ✅ Build request body with only fields to update
        var requestBody: [String: Any] = [
            "task_id": String(taskId) // ❗ Check if API expects Int or String
        ]
        
        if let assignedTo = assignedTo {
            // ✅ Send integer if assignedTo exists
            requestBody["assigned_to"] = assignedTo
        } else {
            // ✅ Explicitly send null if assignedTo is nil
            requestBody["assigned_to"] = NSNull()
        }
        
        if let priority = priority {
            requestBody["priority"] = priority // ✅ Ensure API accepts this value (LOW, MEDIUM, HIGH?)
        }
        
        if let statusId = statusId {
            requestBody["status_id"] = String(statusId) // ❗ Check if API expects Int or String
        }
        
        // ✅ Encode body to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            urlRequest.httpBody = jsonData
            print("🔄 Updating task \(taskId) with: \(requestBody)") // ✅ Debug print before sending request
        } catch {
            onFailure?("Failed to encode request body") // ❗ Check if invalid data types are in requestBody
            return
        }
        
        // ✅ Start network request
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.onFailure?(error.localizedDescription) // ❗ Network error (no internet, timeout)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.onFailure?("Invalid response") // ❗ No proper HTTP response received
                }
                return
            }
            
            print("📡 Update Task Status Code: \(httpResponse.statusCode)") // ✅ Always check status code
            
            // ✅ Handle non-success status codes
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(data: data ?? Data(), encoding: .utf8) ?? "No server message"
                DispatchQueue.main.async {
                    self.onFailure?("Server error: \(httpResponse.statusCode) - \(serverMessage)") // ❗ Useful for debugging backend errors
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.onFailure?("No data received") // ❗ Response was empty
                }
                return
            }
            
            // ✅ Decode API response into model
            do {
                let responseModel = try JSONDecoder().decode(UpdateTaskResponse.self, from: data)
                DispatchQueue.main.async {
                    if responseModel.success {
                        self.onSuccess?(responseModel.message) // ✅ Success message from API
                    } else {
                        self.onFailure?("Update failed: \(responseModel.message)") // ❗ API returned success = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.onFailure?("Failed to decode response: \(error.localizedDescription)") // ❗ JSON structure mismatch
                }
            }
        }
        
        task.resume() // ✅ Start the request
    }
}
