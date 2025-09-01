//
//  UpdateProjectsVM.swift
//  Candor
//

import Foundation

class UpdateProjectsVM {

    var onProjectUpdated: ((String) -> Void)?

    func updateProject(with request: UpdateProjectRequest) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }

        guard let url = URL(string: APIEndpoints.updateProject) else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"

        let boundary = "Boundary-\(UUID().uuidString)"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")

        urlRequest.httpBody = createFormDataBody(request: request, boundary: boundary)

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                return
            }

            guard let data = data else {
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(UpdateProjectResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        self.onProjectUpdated?(decodedResponse.message)
                    } else {
                    }
                }
            } catch {
                if let raw = String(data: data, encoding: .utf8) {
                }
            }
        }.resume()
    }

    private func createFormDataBody(request: UpdateProjectRequest, boundary: String) -> Data {
        var body = Data()

        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        appendField("project_id", request.projectId)
        appendField("name", request.name)
        appendField("type", request.type)
        appendField("rate", request.rate)
        appendField("deadline", request.deadline!)
        appendField("estimated_budget", request.estimatedBudget)
        appendField("estimated_hours", request.estimatedHours)
        appendField("client_id", request.clientId)
        appendField("status", request.status)
        appendField("start_date", request.startDate)

        for techId in request.technologyIds {
            appendField("technology_ids[]", techId)
        }

        body.append("--\(boundary)--\r\n")
        return body
    }
}
