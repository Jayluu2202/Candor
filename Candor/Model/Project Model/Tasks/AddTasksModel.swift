//
//  AddTasksModel.swift
//  Candor
//
//  Created by mac on 26/08/25.
//

import Foundation

// MARK: - Request Model
struct AddTaskRequest: Codable {
    let title: String
    let projectId: Int
    let assignedTo: Int?
    let dueDate: String
    let description: String?
    let isCompleted: Bool
    let priority: String?
    let statusId: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case projectId = "project_id"
        case assignedTo = "assigned_to"
        case dueDate = "due_date"
        case description
        case isCompleted = "is_completed"
        case priority
        case statusId = "status_id"
    }
}

// MARK: - Response Model
struct AddTaskResponse: Codable {
    let success: Bool
    let message: String
}
