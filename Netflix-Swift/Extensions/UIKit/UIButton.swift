//
//  UIButton.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 14/03/2022.
//

import UIKit

// MARK: - UIButton

extension UIButton {
    
    func rounded(_ color: UIColor? = .black, _ alpha: CGFloat? = 0.5) {
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 1
        layer.borderColor = color?.withAlphaComponent(alpha ?? 0.5).cgColor
    }
}
