//
//  GetTaskModel.swift
//  Candor
//
//  Created by mac on 25/08/25.
//

import Foundation

// MARK: - Response
struct GetTasksResponse: Codable {
    let success: Bool
    let message: String
    let data: [ProjectTask]
}


// MARK: - Task
struct ProjectTask: Codable {
    let tags: [String]
    let id: Int
    let title: String
    let priority: String?
    let due_date: String
    let created_at: String
    let project_task_index: Int?   // ✅ fix
    let task_created_date: String
    let is_completed: Bool
    let description: String?
    let duration: String
    let member_removed: String?    // ✅ fix
    let project: ProjectInfo
    let assignee: UserInfo?
    let assignor: UserInfo
    let task_status: TaskStatus
}

// MARK: - Project Info
struct ProjectInfo: Codable {
    let id: Int
    let name: String
    let deleted_at: String?
}

// MARK: - User Info
struct UserInfo: Codable {
    let profile_image: String?
    let id: Int
    let first_name: String
    let last_name: String
    let name: String?
    let user_type: String
}

// MARK: - Task Status
struct TaskStatus: Codable {
    let id: Int
    let title: String
    let index: Int
}
