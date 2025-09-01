//
//  dashboardVM.swift
//  Candor
//
//  Created by mac on 28/07/25.
//

import Foundation

class DashboardVM{
    
    var dashboardData : DashboardData?
    var onSucces : (() -> Void)?
    var onFailure : ((String) -> Void)?
    
    func fetchDashboardDetails(){
        guard let url = URL(string: APIEndpoints.dashboard) else {
            DispatchQueue.main.async {
                self.onFailure?("Invalid URL")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "token"){
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.onFailure?("Error: \(error.localizedDescription)")
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.onFailure?("No data received")
                }
                return
            }
            
            do{
                
                let result = try JSONDecoder().decode(DashboardResponse.self, from: data)
                if result.success, let data = result.data{
                    self.dashboardData = data
                    DispatchQueue.main.async {
                        self.onSucces?()
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.onFailure?(result.message)
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    self.onFailure?("Parsing Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
