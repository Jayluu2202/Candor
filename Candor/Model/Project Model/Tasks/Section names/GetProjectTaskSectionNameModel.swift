//
//  GetProjectTaskSectionNameModel.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import Foundation

struct TaskSectionResponse: Codable {
    let success: Bool
    let message: String
    let data : [TaskSection]
}
struct TaskSection: Codable{
    let id: Int
    let title: String
    let index: Int
}
