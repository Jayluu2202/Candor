//
//  LoggedInUserVM.swift
//  Candor
//
//  Created by mac on 01/08/25.
//

import Foundation

class LoggedInUserVM {
    
    var onProfileFetchSuccess: ((LoggedInUserData) -> Void)?
    var onProfileFetchFailure: ((String) -> Void)?
    
    func fetchUserProfile() {
        guard let url = URL(string: APIEndpoints.loggedInUserProfile) else {
            onProfileFetchFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onProfileFetchFailure?("No auth token found")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.onProfileFetchFailure?("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                self.onProfileFetchFailure?("No data received")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
            }
            do {
                let result = try JSONDecoder().decode(LoggedInUserResponse.self, from: data)
                DispatchQueue.main.async {
                    self.onProfileFetchSuccess?(result.data)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onProfileFetchFailure?("Failed to decode: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
