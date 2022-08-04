//
//  NavigationView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 11/02/2022.
//

import UIKit

// MARK: - NavigationViewDelegate

@objc protocol NavigationViewDelegate: AnyObject {
    @objc func navigationView(_ navigationView: NavigationView, didSelect item: Any)
    func navigationView(_ navigationView: NavigationView, didChange state: NavigationView.State)
    func navigationViewWillPerformInteractions(_ navigationView: NavigationView)
    func navigationViewWillPerformAnimations(_ navigationView: NavigationView)
    func navigationViewWillDisplayOverlay(_ navigationView: NavigationView)
}


// MARK: - NavigationView

final class NavigationView: UIView, Nibable {
    
    // MARK: State
    
    @objc enum State: Int, Valuable, CaseIterable {
        
        case home,
             tvShows,
             movies,
             categories,
             tvShowsAllCategories,
             moviesAllCategories
        
        var stringValue: String {
            switch self {
            case .home: return "Home"
            case .tvShows: return "TV Shows"
            case .movies: return "Movies"
            case .categories: return "Categories"
            case .tvShowsAllCategories: return "All Categories"
            case .moviesAllCategories: return "All Categories"
            }
        }
    }
    
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private weak var bottomContainer: UIView! = nil
    @IBOutlet private weak var homeButton: UIButton! = nil
    @IBOutlet private(set) weak var tvShowsButton: NavigationItemView! = nil
    @IBOutlet private(set) weak var moviesButton: NavigationItemView! = nil
    @IBOutlet private weak var categoriesButton: NavigationItemView! = nil
    @IBOutlet private(set) weak var tvShowsAllCategoriesButton: NavigationItemView! = nil
    @IBOutlet private(set) weak var moviesAllCategoriesButton: NavigationItemView! = nil
    @IBOutlet private weak var profileButton: UIButton! = nil
    @IBOutlet private weak var airPlayButton: UIButton! = nil
    @IBOutlet private weak var topGradientView: UIView! = nil
    @IBOutlet private weak var bottomContainerCenterXConstraint: NSLayoutConstraint! = nil
    @IBOutlet private weak var moviesCenterXConstraint: NSLayoutConstraint! = nil
    @IBOutlet private weak var moviesAllCategoriesLeadingConstraint: NSLayoutConstraint! = nil
    
    var state: State = .home {
        didSet {
            guard let delegate = delegate else { return }
            delegate.navigationView(self, didChange: state)
        }
    }
    
    private var hasExpanded = false
    private var hasInteracted = false
    
    private(set) weak var delegate: NavigationViewDelegate! = nil
    
    weak var homeViewController: HomeViewController! = nil {
        didSet {
            guard let homeViewController = homeViewController else { return }
            WeakInjector.shared.inject([tvShowsButton,
                                        tvShowsAllCategoriesButton,
                                        moviesButton,
                                        moviesAllCategoriesButton,
                                        categoriesButton],
                                       with: homeViewController)
        }
    }
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
        self.topGradientView.addGradientLayer(frame: self.topGradientView.bounds,
                                              colors:
                                                [.black.withAlphaComponent(0.75),
                                                 .black.withAlphaComponent(0.5),
                                                 .clear],
                                              locations: [0.0, 0.5, 1.0])
        self.homeButton.addTarget(self.delegate,
                                  action: #selector(self.delegate.navigationView(_:didSelect:)),
                                  for: .touchUpInside)
    }
    
    deinit {
        WeakInjector.shared.eject([tvShowsButton,
                                    tvShowsAllCategoriesButton,
                                    moviesButton,
                                    moviesAllCategoriesButton,
                                    categoriesButton])
        delegate = nil
        homeViewController = nil
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        APIService.shared.authentication.credentials.deleteCache()
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self,
                let tabBarController = self.homeViewController.tabBarController
            else { return }
            tabBarController.performSegue(withIdentifier: "NavigationAuthViewController", sender: tabBarController)
        }
    }
}


// MARK: - NavigationViewDelegate Implementation

extension NavigationView: NavigationViewDelegate {
    
    @objc func navigationView(_ navigationView: NavigationView, didSelect item: Any) {
        guard
            let homeViewController = homeViewController,
            let homeOverlayViewController = homeViewController.homeOverlayViewController,
            let state: State = .init(rawValue: (item as? UIView)?.tag ?? 0)
        else { return }
        switch state {
        case .home:
            self.state = .home
            homeOverlayViewController.showsOverlay = false
        case .tvShows:
            self.state = .tvShows
            UserDefaults.standard.set(State.tvShows.rawValue,
                                      forKey: UserDefaults.stateRowKey)
        case .movies:
            self.state = .movies
            UserDefaults.standard.set(State.movies.rawValue,
                                      forKey: UserDefaults.stateRowKey)
        case .categories:
            self.state = .categories
        case .tvShowsAllCategories:
            self.state = .tvShowsAllCategories
        case .moviesAllCategories:
            self.state = .moviesAllCategories
        }
    }
    
