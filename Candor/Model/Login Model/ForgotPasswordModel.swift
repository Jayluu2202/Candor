//
//  ForgotPasswordModel.swift
//  Candor
//
//  Created by mac on 12/08/25.
//

import Foundation

struct UpdatePasswordResponse : Codable{
    let success: Bool
    let message : String
    let data : UserData?
}
struct UpdatePasswordRequest: Codable {
    let user_id : String
    let password : String
}
