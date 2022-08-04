//
//  Reusable.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/02/2022.
//

import UIKit

// MARK: - Reusable

protocol Reusable {}


// MARK: - Reusable Implementation

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
