//
//  GetCommentsModel.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

// MARK: - Root Model
struct GetCommentsResponse: Codable {
    let success: Bool
    let message: String
    let data: GetCommentsData
}

// MARK: - Data Section
struct GetCommentsData: Codable {
    let pageData: [GetComment]
    let pageInformation: GetCommentsPageInformation

    enum CodingKeys: String, CodingKey {
        case pageData = "page_data"
        case pageInformation = "page_information"
    }
}

// MARK: - Single Comment
struct GetComment: Codable {
    let mentionUsers: [String]?
    let id: Int
    let taskID: Int?
    let userID: Int
    let message: String
    let createdAt, updatedAt: String
    let deletedAt: String?
    let user: GetCommentsUser
    let taskCommFiles: [String]?

    enum CodingKeys: String, CodingKey {
        case mentionUsers = "mention_users"
        case id
        case taskID = "task_id"
        case userID = "user_id"
        case message, createdAt, updatedAt, deletedAt, user
        case taskCommFiles = "task_comm_files"
    }
}

// MARK: - User
struct GetCommentsUser: Codable {
    let profileImage: String
    let id: Int
    let firstName, lastName: String
    let name: String?
    let userType: String

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case userType = "user_type"
    }
}

// MARK: - Page Information
struct GetCommentsPageInformation: Codable {
    let totalData, lastPage, currentPage, previousPage: Int
    let nextPage: Int

    enum CodingKeys: String, CodingKey {
        case totalData = "total_data"
        case lastPage = "last_page"
        case currentPage = "current_page"
        case previousPage = "previous_page"
        case nextPage = "next_page"
    }
}
