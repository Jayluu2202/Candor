//
//  loginFile.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import Foundation

class UserLoginFile{
    
    var onLoginSuccess: ((UserData) -> Void)?
    var onLoginFailure: ((String) -> Void)?
    
    func login(email: String, password: String){
        guard let url = URL(string: APIEndpoints.login) else{
            onLoginFailure!("Try Again")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body : [String:Any] = [
            "email": email,
            "password": password
        ]
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
        }catch{
            onLoginFailure!("falied to encode body request")
            return
        }
        
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                self.onLoginFailure?("Network error \(error.localizedDescription)")
                return
            }
            
            guard let data = data else{
                self.onLoginFailure?("No Data Recieved")
                return
            }
            
            do{
                let result = try JSONDecoder().decode(LoginResponse.self, from: data)
                if result.success, let userData = result.data {
                    
                    UserDefaults.standard.set(userData.token, forKey: "token")
                    UserDefaults.standard.set(userData.role?.name, forKey: "userRole")
                    
                    let savedToken = UserDefaults.standard.string(forKey: "token") ?? "Nothing"
                    let savedRole = UserDefaults.standard.string(forKey: "userRole") ?? "N/A"
                    
                    self.onLoginSuccess?(userData)
                } else {
                    self.onLoginFailure?(result.message)
                }
            }catch{
                self.onLoginFailure?("Failed to decode response: \(error.localizedDescription)")
            }
            
        }.resume()
        
    }
    
}
