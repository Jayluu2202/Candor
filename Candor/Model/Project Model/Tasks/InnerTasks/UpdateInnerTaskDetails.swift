//
//  UpdateInnerTaskDetails.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

// MARK: - Update Task Request Model
struct UpdateInnerTaskRequest: Codable {
    let taskId: String
    let title: String
    let assignedTo: Int
    let dueDate: String
    let priority: String
    let description: String
    let status: String
    let tags: [String]
    let statusId: String
    
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
    }
}

// MARK: - Update Task Response Model
struct UpdateInnerTaskResponse: Codable {
    let success: Bool
    let message: String
}
