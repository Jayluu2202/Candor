//
//  getEmployeeInfo.swift
//  Candor
//
//  Created by mac on 05/08/25.
//

import Foundation

class SingleEmployeeInfoVM {
    
    var employeeData: SingleEmployeeData?
    var onFetchSuccess: (() -> Void)?
    var onFetchFailure: ((String) -> Void)?
    
    func fetchEmployeeDetails(userId: Int) {
        guard let url = URL(string: "\(APIEndpoints.getEmployeeInfo)?user_id=\(userId)") else {
            onFetchFailure?("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        } else {
            onFetchFailure?("❌ Token missing")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.onFetchFailure?("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.onFetchFailure?("❌ No data received")
                return
            }
            
            
            
            do {
                let decoded = try JSONDecoder().decode(SingleEmployeeResponse.self, from: data)
                if decoded.success, let emp = decoded.data {
                    self.employeeData = emp
                    DispatchQueue.main.async {
                        self.onFetchSuccess?()
                    }
                } else {
                    self.onFetchFailure?(decoded.message)
                }
            } catch {
                self.onFetchFailure?("❌ Parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

