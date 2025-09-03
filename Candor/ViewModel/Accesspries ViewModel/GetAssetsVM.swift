//
//  GetAssetsVM.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

class GetAssetsVM{
    
    var assets: [Asset] = []
    var onSuccess: (() -> Void)?
    var onFailure: ((String) -> Void)?
    
    func fetchAssets(){
        guard let url = URL(string: APIEndpoints.baseURL) else{
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "token"){
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }else{
            DispatchQueue.main.async {
                self.onFailure?("No authentication token found")
            }
            return
        }
        
        URLSession.shared.dataTask(with: request){data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.onFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.onFailure?("Server error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.onFailure?("No data receiverd from server")
                }
                return
            }
            
            do{
                let decodedResponse = try JSONDecoder().decode(GetAssetsResponse.self, from: data)
                if !decodedResponse.success{
                    DispatchQueue.main.async {
                        self.onFailure?(decodedResponse.message)
                    }
                    return
                }
                
                self.assets = decodedResponse.data.pageData
                print("📦 Assets fetched: \(self.assets.count)")
                
                DispatchQueue.main.async {
                    self.onSuccess?()
                }
                
            }catch{
                print("❌ Decoding error: \(error.localizedDescription)")
                if let rawJSON = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON response: \(rawJSON)")
                }
                DispatchQueue.main.async {
                    self.onFailure?("Failed to parse server response")
                }
            }
            
        }.resume()
    }
}
