//
//  EmployeeListFile.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import Foundation



class EmployeeListVM{
    
    var employees: [Employee] = []
    var totalEmployees: Int = 0
    var onSuccess: (() -> Void)?
    var onFailure: ((String) -> Void)?
    
    func fetchEmployees() {
        guard let url = URL(string: APIEndpoints.employeesList) else {
            onFailure?("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "token"){
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }else{
            onFailure?("Missing token")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.onFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.onFailure?("No data received")
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(EmployeeResponse.self, from: data)
                if result.success, let container = result.data {
                    self.employees = container.page_data
                    self.totalEmployees = container.page_information.total_data
                    DispatchQueue.main.async {
                        self.onSuccess?()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.onFailure?(result.message)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.onFailure?("Parsing error: \(error.localizedDescription)")
                }
            }
            
        }.resume()
    }
    
}
