//
//  UpdateAssetVM.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

class UpdateAssetVM {
    
    var onSuccess: ((String) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func updateAsset(asset: UpdateAssetRequest) {
        guard let url = URL(string: APIEndpoints.baseURL) else {
            onFailure?("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"   // Since you’re updating
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // If using Bearer token authentication
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(asset)
            request.httpBody = jsonData
        } catch {
            onFailure?("Encoding error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.onFailure?("Request error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.onFailure?("No response data")
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(UpdateAssetResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        self?.onSuccess?(decodedResponse.message)
                    } else {
                        self?.onFailure?(decodedResponse.message)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.onFailure?("Decoding error: \(error.localizedDescription)")
                }
            }
            
        }.resume()
    }
}
