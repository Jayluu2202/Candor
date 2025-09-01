//
//  NoteModel.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import Foundation

struct AddNoteRequest: Codable{
    let project_id : Int
    let title : String
    let description : String
}

struct AddProjectResponse: Codable{
    let success : Bool
    let message : String
}


// MARK: - Get Notes Response
struct GetNotesResponse: Codable {
    let success: Bool
    let message: String
    let data: [NoteData]
}

// MARK: - Note Data
struct NoteData: Codable {
    let id: Int
    let project_id: Int
    let user_id: Int
    let title: String
    let description: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let user: NoteUser
}

// MARK: - Note User
struct NoteUser: Codable {
    let profile_image: String
    let id: Int
    let first_name: String
    let last_name: String
    let name: String?
    let user_type: String
}

// MARK: - Update Note Request
struct UpdateNoteRequest: Codable {
    let project_note_id: Int
    let title: String
    let description: String
}

// MARK: - Update Note Response
struct UpdateNoteResponse: Codable {
    let success: Bool
    let message: String
}


// MARK: - Delete Note Response
struct DeleteNoteResponse: Codable {
    let success: Bool
    let message: String
}
