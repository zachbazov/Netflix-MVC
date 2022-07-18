//
//  Configurable.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 22/06/2022.
//

import Foundation

// MARK: - Configurable

@objc protocol Configurable {
    @objc optional func configure(_ section: SectionViewModel?, with homeViewController: HomeViewController?)
}
