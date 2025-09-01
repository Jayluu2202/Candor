//
//  GetInnerTaskDetailsModel.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import Foundation

// MARK: - Root Response
struct GetInnerTaskResponse: Codable {
    let success: Bool
    let message: String
    let data: InnerTaskResponseData
}

// MARK: - Data
struct InnerTaskResponseData: Codable {
    let taskData: InnerTaskData
    let assignedToUsers: [InnerAssignedUser]
    let taskStatus: [InnerTaskStatus]
}

// MARK: - TaskData
struct InnerTaskData: Codable {
    let tags: [String]
    let id: Int
    let title: String
    let assignedTo: Int?
    let projectId: Int
    let priority: String
    let dueDate: String
    let createdAt: String
    let description: String?
    let isCompleted: Bool
    let internId: Int?
    let taskCreatedDate: String
    let taskOwnerId: Int?
    let taskType: String
    let project: InnerProject
    let assignee: InnerAssignedUser?
    let assignor: InnerAssignedUser
    let taskDocuments: [String]
    let taskStatus: InnerTaskStatus
    let subTasks: [InnerSubTaskData]

    enum CodingKeys: String, CodingKey {
        case tags, id, title
        case assignedTo = "assigned_to"
        case projectId = "project_id"
        case priority
        case dueDate = "due_date"
        case createdAt = "created_at"
        case description
        case isCompleted = "is_completed"
        case internId = "intern_id"
        case taskCreatedDate = "task_created_date"
        case taskOwnerId = "task_owner_id"
        case taskType = "task_type"
        case project, assignee, assignor
        case taskDocuments = "task_documents"
        case taskStatus = "task_status"
        case subTasks = "sub_tasks"
    }
}

// MARK: - SubTask
struct InnerSubTaskData: Codable {
    let tags: [String]
    let id: Int
    let title: String
    let assignedTo: Int?
    let projectId: Int?
    let priority: String?
    let dueDate: String?
    let createdAt: String
    let description: String?
    let isCompleted: Bool
    let internId: Int?
    let taskOwnerId: Int?
    let taskType: String

    enum CodingKeys: String, CodingKey {
        case tags, id, title
        case assignedTo = "assigned_to"
        case projectId = "project_id"
        case priority
        case dueDate = "due_date"
        case createdAt = "created_at"
        case description
        case isCompleted = "is_completed"
        case internId = "intern_id"
        case taskOwnerId = "task_owner_id"
        case taskType = "task_type"
    }
}

// MARK: - Project
struct InnerProject: Codable {
    let id: Int
    let name: String
    let deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case deletedAt = "deleted_at"
    }
}

// MARK: - AssignedUser
struct InnerAssignedUser: Codable {
    let profileImage: String?
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

// MARK: - TaskStatus
struct InnerTaskStatus: Codable {
    let id: Int
    let title: String
}
