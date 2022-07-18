//
//  BlurryView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 05/04/2022.
//

import UIKit

// MARK: - BlurryViewDelegate

protocol BlurryViewDelegate: AnyObject {
    
    func blurryViewDidConfigure()
    
    func blurryView(_ blurryView: BlurryView, insertToView view: UIView)
    
    func blurryView(_ blurryView: BlurryView, insertImage image: UIImage?)
}



// MARK: - BlurryView

final class BlurryView: UIView {
    
    // MARK: Properties
    
    private var coverView: UIView! = nil
    
    private var imageView: UIImageView! = nil
    
    private var blurView: UIVisualEffectView! = nil
    
    
    private(set) var delegate: BlurryViewDelegate! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, _ view: UIView) {
        self.init(frame: frame)
        
        self.delegate = self
        
        self.blurryViewDidConfigure()
        
        view.insertSubview(self, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        coverView = nil
        imageView = nil
        blurView = nil
        
        delegate = nil
    }
}



// MARK: - BlurryViewDelegate Implementation

extension BlurryView: BlurryViewDelegate {
    
    func blurryViewDidConfigure() {
        guard
            coverView == nil,
            let delegate = delegate
        else {
            return
        }
        
        coverView = UIView(frame: UIScreen.main.bounds)
        imageView = UIImageView(frame: coverView.bounds)
        imageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds

        delegate.blurryView(self, insertToView: self)
    }
    
    func blurryView(_ blurryView: BlurryView, insertToView view: UIView) {
        insertSubview(imageView, at: 0)
        insertSubview(blurView, at: 1)
    }
    
    func blurryView(_ blurryView: BlurryView, insertImage image: UIImage?) {
        imageView.image = image
    }
}
