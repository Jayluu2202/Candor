//
//  LoggedInUserModel.swift
//  Candor
//
//  Created by mac on 01/08/25.
//

import Foundation
struct LoggedInUserResponse: Codable {
    let success: Bool
    let message: String
    let data: LoggedInUserData
}

struct LoggedInUserData: Codable {
    let profile_image: String?
    let id: Int
    let first_name: String
    let last_name: String
    let email: String
    let department: department
    let role: role
}

struct department: Codable {
    let id: Int
    let department_name: String
}

struct role: Codable {
    let id: Int
    let name: String
}
