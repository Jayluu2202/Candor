//
//  projectsModel.swift
//  Candor
//
//  Created by mac on 28/07/25.
//

// ProjectModel.swift
import Foundation

struct ProjectResponse: Codable {
    let success: Bool
    let message: String
    let data: ProjectData?
}

struct ProjectData: Codable {
    let pageData: [Project]
    let pageInformation: PageInformation

    enum CodingKeys: String, CodingKey {
        case pageData = "page_data"
        case pageInformation = "page_information"
    }
}

struct Project: Codable {
    let id: Int
    let name: String
    let deadline: String?
    let status: String
    let startDate: String
    let createdAt: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case id, name, deadline, status
        case startDate = "start_date"
        case createdAt = "created_at"
        case user
    }
}

struct User: Codable {
    let id: Int
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct PageInformation: Codable {
    let totalData: Int
    let lastPage: Int
    let currentPage: Int
    let previousPage: Int
    let nextPage: Int

    enum CodingKeys: String, CodingKey {
        case totalData = "total_data"
        case lastPage = "last_page"
        case currentPage = "current_page"
        case previousPage = "previous_page"
        case nextPage = "next_page"
    }
}

