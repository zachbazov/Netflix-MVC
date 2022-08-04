//
//  NavigationOverlayView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/02/2022.
//

import UIKit

// MARK: - NavigationOverlayViewDelegate

protocol NavigationOverlayViewDelegate: AnyObject {
    func navigationOverlayViewDidShow(_ navigationOverlayView: NavigationOverlayView)
    func navigationOverlayViewDidHide(_ navigationOverlayView: NavigationOverlayView)
    func navigationOverlayViewWillChangeSnapshot(_ navigationView: NavigationView)
    func navigationOverlayViewDidChangeSnapshot(_ navigationOverlayView: NavigationOverlayView)
    func navigationOverlayView(_ navigationView: NavigationView, didValidateBoundsFor tableView: UITableView)
}


// MARK: - NavigationOverlayView

final class NavigationOverlayView: UIView, Nibable {
    
    // MARK: Category
    
    @objc enum Category: Int, Valuable, CaseIterable {
        
        case home,
             myList = 6,
             blockbusters = 5,
             action = 3,
             scienceFiction,
             crime = 7,
             thrillers,
             adventure,
             comedy,
             drama,
             horror,
             anime,
             familyNchildren,
             documentary
        
        var stringValue: String {
            switch self {
            case .home: return "Home"
            case .myList: return "My List"
            case .action: return "Action"
            case .anime: return "Anime"
            case .blockbusters: return "Blockbusters"
            case .familyNchildren: return "Family & Children"
            case .comedy: return "Comedy"
            case .documentary: return "Documentary"
            case .drama: return "Drama"
            case .horror: return "Horror"
            case .thrillers: return "Thriller"
            case .scienceFiction: return "Sci-Fi"
            case .adventure: return "Adventure"
            case .crime: return "Crime"
            }
        }
    }
    
    
    // MARK: Snapshot
    
    enum Snapshot: Int {
        case state
        case category
    }
    
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private(set) weak var tableView: UITableView! = nil
    @IBOutlet private(set) weak var tableViewHeightConstraint: NSLayoutConstraint! = nil
    @IBOutlet private weak var messageLabel: UILabel! = nil
    @IBOutlet private(set) weak var dismissButton: UIButton! = nil
    
    var currentSnapshot: Snapshot = .state {
        didSet {
            guard let delegate = delegate else { return }
            delegate.navigationOverlayViewDidChangeSnapshot(self)
        }
    }
    
    var state: NavigationView.State = .tvShows
    var category: Category = .home
    
    var showsOverlay: Bool = false {
        didSet {
            guard let delegate = delegate else { return }
            showsOverlay
                ? delegate.navigationOverlayViewDidShow(self)
                : delegate.navigationOverlayViewDidHide(self)
        }
    }
    
    private(set) var blurryView: BlurryView! = nil
    
    private(set) var snapshot: NavigationOverlayViewTableViewSnapshot! = nil
    
    private(set) weak var delegate: NavigationOverlayViewDelegate! = nil
    
    weak var homeViewController: HomeViewController! = nil {
        didSet {
            guard blurryView == nil else { return }
            blurryView = BlurryView(frame: UIScreen.main.bounds, contentView)
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
        self.delegate.navigationOverlayViewDidChangeSnapshot(self)
    }
    
    deinit {
        snapshot = nil
        delegate = nil
        homeViewController = nil
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func dismiss(_ sender: UIButton) {
        guard let delegate = delegate else { return }
        delegate.navigationOverlayViewDidHide(self)
    }
}


// MARK: - NavigationOverlayViewDelegate Implemetation

extension NavigationOverlayView: NavigationOverlayViewDelegate {
    
    func navigationOverlayViewDidShow(_ navigationOverlayView: NavigationOverlayView) {
        guard
            let homeViewController = navigationOverlayView.homeViewController,
            let tabBarController = homeViewController.tabBarController
        else { return }
        UIView.animate(withDuration: 0.33) {
            navigationOverlayView.alpha = 1.0
            tabBarController.tabBar.alpha = 0.0
        }
    }
    
    func navigationOverlayViewDidHide(_ navigationOverlayView: NavigationOverlayView) {
        guard
            let homeViewController = navigationOverlayView.homeViewController,
            let tabBarController = homeViewController.tabBarController
        else { return }
        UIView.animate(withDuration: 0.33) {
            navigationOverlayView.alpha = 0.0
            tabBarController.tabBar.alpha = 1.0
        }
    }
    
    
    func navigationOverlayViewWillChangeSnapshot(_ navigationView: NavigationView) {
        guard
            let state = navigationView.state as NavigationView.State?,
            let homeViewController = navigationView.homeViewController,
            let navigationOverlayView = homeViewController.navigationOverlayView
        else { return }
        switch state {
        case .home,
                .tvShows,
                .movies:
            navigationOverlayView.currentSnapshot = .state
        case .categories,
                .tvShowsAllCategories,
                .moviesAllCategories:
            navigationOverlayView.currentSnapshot = .category
        }
    }
    
    func navigationOverlayViewDidChangeSnapshot(_ navigationOverlayView: NavigationOverlayView) {
        snapshot = nil
        switch currentSnapshot {
        case .state:
            var states = NavigationView.State.allCases
            let slice = states[0..<3]
            states = Array(slice)
            snapshot = NavigationOverlayViewTableViewSnapshot(items: states, navigationOverlayView: self)
        case .category:
            let categories = Category.allCases
            snapshot = NavigationOverlayViewTableViewSnapshot(items: categories, navigationOverlayView: self)
        }
        tableView.delegate = snapshot
        tableView.dataSource = snapshot
        tableView.reloadData()
    }
    
    func navigationOverlayView(_ navigationView: NavigationView, didValidateBoundsFor tableView: UITableView) {
        guard
            let state = navigationView.state as NavigationView.State?,
            let homeViewController = navigationView.homeViewController,
            let navigationOverlayView = homeViewController.navigationOverlayView,
            let tableViewHeightConstraint = navigationOverlayView.tableViewHeightConstraint
        else { return }
        let rowHeight = CGFloat(64.0)
        switch state {
        case .home,
                .tvShows,
                .movies:
            tableView.contentInset = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: .zero)
            tableViewHeightConstraint.constant = max(rowHeight,
                                                     rowHeight * CGFloat(navigationOverlayView.snapshot.items.count))
        case .categories,
                .tvShowsAllCategories,
                .moviesAllCategories:
            tableView.contentInset = UIEdgeInsets(top: rowHeight, left: .zero, bottom: rowHeight * 2, right: .zero)
            tableViewHeightConstraint.constant = max(rowHeight,
                                                     rowHeight * CGFloat(navigationOverlayView.snapshot.items.count))
        }
    }
}
