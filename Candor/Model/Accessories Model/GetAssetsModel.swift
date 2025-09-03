//
//  GetAssetsModel.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

// MARK: - Top level response
struct GetAssetsResponse: Codable {
    let success: Bool
    let message: String
    let data: AssetData
}

// MARK: - Data container
struct AssetData: Codable {
    let pageData: [Asset]
    let pageInformation: AssetPageInformation

    enum CodingKeys: String, CodingKey {
        case pageData = "page_data"
        case pageInformation = "page_information"
    }
}

// MARK: - Asset
struct Asset: Codable {
    let id: Int
    let code: String
    let item: String
    let location: Int
    let assignedId: Int?
    let allocation: String
    let os: String?
    let isDefected: Bool
    let user: AssetUser?
    let branch: AssetBranch

    enum CodingKeys: String, CodingKey {
        case id, code, item, location, allocation, user, branch
        case assignedId = "assigned_id"
        case os = "OS"
        case isDefected = "is_defected"
    }
}

// MARK: - Asset User
struct AssetUser: Codable {
    let id: Int
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

// MARK: - Asset Branch
struct AssetBranch: Codable {
    let id: Int
    let branchName: String

    enum CodingKeys: String, CodingKey {
        case id
        case branchName = "branch_name"
    }
}

// MARK: - Asset Page Information
struct AssetPageInformation: Codable {
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
