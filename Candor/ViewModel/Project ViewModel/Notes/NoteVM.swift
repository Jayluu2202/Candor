//
//  AddNoteVM.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import Foundation

class NoteVM {
    var noteAddSuccess: ((String) -> Void)?
    var noteAddFailure: ((String) -> Void)?
    
    var onNotesFetchedSuccess: (([NoteData]) -> Void)?
    var onNotesFetchedFailure: ((String) -> Void)?
    
    func addNewNote(request: AddNoteRequest) {
        print("📝 Starting addNewNote for project: \(request.project_id)")
        
        guard let url = URL(string: APIEndpoints.addNoteInProject) else {
            print("❌ Invalid URL: \(APIEndpoints.addNoteInProject)")
            noteAddFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found")
            noteAddFailure?("Invalid Token")
            return
        }
        
        print("🌐 Add Note URL: \(url)")
        print("📋 Note title: \(request.title)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 30
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            print("📦 Request body encoded successfully")
        } catch {
            print("❌ Failed to encode request: \(error.localizedDescription)")
            noteAddFailure?("Failed to encode request: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("📥 Add Note response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Invalid response from server")
                }
                return
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.noteAddFailure?("No data received")
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
                do {
                    let responseModel = try JSONDecoder().decode(AddProjectResponse.self, from: data)
                    print("✅ Response decoded successfully")
                    DispatchQueue.main.async {
                        if responseModel.success {
                            self.noteAddSuccess?(responseModel.message)
                        } else {
                            self.noteAddFailure?(responseModel.message)
                        }
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    // Assume success if status is 2xx but JSON parsing fails
                    DispatchQueue.main.async {
                        self.noteAddSuccess?("Note added successfully")
                    }
                }
            case 401:
                print("❌ Authentication failed")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Authentication failed. Please log in again.")
                }
            case 403:
                print("❌ Access forbidden")
                DispatchQueue.main.async {
                    self.noteAddFailure?("You don't have permission to add notes to this project.")
                }
            case 404:
                print("❌ Project not found")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Project not found. Please check the project ID.")
                }
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    func fetchNote(projectId: Int) {
        print("📡 Starting fetchNote for project: \(projectId)")
        
        guard let url = URL(string: "\(APIEndpoints.fetchNotes)?project_id=\(projectId)") else {
            print("❌ Invalid URL: \(APIEndpoints.fetchNotes)?project_id=\(projectId)")
            onNotesFetchedFailure?("URL error")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found")
            onNotesFetchedFailure?("Invalid Token")
            return
        }
        
        print("🌐 Fetch Notes URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization") 
        urlRequest.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("📥 Fetch Notes response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.onNotesFetchedFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    self.onNotesFetchedFailure?("Invalid response from server")
                }
                return
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.onNotesFetchedFailure?("No data received")
                }
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString)")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200:
                do {
                    let responseModel = try JSONDecoder().decode(GetNotesResponse.self, from: data)
                    print("✅ Notes decoded successfully - Count: \(responseModel.data.count)")
                    DispatchQueue.main.async {
                        if responseModel.success {
                            self.onNotesFetchedSuccess?(responseModel.data)
                        } else {
                            self.onNotesFetchedFailure?(responseModel.message)
                        }
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    self.handleNotesDecodingError(error: error, data: data)
                }
            case 401:
                print("❌ Authentication failed")
                DispatchQueue.main.async {
                    self.onNotesFetchedFailure?("Authentication failed. Please log in again.")
                }
            case 403:
                print("❌ Access forbidden")
                DispatchQueue.main.async {
                    self.onNotesFetchedFailure?("You don't have permission to view notes for this project.")
                }
            case 404:
                print("ℹ️ No notes found - returning empty list")
                DispatchQueue.main.async {
                    self.onNotesFetchedSuccess?([]) // Return empty array for no notes
                }
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.onNotesFetchedFailure?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    private func handleNotesDecodingError(error: Error, data: Data) {
        print("Handling notes decoding error")
        
        // Try alternative decoding approaches
        do {
            // Try to decode as a direct array
            let notes = try JSONDecoder().decode([NoteData].self, from: data)
            print("✅ Successfully decoded notes as direct array")
            DispatchQueue.main.async {
                self.onNotesFetchedSuccess?(notes)
            }
        } catch {
            print("❌ Alternative notes decoding also failed: \(error)")
            DispatchQueue.main.async {
                if data.isEmpty {
                    self.onNotesFetchedSuccess?([]) // Return empty array for empty response
                } else {
                    self.onNotesFetchedFailure?("Failed to parse notes data. The response format may have changed.")
                }
            }
        }
    }

    func updateNote(request: UpdateNoteRequest) {
        print("✏️ Starting updateNote for note: \(request.project_note_id)")
        
        guard let url = URL(string: APIEndpoints.updateNote) else {
            print("❌ Invalid URL: \(APIEndpoints.updateNote)")
            noteAddFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found")
            noteAddFailure?("Invalid Token")
            return
        }
        
        print("🌐 Update Note URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 30
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            print("📦 Update request body encoded successfully")
        } catch {
            print("❌ Failed to encode request: \(error.localizedDescription)")
            noteAddFailure?("Failed to encode request: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("📥 Update Note response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Invalid response from server")
                }
                return
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.noteAddFailure?("No data received")
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
                do {
                    let responseModel = try JSONDecoder().decode(UpdateNoteResponse.self, from: data)
                    print("✅ Update response decoded successfully")
                    DispatchQueue.main.async {
                        if responseModel.success {
                            self.noteAddSuccess?(responseModel.message)
                        } else {
                            self.noteAddFailure?(responseModel.message)
                        }
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    // Assume success if status is 2xx but JSON parsing fails
                    DispatchQueue.main.async {
                        self.noteAddSuccess?("Note updated successfully")
                    }
                }
            case 401:
                print("❌ Authentication failed")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Authentication failed. Please log in again.")
                }
            case 403:
                print("❌ Access forbidden")
                DispatchQueue.main.async {
                    self.noteAddFailure?("You don't have permission to update this note.")
                }
            case 404:
                print("❌ Note not found")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Note not found or already deleted.")
                }
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    func deleteNote(noteId: Int) {
        print("🗑️ Starting deleteNote for note: \(noteId)")
        
        guard let url = URL(string: "\(APIEndpoints.deleteNote)?project_note_id=\(noteId)") else {
            print("❌ Invalid URL: \(APIEndpoints.deleteNote)?project_note_id=\(noteId)")
            noteAddFailure?("Invalid URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("❌ No token found")
            noteAddFailure?("Invalid Token")
            return
        }
        
        print("🌐 Delete Note URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("📥 Delete Note response received")
            
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Invalid response from server")
                }
                return
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            // Print raw response for debugging
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString)")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                if let data = data, !data.isEmpty {
                    do {
                        let responseModel = try JSONDecoder().decode(DeleteNoteResponse.self, from: data)
                        print("✅ Delete response decoded successfully")
                        DispatchQueue.main.async {
                            if responseModel.success {
                                self.noteAddSuccess?(responseModel.message)
                            } else {
                                self.noteAddFailure?(responseModel.message)
                            }
                        }
                    } catch {
                        print("❌ Decoding error: \(error)")
                        // Assume success if status is 2xx but JSON parsing fails
                        DispatchQueue.main.async {
                            self.noteAddSuccess?("Note deleted successfully")
                        }
                    }
                } else {
                    // No content response is also success for DELETE
                    DispatchQueue.main.async {
                        self.noteAddSuccess?("Note deleted successfully")
                    }
                }
            case 401:
                print("❌ Authentication failed")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Authentication failed. Please log in again.")
                }
            case 403:
                print("❌ Access forbidden")
                DispatchQueue.main.async {
                    self.noteAddFailure?("You don't have permission to delete this note.")
                }
            case 404:
                print("❌ Note not found")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Note not found or already deleted.")
                }
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.noteAddFailure?("Server error (Code: \(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
}
