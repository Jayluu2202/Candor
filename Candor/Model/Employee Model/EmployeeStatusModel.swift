//
//  EmployeeStatusModel.swift
//  Candor
//
//  Created by mac on 19/08/25.
//

import Foundation

struct EmployeeStatusRequest : Codable {
    let user_id: String
    let status: String
}

struct EmployeeStatusResponse : Codable {
    let success : Bool
    let message : String
}
