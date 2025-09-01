//
//  projectsVM.swift
//  Candor
//
//  Created by mac on 28/07/25.
//

import Foundation

class ProjectsVM{
    var projects : [Project] = []
    var onDataFetched: (() -> Void)?
    var onError: ((String) -> Void)?
    
    func fetchProjects() {
        guard let url = URL(string: APIEndpoints.projectsList) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add token from UserDefaults
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.onError?("No authentication token found")
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.onError?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.onError?("Server error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }
            
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.onError?("No data received from server")
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ProjectResponse.self, from: data)
                if !decodedResponse.success {
                    DispatchQueue.main.async {
                        self.onError?(decodedResponse.message)
                    }
                    return
                }
                
                if let pageData = decodedResponse.data?.pageData {
                    self.projects = pageData
                    DispatchQueue.main.async {
                        self.onDataFetched?()
                    }
                } else {
                    self.projects = []
                    DispatchQueue.main.async {
                        self.onDataFetched?()
                    }
                }
            } catch {
                if let decodingError = error as? DecodingError {
                }
                DispatchQueue.main.async {
                    self.onError?("Failed to parse server response")
                }
            }
            
        }.resume()
    }
    
    func updateProjectStatus(projectID: String, status: String, completion: @escaping (Bool) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        guard let url = URL(string: APIEndpoints.updateProject) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"project_id\"\r\n\r\n")
        body.append("\(projectID)\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"status\"\r\n\r\n")
        body.append("\(status)\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        if let bodyString = String(data: body, encoding: .utf8) {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
            }

            do {
                let decodedResponse = try JSONDecoder().decode(UpdateProjectResponse.self, from: data)
                if decodedResponse.success {
                    if let index = self.projects.firstIndex(where: { "\($0.id)" == projectID }) {
                        // Create updated project with new status
                        let updatedProject = Project(
                            id: self.projects[index].id,
                            name: self.projects[index].name,
                            deadline: self.projects[index].deadline,
                            status: status,
                            startDate: self.projects[index].startDate,
                            createdAt: self.projects[index].createdAt,
                            user: self.projects[index].user
                        )
                        self.projects[index] = updatedProject
                    }
                    DispatchQueue.main.async {
                        completion(true)
                        self.onDataFetched?() // Refresh UI
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

    func deleteProject(with projectID: String, completion: @escaping (Bool) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
//    http://159.65.145.9:3000/api/v1/delete-project
        
//    http://159.65.145.9:3000/api/v1/delete-project?project_id=44
        let urlString = "\(APIEndpoints.deleteProject)?project_id=\(projectID)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"project_id\"\r\n\r\n")
        body.append("\(projectID)\r\n")
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        if let bodyString = String(data: body, encoding: .utf8) {
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(UpdateProjectResponse.self, from: data)
                if decodedResponse.success {
                    DispatchQueue.main.async {
                        completion(true)
                        self.onDataFetched?()
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }


}
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
