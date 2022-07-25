//
//  APIError.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/07/2022.
//

import Foundation

// MARK: - APIError

enum APIError: CustomStringConvertible {
    
    case custom(message:String)
    case noInternetConnection
    case generic
    case failedWithStatusCode(statusCode:Int)
    
    var description : String {
        switch self {
        case .noInternetConnection:
            return "Please check your internet connectivity."
        case .custom(let message):
            return message
        case .generic:
            return "There is a technical issue. Please contact us if the issue persists."
        case .failedWithStatusCode(let code):
            return "Failed with status code \(code)"
        }
    }
}
