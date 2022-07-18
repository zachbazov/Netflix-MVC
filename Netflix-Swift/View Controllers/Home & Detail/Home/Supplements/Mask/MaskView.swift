//
//  MaskView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 04/04/2022.
//

import UIKit

// MARK: - MaskViewDelegate

protocol MaskViewDelegate: AnyObject {
    
    func maskViewDidShow(_ maskView: MaskView,
                         coordinatorView view: UIView,
                         with tabBar: UITabBar?,
                         translationY y: CGFloat?)
    
    func maskViewDidHide(_ maskView: MaskView,
                         coordinatorView view: UIView,
                         with tabBar: UITabBar?)
}



// MARK: - MaskView

final class MaskView: UIView {
    
    // MARK: Properties
    
    private(set) weak var delegate: MaskViewDelegate! = nil
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.delegate = self
    }
}



// MARK: - MaskViewDelegate Implementation

extension MaskView: MaskViewDelegate {
    
    func maskViewDidShow(_ maskView: MaskView,
                         coordinatorView view: UIView,
                         with tabBar: UITabBar?,
                         translationY y: CGFloat?) {
        
        UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            maskView.alpha = 1.0
            view.transform = CGAffineTransform(translationX: 0.0, y: y ?? -8.0)
            
            if let tabBar = tabBar {
                tabBar.alpha = 0.0
            }
            
        } completion: { [weak self] done in
            guard let self = self else {
                return
            }
            
            if done {
                guard
                    let _ = done as Bool?
                else {
                    return
                }
                
                self.maskViewDidHide(self, coordinatorView: view, with: tabBar)
            }
        }
    }
    
    func maskViewDidHide(_ maskView: MaskView,
                         coordinatorView view: UIView,
                         with tabBar: UITabBar?) {
        
        UIView.animate(withDuration: 0.33, delay: 0.2, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            
            maskView.alpha = 0.0
            view.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
            
            if let tabBar = tabBar {
                tabBar.alpha = 1.0
            }
        }
    }
}
