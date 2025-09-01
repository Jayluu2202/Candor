//
//  EmployeePasswordVM.swift
//  Candor
//
//  Created by mac on 18/08/25.
//

import Foundation

class EmployeePasswordVM {
    
    var onPasswordUpdateSuccess: ((String) -> Void)?
    var onPasswordUpdateFailure: ((String) -> Void)?
    
    // MARK: - Case 1: Update password WITH current password (User Profile)
    func updatePasswordWithCurrent(currentPassword: String, newPassword: String, profileImage: Data?) {
        guard let url = URL(string: APIEndpoints.changeEmployeePassword) else {
            onPasswordUpdateFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onPasswordUpdateFailure?("No auth token found")
            return
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // current_password
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"current_password\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(currentPassword)\r\n".data(using: .utf8)!)
        
        // new_password
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"new_password\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(newPassword)\r\n".data(using: .utf8)!)
        
        // optional profile_image
        if let imageData = profileImage {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profile_image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        performRequest(request: request)
    }
    
    // MARK: - Case 2: Update password WITHOUT current password (Edit Employee)
    func updatePasswordWithoutCurrent(newPassword: String) {
        guard let url = URL(string: APIEndpoints.changeEmployeePassword) else {
            onPasswordUpdateFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onPasswordUpdateFailure?("No auth token found")
            return
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // only new_password
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"new_password\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(newPassword)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        performRequest(request: request)
    }
    
    // MARK: - Shared request execution
    private func performRequest(request: URLRequest) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.onPasswordUpdateFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.onPasswordUpdateFailure?("No data received")
                }
                return
            }
            
            
            
            do {
                let result = try JSONDecoder().decode(UpdatePassword.self, from: data)
                DispatchQueue.main.async {
                    if result.success {
                        self.onPasswordUpdateSuccess?(result.message)
                    } else {
                        self.onPasswordUpdateFailure?(result.message)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.onPasswordUpdateFailure?("Failed to decode response")
                }
            }
        }.resume()
    }
}

