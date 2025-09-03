//
//  AddAssetModel.swift
//  Candor
//
//  Created by mac on 03/09/25.
//

import Foundation

struct AddAssetRequest: Codable {
    let code: String
    let item: String
    let location: Int
    let assignedId: Int?
    let OS: String?
    let processor: String?
    let graphicCard: String?
    let hardDisk: Int?   // ✅ Must be Int (no GB, just number)
    let ram: String?
    let model: String?
    let displayType: String?
    let mobileCompany: String?
    
    enum CodingKeys: String, CodingKey {
        case code, item, location
        case assignedId = "assigned_id"
        case OS, processor
        case graphicCard = "graphic_card"
        case hardDisk = "hard_disk"
        case ram, model
        case displayType = "display_type"
        case mobileCompany = "mobile_company"
    }
}

struct AddAssetResponse: Codable {
    let success: Bool
    let message: String
}
