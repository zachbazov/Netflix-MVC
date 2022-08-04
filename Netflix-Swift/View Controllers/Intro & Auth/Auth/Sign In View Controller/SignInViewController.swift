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
        self.emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayText])
        self.passwordTextfield.attributedPlaceholder = NSAttributedString(
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
        else { return }
        APIService.shared.authentication.signIn(AuthResponse.self,
                                 email,
                                 password) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let signInResponse):
                APIService.shared.authentication.credentials = APICredentials(jwt: .init(token: signInResponse.token),
                                                                     user: signInResponse.data)
                let defaults = UserDefaults.standard
                let encoder = PropertyListEncoder()
                do {
                    let user = try encoder.encode(APIService.shared.authentication.credentials.user)
                    defaults.set(user, forKey: APICredentials.kUser)
                } catch let err {
                    print(err.localizedDescription)
                }
                let token = APIService.shared.authentication.credentials.jwt.token
                defaults.set(token, forKey: APICredentials.kJWT)
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.isHidden = true
                    self.performSegue(withIdentifier: "HomeTabBarController", sender: self)
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
