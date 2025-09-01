//
//  AddProjectTaskSectionNameModel.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import Foundation

// MARK: - Request Model
struct TaskStatusRequest: Codable {
    let projectId: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case title
    }
}

// MARK: - Response Model
struct TaskStatusResponse: Codable {
    let success: Bool
    let message: String
}
