//
//  DocumentVM.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import Foundation

class DocumentVM {
    var documentUploadSuccess: ((String) -> Void)?
    var documentUploadFailure: ((String) -> Void)?
    
    var onDocumentsFetchedSuccess: ((DocumentResponseData) -> Void)?
    var onDocumentsFetchedFailure: ((String) -> Void)?
    
    func uploadDocument(projectId: Int, name: String, documentData: Data, fileName: String, mimeType: String) {
        print("📤 Starting document upload for project: \(projectId)")
        
        guard let url = URL(string: APIEndpoints.uploadProjectDocument) else {
            print("❌ Invalid URL: \(APIEndpoints.uploadProjectDocument)")
            documentUploadFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found")
            documentUploadFailure?("Invalid Token")
            return
        }
        
        print("🌐 Upload URL: \(url)")
        print("📝 File name: \(fileName), Size: \(documentData.count) bytes")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 60 // Increased timeout for file uploads
        
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add project_id field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"project_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(projectId)\r\n".data(using: .utf8)!)
        
        // Add name field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)
        
        // Add document file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"document\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(documentData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("📥 Upload response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    if error.localizedDescription.contains("timeout") {
                        self.documentUploadFailure?("Upload timeout. Please check your connection and try again.")
                    } else {
                        self.documentUploadFailure?("Network error: \(error.localizedDescription)")
                    }
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Invalid response from server")
                }
                return
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.documentUploadFailure?("No data received from server")
                }
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString)")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                do {
                    let responseModel = try JSONDecoder().decode(UploadDocumentResponse.self, from: data)
                    DispatchQueue.main.async {
                        if responseModel.success {
                            self.documentUploadSuccess?(responseModel.message)
                        } else {
                            self.documentUploadFailure?(responseModel.message)
                        }
                    }
                } catch {
                    print("❌ JSON decode error: \(error)")
                    // Assume success if status is 2xx but JSON parsing fails
                    DispatchQueue.main.async {
                        self.documentUploadSuccess?("Document uploaded successfully")
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Authentication failed. Please log in again.")
                }
            case 403:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("You don't have permission to upload documents to this project.")
                }
            case 404:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Project not found. Please check the project ID.")
                }
            default:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    func fetchDocuments(projectId: Int, page: Int = 1, limit: Int = 10) {
        print("📡 Fetching documents for project: \(projectId)")
        
        guard let url = URL(string: "\(APIEndpoints.getProjectDocuments)?project_id=\(projectId)&page=\(page)&limit=\(limit)") else {
            print("❌ Invalid URL")
            onDocumentsFetchedFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found")
            onDocumentsFetchedFailure?("Invalid Token")
            return
        }
        
        print("🌐 Fetch URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("📥 Fetch documents response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onDocumentsFetchedFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    self.onDocumentsFetchedFailure?("Invalid response from server")
                }
                return
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.onDocumentsFetchedFailure?("No data received from server")
                }
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString)")
            }
            
            // Handle different response scenarios
            switch httpResponse.statusCode {
            case 200:
                // Success - try to decode the response
                do {
                    let responseModel = try JSONDecoder().decode(GetDocumentsResponse.self, from: data)
                    print("✅ Documents decoded successfully")
                    DispatchQueue.main.async {
                        if responseModel.success {
                            self.onDocumentsFetchedSuccess?(responseModel.data)
                        } else {
                            self.onDocumentsFetchedFailure?(responseModel.message)
                        }
                    }
                } catch {
                    print("❌ JSON decode error: \(error)")
                    // Try alternative decoding approaches
                    self.handleAlternativeDecoding(data: data)
                }
            case 401:
                print("❌ Authentication failed")
                DispatchQueue.main.async {
                    self.onDocumentsFetchedFailure?("Authentication failed. Please log in again.")
                }
            case 403:
                print("❌ Access forbidden")
                DispatchQueue.main.async {
                    self.onDocumentsFetchedFailure?("You don't have permission to view this project's documents.")
                }
            case 404:
                print("ℹ️ No documents found - creating empty response")
                DispatchQueue.main.async {
                    let emptyResponse = DocumentResponseData(
                        page_data: [],
                        page_information: PageInformations(
                            total_data: 0,
                            last_page: 1,
                            current_page: page,
                            previous_page: max(0, page - 1),
                            next_page: 0
                        )
                    )
                    self.onDocumentsFetchedSuccess?(emptyResponse)
                }
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.onDocumentsFetchedFailure?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    private func handleAlternativeDecoding(data: Data) {
        // Try to decode as a direct array of documents
        do {
            let documents = try JSONDecoder().decode([DocumentData].self, from: data)
            print("✅ Documents decoded as array")
            let response = DocumentResponseData(
                page_data: documents,
                page_information: PageInformations(
                    total_data: documents.count,
                    last_page: 1,
                    current_page: 1,
                    previous_page: 0,
                    next_page: 0
                )
            )
            DispatchQueue.main.async {
                self.onDocumentsFetchedSuccess?(response)
            }
        } catch {
            print("❌ Alternative decoding failed: \(error)")
            DispatchQueue.main.async {
                if data.isEmpty {
                    // Empty response - return empty document list
                    let emptyResponse = DocumentResponseData(
                        page_data: [],
                        page_information: PageInformations(
                            total_data: 0,
                            last_page: 1,
                            current_page: 1,
                            previous_page: 0,
                            next_page: 0
                        )
                    )
                    self.onDocumentsFetchedSuccess?(emptyResponse)
                } else {
                    self.onDocumentsFetchedFailure?("Unable to parse server response. The response format may have changed.")
                }
            }
        }
    }
    
    func deleteDocument(documentId: Int) {
        print("🗑️ Deleting document: \(documentId)")
        
        guard let url = URL(string: "\(APIEndpoints.deleteProjectDocument)?document_id=\(documentId)") else {
            print("❌ Invalid URL")
            documentUploadFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found")
            documentUploadFailure?("Invalid Token")
            return
        }
        
        print("🌐 Delete URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization") 
        urlRequest.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("📥 Delete response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Invalid response from server")
                }
                return
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            // Print raw response for debugging
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                if let data = data, !data.isEmpty {
                    do {
                        let responseModel = try JSONDecoder().decode(DeleteDocumentResponse.self, from: data)
                        DispatchQueue.main.async {
                            if responseModel.success {
                                self.documentUploadSuccess?(responseModel.message)
                            } else {
                                self.documentUploadFailure?(responseModel.message)
                            }
                        }
                    } catch {
                        print("❌ JSON decode error: \(error)")
                        DispatchQueue.main.async {
                            self.documentUploadSuccess?("Document deleted successfully")
                        }
                    }
                } else {
                    // No content response is also success for DELETE
                    DispatchQueue.main.async {
                        self.documentUploadSuccess?("Document deleted successfully")
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Authentication failed. Please log in again.")
                }
            case 403:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("You don't have permission to delete this document.")
                }
            case 404:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Document not found or already deleted.")
                }
            default:
                DispatchQueue.main.async {
                    self.documentUploadFailure?("Failed to delete document (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
}
