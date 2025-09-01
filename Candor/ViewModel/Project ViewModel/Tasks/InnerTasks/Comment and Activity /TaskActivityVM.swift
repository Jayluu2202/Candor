//
//  TaskActivityVM.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

class TaskActivityViewModel {

    var activities: [TaskActivity] = []
    var activitiesDict: [String: [TaskActivity]] = [:] // Expose this property
    
    func fetchTaskActivity(taskID: Int, token: String, completion: @escaping (Bool, String?) -> Void) {
        let urlString = "\(APIEndpoints.GetActivity)?task_id=\(taskID)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false, "Invalid URL")
            return
        }

        print("Fetching Task Activity from URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                DispatchQueue.main.async {
                    completion(false, "No data received")
                }
                return
            }

            do {
                print("Raw JSON Response: \(String(data: data, encoding: .utf8) ?? "N/A")")

                let decoder = JSONDecoder()
                let responseModel = try decoder.decode(TaskActivityResponse.self, from: data)
                
                print("Decoded Response: \(responseModel)")
                
                if responseModel.success {
                    // Store both the dictionary and flattened array
                    self.activitiesDict = responseModel.data
                    self.activities = responseModel.data.flatMap { $0.value }
                    
                    print("Total Activities: \(self.activities.count)")
                    print("Activity Sections: \(self.activitiesDict.keys.sorted())")

                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    print("API Response: \(responseModel.message)")
                    DispatchQueue.main.async {
                        completion(false, responseModel.message)
                    }
                }
            } catch {
                print("JSON Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }.resume()
    }
}
