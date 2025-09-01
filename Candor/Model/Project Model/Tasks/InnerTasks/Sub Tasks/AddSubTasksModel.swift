//
//  AddSubTasksModel.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

// MARK: - Add Sub Task Request Model
struct AddSubTaskRequest: Codable {
    let title: String
    let taskId: Int
    let dueDate: String
    let description: String
    let statusId: Int
    let isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case title
        case taskId = "parent_id"
        case dueDate = "due_date"
        case description
        case statusId = "status_id"
        case isCompleted = "is_completed"
    }
}

// MARK: - Add Sub Task Response Model
struct AddSubTaskResponse: Codable {
    let success: Bool
    let message: String
    let data: SubTaskData?
}

// MARK: - Sub Task Data
struct SubTaskData: Codable {
    let id: Int
    let title: String
    let parentId: Int?
    let assignedTo: Int?
    let assignedBy: Int?
    let dueDate: String
    let description: String
    let taskType: String
    let isCompleted: Bool
    let statusId: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case parentId = "parent_id"
        case assignedTo = "assigned_to"
        case assignedBy = "assigned_by"
        case dueDate = "due_date"
        case description
        case taskType = "task_type"
        case isCompleted = "is_completed"
        case statusId = "status_id"
        case createdAt, updatedAt
    }
}
