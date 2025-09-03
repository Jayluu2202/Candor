//
//  GetUserAssetVM.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

class GetUserAssetVM {
    
    var asset: UserAssetData?
    var onSuccess: (() -> Void)?
    var onFailure: ((String) -> Void)?
    
    func fetchUserAsset(by assetId: Int) {
        guard let url = URL(string: "\(APIEndpoints.baseURL)/get-assets-by-id?assets_id=\(assetId)") else {
            onFailure?("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        } else {
            onFailure?("Token not found")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.onFailure?(error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.onFailure?("No data received")
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(UserAssetResponse.self, from: data)
                self?.asset = decodedResponse.data
                DispatchQueue.main.async {
                    self?.onSuccess?()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.onFailure?("Decoding error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
