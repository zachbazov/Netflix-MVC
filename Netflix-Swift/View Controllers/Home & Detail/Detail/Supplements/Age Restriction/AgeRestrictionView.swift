//
//  AgeRestrictionView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/03/2022.
//

import UIKit

// MARK: - AgeRestrictionView

final class AgeRestrictionView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private weak var label: UILabel! = nil
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.layer.cornerRadius = 2.0
        self.contentView.layer.cornerRadius = 2.0
    }
}
