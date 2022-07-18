//
//  DispatchError.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 03/05/2022.
//

import Foundation

// MARK: - DispatchError

enum DispatchError: Error {
    
    case unexpectedIndexPathForSection(Int)
    
    var dispatch: Never {
        switch self {
        case .unexpectedIndexPathForSection(let section):
            fatalError("Unexpected indexPath for section: \(section).")
        }
    }
}

extension DispatchError {
    var isFatal: Bool {
        if case DispatchError.unexpectedIndexPathForSection = self {
            return true
        } else {
            return false
        }
    }
}
