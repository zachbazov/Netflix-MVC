//
//  SignInViewController.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/07/2022.
//

import UIKit

// MARK: - SignInViewController

final class SignInViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var alertView: AlertView!
    
    @IBOutlet weak var alertViewTopConstraint: NSLayoutConstraint!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextfield.attributedPlaceholder = .init(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayText])
        
        self.passwordTextfield.attributedPlaceholder = .init(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayText])
        
        self.signInButton.layer.borderWidth = 1.5
        self.signInButton.layer.borderColor = UIColor.black.cgColor
        
        
        WeakInjector.shared.inject(alertView, with: self)
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        
        guard
            let email = emailTextfield.text,
            let password = passwordTextfield.text
        else {
            return
        }
        
        APIService.shared.authentication.signIn(AuthResponse.self,
                                 email,
                                 password) { [weak self] response in
            
            guard let self = self else {
                return
            }
            
            switch response {
            case .success(let signInResponse):
                
                APIService.shared.authentication.credentials = .init(jwt: .init(token: signInResponse.token),
                                                                     user: signInResponse.data)
                
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
                
                DispatchQueue.main.async {
                    
                    let storyboard: UIStoryboard = .init(name: UIStoryboard.Name.home, bundle: .main)
                    let viewController: UITabBarController = storyboard.instantiateViewController(withIdentifier: UIViewController.Identifier.homeTabBarController) as! UITabBarController
                    
                    if UIApplication.shared.windows.first!.rootViewController?.presentedViewController is UINavigationController || UIApplication.shared.windows.first!.rootViewController?.presentedViewController is UITabBarController {
                        
                        self.dismiss(animated: true, completion: nil)
                        
                        return
                    }
                    
                    if #available(iOS 13, *) {
                        UIApplication.shared.windows.first!.rootViewController?.present(viewController, animated: true)
                    } else {
                        UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true)
                    }
                }
                
            case .failure(let err):
                
                self.alertView
                    .present()
                    .message(err.description)
                    .image(.failure)
            }
        }
    }
}
