//
//  APIResponse.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/07/2022.
//

import Foundation

// MARK: - APIResponse

enum APIResponse<T> {
    case success(T)
    case failure(APIError)
}



// MARK: - AuthResponse

struct AuthResponse: Decodable {
    let status: String
    let token: String
    let data: UserViewModel
}



// MARK: - SectionResponse

struct SectionResponse: Decodable {
    let status: String
    let results: Int
    let data: [SectionViewModel]
}
