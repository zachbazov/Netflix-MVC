//
//  BarButtonItem.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/07/2022.
//

import UIKit

// MARK: - BarButtonItem

final class BarButtonItem: UIBarButtonItem {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)], for: .highlighted)
    }
}