    func navigationView(_ navigationView: NavigationView, didChange state: State) {
        guard
            let homeViewController = homeViewController,
            let navigationOverlayView = homeViewController.navigationOverlayView,
            let delegate = delegate,
            let navigationOverlayViewDelegate = navigationOverlayView.delegate
        else { return }
        delegate.navigationViewWillPerformInteractions(self)
        delegate.navigationViewWillDisplayOverlay(self)
        navigationOverlayViewDelegate.navigationOverlayViewWillChangeSnapshot(self)
        navigationOverlayViewDelegate.navigationOverlayView(self, didValidateBoundsFor: navigationOverlayView.tableView)
        animate(.spring)
    }
    
    
    func navigationViewWillPerformInteractions(_ navigationView: NavigationView) {
        guard
            let homeViewController = homeViewController,
            let maskView = homeViewController.maskView,
            let rootView = homeViewController.view,
            let tabBarController = homeViewController.tabBarController,
            let tabBar = tabBarController.tabBar as UITabBar?,
            let navigationOverlayView = homeViewController.navigationOverlayView,
            let homeOverlayViewController = homeViewController.homeOverlayViewController,
            let delegate = delegate
        else { return }
        switch state {
        case .home:
            if !hasInteracted
                && navigationOverlayView.category == .home
                && !homeOverlayViewController.showsOverlay {
                guard let maskViewDelegate = maskView.delegate else { return }
                maskViewDelegate.maskViewDidShow(maskView,
                                                 coordinatorView: rootView,
                                                 with: tabBar,
                                                 translationY: nil)
            }
            if navigationOverlayView.category != .home
                && homeOverlayViewController.showsOverlay {
                navigationOverlayView.category = .home
                UserDefaults.standard.set(State.home.rawValue, forKey: UserDefaults.categoryRowKey)
            }
            hasExpanded = false
            hasInteracted = false
        case .tvShows:
            hasInteracted = true
        case .movies:
            hasInteracted = true
        case .categories:
            hasInteracted = false
        case .tvShowsAllCategories:
            hasInteracted = true
        case .moviesAllCategories:
            hasInteracted = true
        }
        delegate.navigationViewWillPerformAnimations(self)
    }
    
    func navigationViewWillPerformAnimations(_ navigationView: NavigationView) {
        switch state {
        case .home:
            UIView.animate(withDuration: 0.5) { [unowned self] in
                bottomContainerCenterXConstraint.constant = 0.0
                moviesCenterXConstraint.constant = 0.0
                moviesAllCategoriesLeadingConstraint.constant = 0.0
                tvShowsButton.alpha = 1.0
                moviesButton.alpha = 1.0
                categoriesButton.alpha = 1.0
                tvShowsAllCategoriesButton.alpha = 0.0
                moviesAllCategoriesButton.alpha = 0.0
                tvShowsButton.imageView.alpha = 0.0
                tvShowsAllCategoriesButton.imageView.alpha = 0.0
                moviesButton.imageView.alpha = 0.0
                moviesAllCategoriesButton.imageView.alpha = 0.0
            }
        case .tvShows:
            UIView.animate(withDuration: 0.5) { [unowned self] in
                bottomContainerCenterXConstraint.constant = -24.0
                moviesCenterXConstraint.constant = 0.0
                moviesAllCategoriesLeadingConstraint.constant = 0.0
                tvShowsButton.alpha = 1.0
                moviesButton.alpha = 0.0
                categoriesButton.alpha = 0.0
                tvShowsAllCategoriesButton.alpha = 1.0
                moviesAllCategoriesButton.alpha = 0.0
                tvShowsButton.imageView.alpha = 1.0
                tvShowsAllCategoriesButton.imageView.alpha = 1.0
                moviesButton.imageView.alpha = 0.0
                moviesAllCategoriesButton.imageView.alpha = 0.0
            }
        case .movies:
            UIView.animate(withDuration: 0.5) { [unowned self] in
                bottomContainerCenterXConstraint.constant = 0.0
                moviesCenterXConstraint.constant = -bottomContainer.bounds.size.width / 2 + 8.0
                moviesAllCategoriesLeadingConstraint.constant = 10.0
                tvShowsButton.alpha = 0.0
                moviesButton.alpha = 1.0
                categoriesButton.alpha = 0.0
                tvShowsAllCategoriesButton.alpha = 0.0
                moviesAllCategoriesButton.alpha = 1.0
                tvShowsButton.imageView.alpha = 0.0
                tvShowsAllCategoriesButton.imageView.alpha = 0.0
                moviesButton.imageView.alpha = 1.0
                moviesAllCategoriesButton.imageView.alpha = 1.0
            }
        default: return
        }
    }
    
    func navigationViewWillDisplayOverlay(_ navigationView: NavigationView) {
        guard
            let homeViewController = homeViewController,
            let categoryOverlayView = homeViewController.navigationOverlayView
        else { return }
        switch state {
        case .home:
            hasInteracted = false
            hasExpanded = false
        case .tvShows,
                .movies:
            guard let homeOverlayViewController = homeViewController.homeOverlayViewController else { return }
            if hasInteracted
                && hasExpanded
                || homeOverlayViewController.showsOverlay {
                categoryOverlayView.showsOverlay = true
                return
            }
            hasExpanded = true
        case .categories:
            hasInteracted = false
            hasExpanded = false
            categoryOverlayView.showsOverlay = true
        case .tvShowsAllCategories,
                .moviesAllCategories:
            hasInteracted = true
            hasExpanded = true
            categoryOverlayView.showsOverlay = true
        }
    }
}
