//
//  SignUpViewController.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/07/2022.
//

import UIKit

// MARK: - SignUpViewController

final class SignUpViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var passwordConfirmTextfield: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var alertView: AlertView!
    
    @IBOutlet weak var alertViewTopConstraint: NSLayoutConstraint!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextfield.attributedPlaceholder = .init(
            string: "Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayText])
        
        self.emailTextfield.attributedPlaceholder = .init(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayText])
        
        self.passwordTextfield.attributedPlaceholder = .init(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayText])
        
        self.passwordConfirmTextfield.attributedPlaceholder = .init(
            string: "Confirm Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayText])
        
        self.signUpButton.layer.borderWidth = 1.5
        self.signUpButton.layer.borderColor = UIColor.black.cgColor
        
        self.alertView.signUpViewController = self
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        
        guard
            let name = nameTextfield.text,
            let email = emailTextfield.text,
            let password = passwordTextfield.text,
            let passwordConfirm = passwordConfirmTextfield.text
        else {
            return
        }
        
        APIService.shared.authentication.signUp(AuthResponse.self,
                                                name,
                                                email,
                                                password,
                                                passwordConfirm) { [weak self] response in
            
            guard let self = self else {
                return
            }
            
            switch response {
            case .success(let signupResponse):
                
                APIService.shared.authentication.credentials = .init(jwt: .init(token: signupResponse.token),
                                                                     user: signupResponse.data)
                
                let defaults: UserDefaults = .standard
                let encoder: PropertyListEncoder = .init()
                
                do {
                    let user: Data = try encoder.encode(APIService.shared.authentication.credentials.user)
                    
                    defaults.set(user, forKey: APICredentials.kUser)
                } catch let err {
                    print(err.localizedDescription)
                }
                
                let token: String = APIService.shared.authentication.credentials.jwt.token
                defaults.set(token, forKey: APICredentials.kJWT)
                
                self.alertView.primaryAction = {
                    
                    self.alertView.showsAlert = false
                    
                    let storyboard: UIStoryboard = .init(name: UIStoryboard.Name.home, bundle: .main)
                    let viewController: UIViewController = storyboard.instantiateViewController(withIdentifier: UIViewController.Identifier.homeTabBarController)
                    
                    self.present(viewController, animated: true)
                }
                
                self.alertView
                    .present()
                    .title("SUCCESS")
                    .message("Unlimited content is now available.")
                    .image(.success)
                    .buttonTitle(for: .primary, "Launch")
                
            case .failure(let err):
                
                self.alertView
                    .present()
                    .message(err.description)
                    .image(.failure)
            }
        }
    }
}