//
//  MemberModel.swift
//  Candor
//
//  Created by mac on 21/08/25.
//

import Foundation

// MARK: - Add Project Member Response
struct AddProjectMemberResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Remove Project Member Response
struct RemoveProjectMemberResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Get Employee List Response
struct EmployeeListResponseMembers: Codable {
    let success: Bool
    let message: String
    let data: [EmployeeMember]
}

struct EmployeeMember: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let name: String?
    let userType: String
    let role: MemberRole
    let technology: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case userType = "user_type"
        case role
        case technology
    }
}

struct MemberRole: Codable {
    let id: Int
    let name: String
}

// MARK: - Get Project Members Response
struct ProjectMembersResponse: Codable {
    let success: Bool
    let message: String
    let data: [ProjectMember]
}

struct ProjectMember: Codable {
    let id: Int
    let isActive: Bool
    let manualTimerAllow: Bool
    let user: MemberUser

    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case manualTimerAllow = "manual_timer_allow"
        case user
    }
}

struct MemberUser: Codable {
    let profileImage: String?
    let id: Int
    let firstName: String
    let lastName: String
    let name: String?
    let userType: String
    let technology: String?
    let role: MemberRole

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case userType = "user_type"
        case technology
        case role
    }
}
