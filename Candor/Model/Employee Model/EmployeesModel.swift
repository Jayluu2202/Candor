//
//  EmployeesModel.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import Foundation

struct EmployeeResponse: Codable {
    let success: Bool
    let message: String
    let data: EmployeeDataContainer?
}

struct EmployeeDataContainer: Codable {
    let page_data: [Employee]
    let page_information: PageInfo
}

struct Employee: Codable {
    let id: Int
    let first_name: String
    let last_name: String
    let email: String
    let status: String
    let employee_id: String
    let profile_image: String?
    let department: Department?
    let role: Role?
}

struct Department: Codable {
    let id: Int
    let department_name: String
}

struct Role: Codable {
    let id: Int
    let name: String
}

struct PageInfo: Codable {
    let total_data: Int
    let last_page: Int
    let current_page: Int
    let previous_page: Int
    let next_page: Int
}
