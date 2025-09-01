//
//  MembersVM.swift
//  Candor
//
//  Created by mac on 21/08/25.
//

import Foundation

class MembersVM {
    var onEmployeesFetched: (([EmployeeMember]) -> Void)?
    var onProjectMembersFetched: (([ProjectMember]) -> Void)?
    
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?

    // Get Employee List for Adding
    func getEmployeeList(projectId: Int) {
        print("Starting getEmployeeList for project: \(projectId)")
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("No token found")
            onError?("No authentication token found")
            return
        }
        
        guard let url = URL(string: "\(APIEndpoints.getEmployeeDropDown)?project_id=\(projectId)") else {
            print("Invalid URL: \(APIEndpoints.getEmployeeDropDown)?project_id=\(projectId)")
            onError?("Invalid URL")
            return
        }
        
        print("API URL: \(url)")
        print("Token: \(token.prefix(20))...")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("API Response received")
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                DispatchQueue.main.async {
                    self.onError?("Invalid response from server")
                }
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.onError?("No data received")
                }
                return
            }
            
            print("Data received: \(data.count) bytes")
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200:
                do {
                    let response = try JSONDecoder().decode(EmployeeListResponseMembers.self, from: data)
                    print("JSON Decoded successfully")
                    
                    if response.success {
                        // Print each employee for debugging
                        for (index, employee) in response.data.enumerated() {
                            let displayName = employee.name ?? "\(employee.firstName) \(employee.lastName)"
                            print("Employee \(index + 1): \(displayName) (ID: \(employee.id))")
                        }
                        
                        DispatchQueue.main.async {
                            self.onEmployeesFetched?(response.data)
                        }
                    } else {
                        print("API returned success: false - \(response.message)")
                        DispatchQueue.main.async {
                            self.onError?(response.message)
                        }
                    }
                } catch {
                    print("JSON Decode error: \(error)")
                    self.handleEmployeeDecodingError(error: error, data: data)
                }
            case 401:
                print("Authentication failed")
                DispatchQueue.main.async {
                    self.onError?("Authentication failed. Please log in again.")
                }
            case 403:
                print("Access forbidden")
                DispatchQueue.main.async {
                    self.onError?("You don't have permission to view employees for this project.")
                }
            case 404:
                print("Project or employees not found")
                DispatchQueue.main.async {
                    self.onError?("Project not found or no employees available.")
                }
            default:
                print("Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.onError?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    private func handleEmployeeDecodingError(error: Error, data: Data) {
        print("Handling employee decoding error")
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key not found: \(key), Context: \(context)")
            case .typeMismatch(let type, let context):
                print("Type mismatch: \(type), Context: \(context)")
            case .valueNotFound(let type, let context):
                print("Value not found: \(type), Context: \(context)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context)")
            @unknown default:
                print("Unknown decoding error")
            }
        }
        
        // Try alternative decoding approaches
        do {
            // Try to decode as a direct array
            let employees = try JSONDecoder().decode([EmployeeMember].self, from: data)
            print("Successfully decoded as direct array")
            DispatchQueue.main.async {
                self.onEmployeesFetched?(employees)
            }
        } catch {
            print("Alternative decoding also failed: \(error)")
            DispatchQueue.main.async {
                if data.isEmpty {
                    self.onEmployeesFetched?([]) // Return empty array for empty response
                } else {
                    self.onError?("Failed to parse employee data. The response format may have changed.")
                }
            }
        }
    }

    // Get Project Members
    func getProjectMembers(projectId: Int) {
        print("Starting getProjectMembers for project: \(projectId)")
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("No token found")
            onError?("No authentication token found")
            return
        }
        
        guard let url = URL(string: "\(APIEndpoints.getProjectMembers)?project_id=\(projectId)") else {
            print("Invalid URL: \(APIEndpoints.getProjectMembers)?project_id=\(projectId)")
            onError?("Invalid URL")
            return
        }
        
        print("API URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Project Members API Response received")
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                DispatchQueue.main.async {
                    self.onError?("Invalid response from server")
                }
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.onError?("No data received")
                }
                return
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200:
                do {
                    let response = try JSONDecoder().decode(ProjectMembersResponse.self, from: data)
                    print("Project Members JSON Decoded successfully")
                    print("Response success: \(response.success)")
                    print("Response message: \(response.message)")
                    print("Project Members count: \(response.data.count)")
                    
                    if response.success {
                        DispatchQueue.main.async {
                            self.onProjectMembersFetched?(response.data)
                        }
                    } else {
                        print("API returned success: false")
                        DispatchQueue.main.async {
                            self.onError?(response.message)
                        }
                    }
                } catch {
                    print("JSON Decode error: \(error)")
                    self.handleMembersDecodingError(error: error, data: data)
                }
            case 401:
                print("Authentication failed")
                DispatchQueue.main.async {
                    self.onError?("Authentication failed. Please log in again.")
                }
            case 403:
                print("Access forbidden")
                DispatchQueue.main.async {
                    self.onError?("You don't have permission to view members for this project.")
                }
            case 404:
                print("No members found - returning empty list")
                DispatchQueue.main.async {
                    self.onProjectMembersFetched?([]) // Return empty array for no members
                }
            default:
                print("Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.onError?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    private func handleMembersDecodingError(error: Error, data: Data) {
        print("Handling members decoding error")
        
        // Try alternative decoding approaches
        do {
            // Try to decode as a direct array
            let members = try JSONDecoder().decode([ProjectMember].self, from: data)
            print("Successfully decoded members as direct array")
            DispatchQueue.main.async {
                self.onProjectMembersFetched?(members)
            }
        } catch {
            print("Alternative members decoding also failed: \(error)")
            DispatchQueue.main.async {
                if data.isEmpty {
                    self.onProjectMembersFetched?([]) // Return empty array for empty response
                } else {
                    self.onError?("Failed to parse project members data. The response format may have changed.")
                }
            }
        }
    }

    // Add Project Member
    func addProjectMember(projectId: Int, userIds: [Int]) {
        print("Starting addProjectMember - Project: \(projectId), Users: \(userIds)")
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("No token found")
            onError?("No authentication token found")
            return
        }
        
        guard let url = URL(string: APIEndpoints.addMemberInProject) else {
            print("Invalid URL: \(APIEndpoints.addMemberInProject)")
            onError?("Invalid URL")
            return
        }
        
        print("API URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization") 
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "project_id": projectId,
            "user_ids": userIds
        ]
        
        print("Request Body: \(body)")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to serialize request body: \(error)")
            onError?("Failed to prepare request")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Add Member API Response received")
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                DispatchQueue.main.async {
                    self.onError?("Invalid response from server")
                }
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.onError?("No data received")
                }
                return
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print("Response parsed: \(responseDict ?? [:])")
                    
                    if let success = responseDict?["success"] as? Bool, success {
                        let message = responseDict?["message"] as? String ?? "Member added successfully"
                        print("Member added successfully: \(message)")
                        DispatchQueue.main.async {
                            self.onSuccess?(message)
                        }
                    } else {
                        let errorMessage = responseDict?["message"] as? String ?? "Failed to add member"
                        print("Failed to add member: \(errorMessage)")
                        DispatchQueue.main.async {
                            self.onError?(errorMessage)
                        }
                    }
                } catch {
                    print("JSON Parse error: \(error)")
                    // Assume success if status is 2xx but JSON parsing fails
                    DispatchQueue.main.async {
                        self.onSuccess?("Member added successfully")
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    self.onError?("Authentication failed. Please log in again.")
                }
            case 403:
                DispatchQueue.main.async {
                    self.onError?("You don't have permission to add members to this project.")
                }
            case 404:
                DispatchQueue.main.async {
                    self.onError?("Project or user not found.")
                }
            default:
                DispatchQueue.main.async {
                    self.onError?("Failed to add member (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }

    // Remove Project Member
    func removeProjectMember(projectId: Int, userId: Int) {
        print("Starting removeProjectMember - Project: \(projectId), User: \(userId)")
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("No token found")
            onError?("No authentication token found")
            return
        }
        
        guard let url = URL(string: APIEndpoints.removeMemberFromProject) else {
            print("Invalid URL: \(APIEndpoints.removeMemberFromProject)")
            onError?("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "project_id": projectId,
            "user_id": userId
        ]
        
        print("Request Body: \(body)")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to serialize request body: \(error)")
            onError?("Failed to prepare request")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Remove Member API Response received")
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?("Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                DispatchQueue.main.async {
                    self.onError?("Invalid response from server")
                }
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("No data received")
                // Some PATCH endpoints return no content on success
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    DispatchQueue.main.async {
                        self.onSuccess?("Member removed successfully")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.onError?("No data received from server")
                    }
                }
                return
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Remove Member Raw JSON Response: \(jsonString)")
            }

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let success = responseDict?["success"] as? Bool, success {
                        let message = responseDict?["message"] as? String ?? "Member removed successfully"
                        print("Member removed successfully: \(message)")
                        DispatchQueue.main.async {
                            self.onSuccess?(message)
                        }
                    } else {
                        let errorMessage = responseDict?["message"] as? String ?? "Failed to remove member"
                        print("Failed to remove member: \(errorMessage)")
                        DispatchQueue.main.async {
                            self.onError?(errorMessage)
                        }
                    }
                } catch {
                    print("JSON Parse error: \(error)")
                    // Assume success if status is 2xx but JSON parsing fails
                    DispatchQueue.main.async {
                        self.onSuccess?("Member removed successfully")
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    self.onError?("Authentication failed. Please log in again.")
                }
            case 403:
                DispatchQueue.main.async {
                    self.onError?("You don't have permission to remove members from this project.")
                }
            case 404:
                DispatchQueue.main.async {
                    self.onError?("Project or member not found.")
                }
            default:
                DispatchQueue.main.async {
                    self.onError?("Failed to remove member (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
}
