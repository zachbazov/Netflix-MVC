//
//  UIView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 22/02/2022.
//

import UIKit

// MARK: - UIView

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var maxYCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }
}


extension UIView {
    
    enum Animation {
        case alpha
        case spring
    }
    
    func animate(_ animation: Animation,
                 animationDuration duration: TimeInterval? = nil,
                 delayingBy delay: TimeInterval? = nil,
                 alphaBefore before: CGFloat? = nil,
                 alphaAfter after: CGFloat? = nil,
                 animationOptions options: UIView.AnimationOptions? = nil,
                 coordinateBy superview: UIView? = nil,
                 completionBlock completion: (() -> Void)? = nil) {
        switch animation {
        case .alpha:
            break
        case .spring:
            UIView.animate(withDuration: 0.75,
                           delay: 0,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut) { [weak self] in
                guard let self = self else { return }
                self.layoutIfNeeded()
            }
        }
    }
}


extension UIView {
    
    fileprivate var defaultAnimationDuration: TimeInterval { return 0.3 }
    fileprivate var semiTransparent: CGFloat { return 0.5 }
    fileprivate var nonTransparent: CGFloat { return 1.0 }
    
    func setAlphaAnimation(using gesture: UIGestureRecognizer? = nil,
                           duration: TimeInterval? = nil,
                           alpha: CGFloat? = nil) {
        guard let gesture = gesture else { return }
        UIView.animate(withDuration: duration ?? defaultAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.alpha = alpha ?? self.semiTransparent
            self.isUserInteractionEnabled = false
        }
        if gesture.state == .ended {
            UIView.animate(withDuration: duration ?? defaultAnimationDuration) { [weak self] in
                guard let self = self else { return }
                self.alpha = alpha ?? self.nonTransparent
                self.isUserInteractionEnabled = true
            }
        }
    }
}


extension UIView {
    func addGradientLayer(frame: CGRect, colors:[UIColor], locations: [NSNumber]) {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map{$0.cgColor}
        gradient.locations = locations
        self.layer.addSublayer(gradient)
    }
}


extension UIView {
    var inferredFrame: CGRect? {
        guard
            let window = UIApplication.shared.windows.first as UIWindow?,
            let rootView = window.rootViewController?.view
        else { return .zero }
        return self.superview?.convert(self.frame, to: rootView)
    }
}
