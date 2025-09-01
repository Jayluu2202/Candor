//
//  EmployeeStatusVM.swift
//  Candor
//
//  Created by mac on 19/08/25.
//

import Foundation

class EmployeeStatusVM{
    
    var onStatusChangeSuccess : ((String) -> Void)?
    var onStatusChangeFailure : ((String) -> Void)?
    
    func statusChange(_ requestModel : EmployeeStatusRequest){
        guard let url = URL(string: APIEndpoints.changeEmployeeStatus) else{
            onStatusChangeFailure?("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        } else {
            onStatusChangeFailure?("Token Missing")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(requestModel)
            request.httpBody = jsonData
        } catch {
            onStatusChangeFailure?("Encoding Error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.onStatusChangeFailure?("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.onStatusChangeFailure?("No data received")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(EmployeeStatusResponse.self, from: data)
                if decoded.success {
                    self.onStatusChangeSuccess?(decoded.message)
                } else {
                    self.onStatusChangeFailure?(decoded.message)
                }
            } catch {
                self.onStatusChangeFailure?("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
}
