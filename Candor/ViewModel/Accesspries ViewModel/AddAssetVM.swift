//
//  AddAssetVM.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

class AddAssetVM {
    
    var onSuccess: ((String) -> Void)?
    var onFailure: ((String) -> Void)?
    
    func addAsset(asset: AddAssetRequest) {
        guard let url = URL(string: APIEndpoints.baseURL) else {
            onFailure?("Invalid URL")
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "token"){
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }else{
            DispatchQueue.main.async {
                self.onFailure?("No authentication token found")
            }
            return
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
                self?.onFailure?("Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self?.onFailure?("No data received")
                return
            }
            
            do {
                let responseModel = try JSONDecoder().decode(AddAssetResponse.self, from: data)
                if responseModel.success {
                    self?.onSuccess?(responseModel.message)
                } else {
                    self?.onFailure?(responseModel.message)
                }
            } catch {
                self?.onFailure?("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
