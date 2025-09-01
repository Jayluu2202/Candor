//
//  GetProjectTaskSectionNameVM.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import Foundation

class GetProjectTaskSectionNameVM{
    
    var onSuccess: (([TaskSection]) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func getSections(projectId: Int){
        guard let token = UserDefaults.standard.string(forKey: "token") else{
            onFailure?("No authentication token found")
            return
        }
     
        let urlString = "\(APIEndpoints.GetProjectTaskSectionsName)?project_id=\(projectId)"
        guard let url = URL(string: urlString) else{
            DispatchQueue.main.async {
                self.onFailure?("Error in the url")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                self.onFailure?("Error: \(error.localizedDescription)")
                return
            }
            guard let httpresponse = response as? HTTPURLResponse else{
                self.onFailure?("Invalid Response")
                return
            }
            print("Status Code: \(httpresponse.statusCode)")
            
            if !(200...299).contains(httpresponse.statusCode) {
                let serverMessage = String(data: data ?? Data(), encoding: .utf8) ?? "No server message"
                print("❌ Server Error: \(serverMessage)")
                self.onFailure?("Server error: \(httpresponse.statusCode) - \(serverMessage)")
                return
            }
            guard let data = data else {
                self.onFailure?("No data received")
                return
            }
            print("🔍 Raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            do{
                let decoder = JSONDecoder()
                let response = try decoder.decode(TaskSectionResponse.self, from: data)
                self.onSuccess?(response.data)
                
            }catch{
                let raw = String(data: data, encoding: .utf8) ?? "nil"
                self.onFailure?("Error decoding sections:- \(error.localizedDescription)")
            }
        }.resume()
    }
}
