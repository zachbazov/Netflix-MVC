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
    @IBOutlet weak var alertView: AlertView!
    @IBOutlet weak var alertViewTopConstraint: NSLayoutConstraint!
    
    private(set) var homeViewModel: HomeViewModel = .init()
    
    var detailViewController: DetailViewController! = nil
    
    private(set) var homeOverlayViewController: HomeOverlayViewController! = nil
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WeakInjector.shared.inject(alertView, with: self)
        placeholderView.alpha = .hidden
        if let _ = APIService.shared.authentication.credentials.user,
           let _ = APIService.shared.authentication.credentials.jwt {
            APIService.shared.request(SectionResponse.self,
                                      .get,
                                      .find(.sections)) { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(let sectionResponse):
                    self.homeViewModel.tvShows = sectionResponse.data
                    self.homeViewModel.movies = sectionResponse.data
                    WeakInjector.shared.inject([self.homeViewModel,
                                                self.navigationView,
                                                self.navigationOverlayView],
                                               with: self)
                case .failure(let err):
                    self.alertView
                        .present()
                        .title("Unauthorized")
                        .message(err.description)
                        .withStatusCode(401)
                        .secondaryTitle("Sign In")
                        .action(.secondary) {
                            APIService.shared.authentication.credentials.deleteCache()
                            guard let tabBarController = self.tabBarController else { return }
                            tabBarController.performSegue(withIdentifier: "NavigationAuthViewController", sender: tabBarController)
                        }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.orientation = .portrait
        homeOverlayContainerViewTop.constant = view.bounds.size.height
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
