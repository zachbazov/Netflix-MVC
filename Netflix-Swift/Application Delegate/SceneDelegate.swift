//
//  SceneDelegate.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 11/02/2022.
//

import UIKit

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?
    
    
    // MARK: Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        APIService.shared.authentication.credentials.decode()
        let condition = APIService.shared.authentication.credentials.user == nil || APIService.shared.authentication.credentials.jwt == nil
        let storyboard = UIStoryboard(name: condition
                                        ? UIStoryboard.Name.authentication
                                        : UIStoryboard.Name.home,
                                      bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: condition
                                                                    ? UIViewController.Identifier.navigationAuthViewController
                                                                    : UIViewController.Identifier.homeTabBarController)
        window = UIWindow(windowScene: windowScene)
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        UserDefaults.standard.removeObject(forKey: UserDefaults.stateRowKey)
        UserDefaults.standard.removeObject(forKey: UserDefaults.categoryRowKey)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
