//
//  UpdateSubTasksModel.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

// MARK: - Update Sub Task Request Model
struct UpdateSubTaskRequest: Codable {
    let taskId: String
    let title: String
    let assignedTo: Int
    let dueDate: String
    let priority: String
    let description: String
    let status: String
    let tags: [String]
    let statusId: String
    // let isCompleted: Bool? // Uncomment if you need this later
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case title
        case assignedTo = "assigned_to"
        case dueDate = "due_date"
        case priority
        case description
        case status
        case tags
        case statusId = "status_id"
        // case isCompleted = "is_completed"
    }
}

// MARK: - Update Sub Task Response Model
struct UpdateSubTaskResponse: Codable {
    let success: Bool
    let message: String
}
