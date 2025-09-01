//
//  SingleEmployeeResponse.swift
//  Candor
//
//  Created by mac on 05/08/25.
//

import Foundation

struct SingleEmployeeResponse: Codable {
    let success: Bool
    let message: String
    let data: SingleEmployeeData?
}

struct SingleEmployeeData: Codable {
    let profile_image: String?
    let id: Int
    let name: String?
    let country: String?
    let upwork_account_id: String?
    let employee_id: String
    let first_name: String
    let last_name: String
    let email: String
    let birth_date: String?
    let joining_date: String?
    let leaving_date: String?
    let contact_number: String?
    let emergency_contact_name: String?
    let emergency_contact_no: String?
    let address: String?
    let status: String?
    let reporting_person_id: Int?
    let user_type: String?
    let createdAt: String?
    let is_on_termination: String?
    let department: singleEmployeeDepartment?
    let user_branches: [Branch]?
    let technology: String?
    let technology_id: Int?
    let role: singleEmployeeRole?
    let reporting_person: ReportingPerson?
}

struct singleEmployeeDepartment: Codable {
    let id: Int
    let department_name: String
}

struct singleEmployeeRole: Codable {
    let id: Int
    let name: String
}

struct ReportingPerson: Codable {
    let id: Int
    let first_name: String
    let last_name: String
}

struct Branch: Codable {
    // Customize based on future usage or actual data structure.
    let id : Int
    let branch : BranchInfo
}
struct BranchInfo : Codable{
    let id : Int
    let branch_name : String
}

