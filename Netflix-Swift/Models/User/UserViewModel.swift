//
//  UserViewModel.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 18/07/2022.
//

import Foundation

//

struct SignInResponse: Decodable {
    let status: String
    let token: String
    let data: UserResponse
}

// MARK: - UserResponse

struct UserResponse: Decodable {
    let user: UserViewModel
}

// MARK: - UserViewModel

struct UserViewModel: Decodable {
    let name: String?
    let email: String?
    let password: String?
    let passwordConfirm: String?
    let role: String?
}
