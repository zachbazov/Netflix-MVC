//
//  UserViewModel.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 18/07/2022.
//

import Foundation

// MARK: - UserViewModel

struct UserViewModel: Codable {
    let name: String?
    let email: String?
    let password: String?
    let passwordConfirm: String?
    let role: String?
    let active: Bool?
}
