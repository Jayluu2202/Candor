//
//  AddProjectModel.swift
//  Candor
//
//  Created by mac on 29/07/25.
//

import Foundation

struct ProjectRequest: Codable {
    let name: String
    let start_date: String
    let deadline: String
}

struct BasicResponse: Codable {
    let success: Bool
    let message: String
}
