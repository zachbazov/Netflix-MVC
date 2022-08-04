//
//  HDView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/03/2022.
//

import UIKit

// MARK: - HDView

final class HDView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private weak var label: UILabel! = nil
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
