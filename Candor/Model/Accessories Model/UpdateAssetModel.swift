//
//  UpdateAssetModel.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

// Request model
struct UpdateAssetRequest: Codable {
    let assets_id: Int
    let item: String
    let location: Int
    let assigned_id: Int
    let OS: String
    let processor: String
    let graphic_card: String
    let hard_disk: Int
    let ram: String
    let model: String
    let display_type: String
    let mobile_company: String
}

// Response model
struct UpdateAssetResponse: Codable {
    let success: Bool
    let message: String
}
