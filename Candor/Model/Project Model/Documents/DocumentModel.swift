//
//  DocumentModel.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import Foundation

// MARK: - Upload Document Request
struct UploadDocumentRequest: Codable {
    let project_id: Int
    let name: String
    // Note: document file will be handled separately as multipart data
}

// MARK: - Upload Document Response
struct UploadDocumentResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Get Documents Response
struct GetDocumentsResponse: Codable {
    let success: Bool
    let message: String
    let data: DocumentResponseData
}

// MARK: - Document Response Data
struct DocumentResponseData: Codable {
    let page_data: [DocumentData]
    let page_information: PageInformations
}

// MARK: - Document Data
struct DocumentData: Codable {
    let document: String
    let id: Int
    let project_id: Int
    let name: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
}

// MARK: - Page Information
struct PageInformations: Codable {
    let total_data: Int
    let last_page: Int
    let current_page: Int
    let previous_page: Int
    let next_page: Int
}

// MARK: - Delete Document Response
struct DeleteDocumentResponse: Codable {
    let success: Bool
    let message: String
}
