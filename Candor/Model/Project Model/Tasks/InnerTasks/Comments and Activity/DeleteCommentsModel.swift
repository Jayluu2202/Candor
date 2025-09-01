//
//  DeleteCommentsModel.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import Foundation

// MARK: - Delete Comment Response Model
struct DeleteCommentResponse: Codable {
    let success: Bool
    let message: String
}
