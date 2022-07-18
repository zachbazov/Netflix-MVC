//
//  StatusBarBackgroundView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 04/04/2022.
//

import UIKit

// MARK: - StatusBarBackgroundViewDelegate

protocol StatusBarBackgroundViewDelegate: AnyObject {
    
    func statusBarBackgroundView(_ statusBarBackgroundView: StatusBarBackgroundView,
                                 willChange color: UIColor,
                                 withAlphaComponent alpha: CGFloat)
}



// MARK: - StatusBarBackgroundView

final class StatusBarBackgroundView: UIView {
    
    // MARK: Properties
    
    weak var delegate: StatusBarBackgroundViewDelegate! = nil
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.delegate = self
        
        self.delegate.statusBarBackgroundView(self, willChange: .black, withAlphaComponent: 0.75)
    }
}



// MARK: - StatusBarBackgroundViewDelegate Implementation

extension StatusBarBackgroundView: StatusBarBackgroundViewDelegate {
    
    func statusBarBackgroundView(_ statusBarBackgroundView: StatusBarBackgroundView,
                                 willChange color: UIColor,
                                 withAlphaComponent alpha: CGFloat) {
        statusBarBackgroundView.backgroundColor = color.withAlphaComponent(alpha)
    }
}
