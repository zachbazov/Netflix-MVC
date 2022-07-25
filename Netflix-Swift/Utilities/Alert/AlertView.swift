//
//  AlertView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/07/2022.
//

import UIKit

// MARK: - AlertViewDelegate

protocol AlertViewDelegate: AnyObject {
    
    func alertViewDidShow()
    
    func alertViewDidHide()
}



// MARK: - AlertView

final class AlertView: UIView, Nibable {
    
    // MARK: Status
    
    enum State {
        case success,
             failure
    }
    
    
    // MARK: Action
    
    enum Button: Int {
        case primary,
             secondary
    }
    
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var primaryButton: UIButton!
    
    @IBOutlet weak var secondaryButton: UIButton!
    
    
    var showsAlert: Bool = false {
        didSet {
            guard let delegate = delegate else { return }
            showsAlert ? delegate.alertViewDidShow() : delegate.alertViewDidHide()
        }
    }
    
    var isSecondaryActive: Bool = false
    
    
    var primaryAction: (() -> Void)!
    
    var secondaryAction: (() -> Void)!
    
    
    weak var delegate: AlertViewDelegate! = nil
    
    
    weak var signInViewController: SignInViewController! = nil
    
    weak var signUpViewController: SignUpViewController! = nil
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.loadNib()
        
        self.delegate = self
        
        self.primaryAction = {
            self.showsAlert = false
        }
    }
    
    deinit {
        primaryAction = nil
        secondaryAction = nil
        
        signInViewController = nil
        signUpViewController = nil
        
        delegate = nil
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        guard let tag = sender.tag as Int? else {
            return
        }
        
        switch tag {
        case 0:
            primaryAction()
        case 1:
            secondaryAction()
        default:
            break
        }
    }
    
    
    // MARK: Methods
    
    func resetElements() {
        secondaryButton.isHidden = true
    }
    
    @discardableResult
    func present() -> AlertView {
        
        resetElements()
        
        if showsAlert {
            showsAlert = false
        } else {
            showsAlert = true
        }
        
        return self
    }
    
    @discardableResult
    func title(_ title: String) -> AlertView {
        
        titleLabel?.text = title
        
        return self
    }
    
    @discardableResult
    func message(_ message: String) -> AlertView {
        
        messageLabel?.text = message
        
        return self
    }
    
    @discardableResult
    func withStatusCode(_ statusCode: Int) -> AlertView {
        
        let currentTitle = titleLabel?.text ?? ""
        let newTitle = "\(statusCode): \(currentTitle)"
        
        titleLabel?.text = newTitle
        
        return self
    }
    
    @discardableResult
    func image(_ state: State) -> AlertView {
        
        imageView?.image = UIImage(systemName: state == .success
                                  ? "checkmark.circle.fill"
                                  : "exclamationmark.circle.fill")!
        
        return self
    }
    
    @discardableResult
    func action(_ act: Button, _ closure: @escaping (() -> Void)) -> AlertView {
        
        switch act {
        case .primary:
            primaryAction = closure
        case .secondary:
            secondaryAction = closure
        }
        
        return self
    }
    
    @discardableResult
    func buttonTitle(for button: Button, _ title: String) -> AlertView {
        
        switch button {
        case .primary:
            primaryButton.setTitle(title, for: .normal)
        case .secondary:
            secondaryButton.isHidden = false
            secondaryButton.setTitle(title, for: .normal)
        }
        
        return self
    }
    
    @discardableResult
    func secondaryTitle(_ title: String) -> AlertView {
        
        secondaryButton?.isHidden = false
        secondaryButton?.setTitle(title, for: .normal)
        
        return self
    }
    
    @discardableResult
    func secondaryAction(secondaryAction action: @escaping () -> Void) -> AlertView {
        
        secondaryButton.isHidden = false
        
        secondaryAction = action
        
        return self
    }
}



// MARK: - AlertViewDelegate Implementation

extension AlertView: AlertViewDelegate {
    
    func alertViewDidShow() {
        self.signInViewController?.alertViewTopConstraint.constant = 0.0
        self.signUpViewController?.alertViewTopConstraint.constant = 0.0
        self.homeViewController?.alertViewTopConstraint.constant = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .curveEaseInOut) {
            
            self.alpha = 1.0
            
            self.signInViewController?.view.layoutIfNeeded()
            self.signUpViewController?.view.layoutIfNeeded()
            self.homeViewController?.view.layoutIfNeeded()
        }
    }
    
    func alertViewDidHide() {
        self.signInViewController?.alertViewTopConstraint.constant = -64.0
        self.signUpViewController?.alertViewTopConstraint.constant = -64.0
        self.homeViewController?.alertViewTopConstraint.constant = -128.0
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseInOut) {
            
            self.alpha = 0.0
            
            self.signInViewController?.view.layoutIfNeeded()
            self.signUpViewController?.view.layoutIfNeeded()
            self.homeViewController?.view.layoutIfNeeded()
        }
    }
}
