//
//  addEmployee.swift
//  Candor
//
//  Created by mac on 01/08/25.
//

import Foundation

class addEmployeeVM{
    
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    
    func addEmployee(_ employee: AddEmployeeRequest){
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let url = URL(string: APIEndpoints.addEmployee) else {
                  onError?("Invalid URL or missing token")
                  return
              }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        do {
            let bodyData = try JSONEncoder().encode(employee)
            request.httpBody = bodyData
        } catch {
            onError?("Encoding failed: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.onError?("Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.onError?("No data received")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(AddEmployeeResponse.self, from: data)
                if response.success {
                    self.onSuccess?(response.message)
                } else {
                    self.onError?(response.message)
                }
            } catch {
                self.onError?("Failed to decode response: \(error.localizedDescription)")
            }
        }.resume()
        
        
    }
}
