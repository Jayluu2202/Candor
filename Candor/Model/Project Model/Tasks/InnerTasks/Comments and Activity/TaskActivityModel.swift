//
//  TaskActivityModel.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

// MARK: - TaskActivityResponse
struct ActivitySection {
    let date: String
    let activities: [TaskActivity]
}

struct TaskActivityResponse: Codable {
    let success: Bool
    let message: String
    let data: [String: [TaskActivity]] // The keys are dates like "2025-08-29"
}

// MARK: - TaskActivity
struct TaskActivity: Codable {
    let id: Int
    let taskID: Int?
    let userID: Int
    let activityLog: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let user: ActivityUser

    enum CodingKeys: String, CodingKey {
        case id
        case taskID = "task_id"
        case userID = "user_id"
        case activityLog = "activity_log"
        case createdAt
        case updatedAt
        case deletedAt
        case user
    }
}

// MARK: - ActivityUser
struct ActivityUser: Codable {
    let profileImage: String
    let id: Int
    let firstName: String
    let lastName: String
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
