//
//  editEmployeeVM.swift
//  Candor
//
//  Created by mac on 06/08/25.
//

import Foundation

class EditEmployeeVM {
    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?

    func editEmployee(_ requestModel: EditEmployeeRequest) {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            onError?("Missing token")
            return
        }

        guard let url = URL(string: APIEndpoints.editEmployee) else {
            onError?("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")

        var body = Data()

        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        appendFormField(name: "user_id", value: "\(requestModel.user_id)")
        appendFormField(name: "first_name", value: requestModel.first_name)
        appendFormField(name: "last_name", value: requestModel.last_name)
        if let password = requestModel.password {
            appendFormField(name: "password", value: password)
        }
        appendFormField(name: "birth_date", value: requestModel.birth_date)
        appendFormField(name: "contact_number", value: requestModel.contact_number)
        appendFormField(name: "emergency_contact_name", value: requestModel.emergency_contact_name)
        appendFormField(name: "emergency_contact_no", value: requestModel.emergency_contact_no)
        appendFormField(name: "address", value: requestModel.address)
        appendFormField(name: "department_id", value: "\(requestModel.department_id)")
        appendFormField(name: "joining_date", value: requestModel.joining_date)
        appendFormField(name: "role_id", value: "\(requestModel.role_id)")
        if let reportingID = requestModel.reporting_person_id {
            appendFormField(name: "reporting_person_id", value: "\(reportingID)")
        }
        if let technologyID = requestModel.technology_id {
            appendFormField(name: "technology_id", value: "\(technologyID)")
        }
        
        for branchID in requestModel.branch_ids {
            appendFormField(name: "branch_ids[]", value: "\(branchID)")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        // Call API
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.onError?("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                self.onError?("No data received")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(EditEmployeeResponse.self, from: data)
                if decoded.success {
                    self.onSuccess?(decoded.message)
                } else {
                    self.onError?(decoded.message)
                }
            } catch {
                self.onError?("Decoding error: \(error.localizedDescription)")
            }
            

        }.resume()
    }
}

