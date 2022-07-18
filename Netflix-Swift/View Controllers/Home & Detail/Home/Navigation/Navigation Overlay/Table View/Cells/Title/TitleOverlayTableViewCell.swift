//
//  TitleOverlayTableViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 17/03/2022.
//

import UIKit

// MARK: - TitleOverlayTableViewCell

final class TitleOverlayTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet private weak var titleLabel: UILabel! = nil
    
    
    // MARK: Lifecycle
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let defaultSize: CGFloat = 17.0
        let largeSize: CGFloat = 24.0
        
        selected ? setFont(UIFont.boldSystemFont(ofSize: largeSize)) : setFont(.systemFont(ofSize: defaultSize))
    }
    
    
    // MARK: Methods
    
    private func setFont(_ font: UIFont) {
        titleLabel.font = font
    }
    
    
    func configure<T>(_ t: T) where T: Valuable {
        titleLabel.text = t.stringValue
    }
}
