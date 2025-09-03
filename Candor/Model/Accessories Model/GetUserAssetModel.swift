//
//  GetUserAssetModel.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

// MARK: - API Response
struct UserAssetResponse: Codable {
    let success: Bool
    let message: String
    let data: UserAssetData
}

// MARK: - Asset Data
struct UserAssetData: Codable {
    let id: Int
    let code: String
    let item: String
    let location: Int
    let assignedId: Int?
    let allocation: String
    let os: String?
    let osVersion: String?
    let processor: String?
    let graphicCard: String?
    let hardDisk: String?
    let ram: String?
    let model: String?
    let displayType: String?
    let mobileCompany: String?
    let isDefected: Bool
    let note: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let user: UserAsset?
    let branch: UserAssetBranch?

    enum CodingKeys: String, CodingKey {
        case id, code, item, location
        case assignedId = "assigned_id"
        case allocation
        case os = "OS"
        case osVersion = "os_version"
        case processor
        case graphicCard = "graphic_card"
        case hardDisk = "hard_disk"
        case ram, model
        case displayType = "display_type"
        case mobileCompany = "mobile_company"
        case isDefected = "is_defected"
        case note, createdAt, updatedAt, deletedAt, user, branch
    }
}

// MARK: - User
struct UserAsset: Codable {
    let id: Int
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

// MARK: - Branch
struct UserAssetBranch: Codable {
    let id: Int
    let branchName: String

    enum CodingKeys: String, CodingKey {
        case id
        case branchName = "branch_name"
    }
}
