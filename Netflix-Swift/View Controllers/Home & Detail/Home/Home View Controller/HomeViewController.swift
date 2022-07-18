//
//  HomeViewController.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 13/02/2022.
//

import UIKit

// MARK: - HomeViewController

final class HomeViewController: PrototypeViewController {
    
    // MARK: Properties
    
    @IBOutlet private(set) weak var tableView: UITableView! = nil
    
    @IBOutlet private(set) weak var placeholderView: PlaceholderView! = nil
    
    @IBOutlet private(set) weak var statusBarBackgroundView: StatusBarBackgroundView! = nil
    
    @IBOutlet private(set) weak var navigationView: NavigationView! = nil
    
    @IBOutlet private(set) weak var navigationOverlayView: NavigationOverlayView! = nil
    
    @IBOutlet private(set) weak var maskView: MaskView! = nil
    
    @IBOutlet private(set) weak var homeOverlayContainerView: UIView! = nil
    
    @IBOutlet private(set) weak var navigationViewHeight: NSLayoutConstraint! = nil
    
    @IBOutlet private(set) weak var homeOverlayContainerViewTop: NSLayoutConstraint! = nil
    
    
    private(set) var homeViewModel: HomeViewModel = .init()
    
    
    var detailViewController: DetailViewController! = nil
    
    private(set) var homeOverlayViewController: HomeOverlayViewController! = nil
    
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.orientation = .portrait
        
        homeOverlayContainerViewTop.constant = view.bounds.size.height
        
        
        APIService.shared.request(SignInResponse.self, .signIn) { response in
            
            switch response {
            case .success(let signInResponse):
                
                APIService.shared.authentication.authedUser = signInResponse.data.user
                
                APIService.shared.authentication.authedUserJWTToken = signInResponse.token
                
                
                APIService.shared.request(SectionResponse.self, .section) { response in
                    
                    switch response {
                    case .success(let sectionResponse):
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else {
                                return
                            }
                            
                            self.homeViewModel.tvShows = sectionResponse.data
                            self.homeViewModel.movies = sectionResponse.data
                                                        WeakInjector.shared.inject([self.homeViewModel,
                                                        self.navigationView,
                                                        self.navigationOverlayView],
                                                       with: self)
                        }
                        
                    case .failure(.failedWithStatusCode(statusCode: 401)):
                        print("401 error while fetching sections.")
                    case .failure(_):
                        print("error while fetching sections.")
                    }
                }
            case .failure(let err):
                print(err.description)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let navigationController as UINavigationController:
            
            let destination = navigationController.viewControllers.first as? DetailViewController
            
            detailViewController = destination
            
            WeakInjector.shared.inject(detailViewController, with: self)
            
            WeakInjector.shared.inject(detailViewController.detailViewModel, with: detailViewController)
            
        case let destination as HomeOverlayViewController:
            
            homeOverlayViewController = destination
            
            WeakInjector.shared.inject(homeOverlayViewController, with: self)
            
        default: return
        }
    }
}
