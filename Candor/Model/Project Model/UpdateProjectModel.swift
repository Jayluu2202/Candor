//
//  UpdateProjectModel.swift
//  Candor
//
//  Created by mac on 04/08/25.
//

import Foundation

struct UpdateProjectResponse: Codable {
    let success: Bool
    let message: String
}

struct UpdateProjectRequest {
    let projectId: String
    let name: String
    let type: String
    let rate: String
    let deadline: String?
    let estimatedBudget: String
    let estimatedHours: String
    let clientId: String
    let status: String
    let startDate: String
    let technologyIds: [String]
}


