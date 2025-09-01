//
//  ForgotPasswordVM.swift
//  Candor
//
//  Created by mac on 12/08/25.
//

import Foundation

class UserForgetPassword{
    
    var onPasswordUpdateSuccess: ((String) -> Void)?
    var onPasswordUpdateFailure: ((String) -> Void)?
    
    func updatePassword(userId : String, newPassword : String){
        guard let url = URL(string: APIEndpoints.forgotPassword) else{
            onPasswordUpdateFailure?("Invalid URL")
            return
        }
        
        let requestBody = UpdatePasswordRequest(user_id : userId, password: newPassword)
        guard let jsonData = try? JSONEncoder().encode(requestBody) else{
            onPasswordUpdateFailure?("Invalid request body")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                self.onPasswordUpdateFailure?("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.onPasswordUpdateFailure?("No response data")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(UpdatePasswordResponse.self, from: data)
                if decodedResponse.success {
                    self.onPasswordUpdateSuccess?(decodedResponse.message)
                    
                } else {
                    self.onPasswordUpdateFailure?(decodedResponse.message)
                }
            } catch {
                self.onPasswordUpdateFailure?("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
