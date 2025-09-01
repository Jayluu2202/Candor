//
//  EditEmployeeModel.swift
//  Candor
//
//  Created by mac on 06/08/25.
//

import Foundation

struct EditEmployeeRequest {
    let user_id: Int
    let first_name: String
    let last_name: String
    let birth_date: String
    let contact_number: String
    let emergency_contact_name: String
    let emergency_contact_no: String
    let address: String
    let department_id: Int
    let branch_ids: [Int]
    let joining_date: String
    let role_id: Int
    let reporting_person_id: Int?
    let password: String?
    let technology_id: Int?
    
}

struct EditEmployeeResponse: Codable {
    let success: Bool
    let message: String
}
