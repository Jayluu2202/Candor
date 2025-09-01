//
//  basicModel.swift
//  Candor
//
//  Created by mac on 24/07/25.
//

import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: UserData?
}

struct UserData: Codable {
    let id: Int
    let user_type: String
    let role: UserRole?
    let token: String
}
struct UserRole: Codable{
    let id : Int
    let name : String
    let role_access : [UserAccess]?
    
}

struct UserAccess: Codable{
    let access_type: String
    let module : UserAccessNames?
}
struct UserAccessNames: Codable{
    let name : String
}
