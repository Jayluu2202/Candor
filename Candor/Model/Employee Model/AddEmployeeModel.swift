//
//  AddEmployeeModel.swift
//  Candor
//
//  Created by mac on 01/08/25.
//

import Foundation

struct AddEmployeeRequest: Codable {
    let employee_id: String
    let first_name: String
    let last_name: String
    let email: String
    let password: String
    let department_id: Int
    let role_id: Int
    let branch_ids: [Int]
    let birth_date: String
    let joining_date: String
    let contact_number: String
    let emergency_contact_name: String
    let emergency_contact_no: String
    let address: String
//    let reporting_person_id: String
//    let status: String
}

struct AddEmployeeResponse: Codable{
    let success: Bool
    let message: String
}
