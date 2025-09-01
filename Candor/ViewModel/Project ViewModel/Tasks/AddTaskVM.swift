//
//  AddTaskVM.swift
//  Candor
//
//  Created by mac on 26/08/25.
//

import Foundation

class AddTaskVM {
    
    // MARK: - Callbacks
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - API Call
    func createTask(request: AddTaskRequest) {
        
        guard let token = UserDefaults.standard.string(forKey: "token"),
              let url = URL(string: APIEndpoints.createTaskInTable) else{
                  onError?("Invalid token or URL")
            return
        }
        
        // Encode request model into JSON
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        do {
            let bodyData = try JSONEncoder().encode(request)
            urlRequest.httpBody = bodyData
        } catch {
            onError?("Failed to encode request")
            return
        }
        
        onLoading?(true)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.onLoading?(false)
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.onError?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.onError?("No response data")
                }
                return
            }
            
            do {
                let responseModel = try JSONDecoder().decode(AddTaskResponse.self, from: data)
                DispatchQueue.main.async {
                    if responseModel.success {
                        self?.onSuccess?(responseModel.message)
                    } else {
                        self?.onError?(responseModel.message)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.onError?("Decoding error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
}
