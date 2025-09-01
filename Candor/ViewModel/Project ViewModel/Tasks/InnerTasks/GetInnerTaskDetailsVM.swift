//
//  GetInnerTaskDetailsVM.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

///get tasks
import Foundation

class GetInnerTaskDetailsVM {
    
    // MARK: - Callbacks
    var onSuccess: ((InnerTaskData) -> Void)?
    var onSuccessWithDetails: ((InnerTaskData, [InnerAssignedUser], [InnerTaskStatus]) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Fetch Task
    func getTask(taskId: Int) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No authentication token found")
            onError?("No authentication token found")
            return
        }
        
        let urlString = "\(APIEndpoints.GetInnerTasks)?task_id=\(taskId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            onError?("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        print("📡 Sending request to: \(urlString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                DispatchQueue.main.async {
                    self.onError?("Invalid response")
                }
                return
            }
            
            print("📡 Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.onError?("No data received")
                }
                return
            }
            
            // 🔍 DEBUG: Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔍 Raw JSON Response:")
                print(jsonString)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(GetInnerTaskResponse.self, from: data)
                print("✅ Decoding success")
                print("📄 Task Title: \(decodedResponse.data.taskData.title)")
                
                DispatchQueue.main.async {
                    // Call both callbacks if they exist
                    self.onSuccess?(decodedResponse.data.taskData)
                    self.onSuccessWithDetails?(
                        decodedResponse.data.taskData,
                        decodedResponse.data.assignedToUsers,
                        decodedResponse.data.taskStatus
                    )
                }
            } catch let DecodingError.dataCorrupted(context) {
                print("❌ Data corrupted: \(context)")
                DispatchQueue.main.async {
                    self.onError?("Data corrupted: \(context.debugDescription)")
                }
            } catch let DecodingError.keyNotFound(key, context) {
                print("❌ Key '\(key)' not found: \(context.debugDescription)")
                print("❌ codingPath: \(context.codingPath)")
                DispatchQueue.main.async {
                    self.onError?("Key '\(key)' not found: \(context.debugDescription)")
                }
            } catch let DecodingError.valueNotFound(value, context) {
                print("❌ Value '\(value)' not found: \(context.debugDescription)")
                print("❌ codingPath: \(context.codingPath)")
                DispatchQueue.main.async {
                    self.onError?("Value '\(value)' not found: \(context.debugDescription)")
                }
            } catch let DecodingError.typeMismatch(type, context) {
                print("❌ Type '\(type)' mismatch: \(context.debugDescription)")
                print("❌ codingPath: \(context.codingPath)")
                DispatchQueue.main.async {
                    self.onError?("Type '\(type)' mismatch: \(context.debugDescription)")
                }
            } catch {
                print("❌ JSON Decoding error: \(error.localizedDescription)")
                print("❌ Full error: \(error)")
                DispatchQueue.main.async {
                    self.onError?("Decoding error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
