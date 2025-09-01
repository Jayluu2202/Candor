//
//  addProject.swift
//  Candor
//
//  Created by mac on 29/07/25.
//

import Foundation
import UIKit

class addProjectVM{
    var onProjectAdded : ((String) -> Void)?
    var onError : ((String) -> Void)?
    
    func addNewProject(name: String, startDate: String, deadline: String){
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let url = URL(string: APIEndpoints.addProject) else{
                  onError?("Invalid token or URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let body = ProjectRequest(name: name, start_date: startDate, deadline: deadline)
        
        do{
            let encodedBody = try JSONEncoder().encode(body)
            request.httpBody = encodedBody
        }catch{
            onError?("Encoding error: \(error.localizedDescription)")
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
            do{
                let result = try JSONDecoder().decode(BasicResponse.self, from: data)
                if result.success{
                    self.onProjectAdded?(result.message)
                }else{
                    self.onError?(result.message)
                }
            }catch{
                self.onError?("Failed to decode response: \(error.localizedDescription)")
            }
        }.resume()
        
        
    }
    
    
    
}
