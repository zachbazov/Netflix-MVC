//
//  TitleHeaderView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/02/2022.
//

import UIKit

// MARK: - TitleHeaderView

final class TitleHeaderView: UITableViewHeaderFooterView {
    
    // MARK: Properties
    
    private(set) var titleLabel = UILabel()
    
    
    // MARK: Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
