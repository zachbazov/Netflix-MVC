//
//  NavigationItemView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 23/03/2022.
//

import UIKit

// MARK: - NavigationItemConfigurationDelegate

@objc private protocol NavigationItemConfigurationDelegate: AnyObject {
    
    func configurationDidRegisterRecognizers(_ configuration: NavigationItemConfiguration)
    
    
    @objc func navigationItemDidTap(_ navigationItem: Any)
    
    @objc func navigationItemDidLongPress(_ navigationItem: NavigationItem)
}



// MARK: - NavigationItemConfiguration

private final class NavigationItemConfiguration: NSObject {
    
    // MARK: GestureRecognizer
    
    fileprivate enum GestureRecognizer {
        case tap, longPress
    }
    
    
    // MARK: Properties
    
    fileprivate var gestureRecognizer: GestureRecognizer = .tap
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer! = nil
    
    fileprivate var longPressGestureRecignizer: UILongPressGestureRecognizer! = nil
    
    
    private weak var item: NavigationItem! = nil
    
    
    private weak var delegate: NavigationItemConfigurationDelegate! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    fileprivate convenience init(_ item: NavigationItem) {
        self.init()
        self.item = item
        
        self.delegate = self
        self.configurationDidRegisterRecognizers(self)
    }
    
    deinit {
        tapGestureRecognizer = nil
        longPressGestureRecignizer = nil
        
        delegate = nil
        item = nil
    }
}



// MARK: - NavigationItemConfigurationDelegate Implementation

extension NavigationItemConfiguration: NavigationItemConfigurationDelegate {
    
    func navigationItemDidTap(_ navigationItem: Any) {
        guard
            let item = item,
            let homeViewController = item.homeViewController,
            let navigationView = homeViewController.navigationView,
            let itemDelegate = item.delegate,
            let navigationViewDelegate = navigationView.delegate
        else {
            return
        }
        
        gestureRecognizer = .tap
        
        item.contentView.setAlphaAnimation(using: gestureRecognizer == .tap
                                           ? tapGestureRecognizer
                                           : longPressGestureRecignizer)
        
        navigationViewDelegate.navigationView(navigationView, didSelect: item)
        
        itemDelegate.navigationItemWillPerformAnimations(item) { homeViewModel, navigationView in
            
            guard let tableViewSnapshotDelegate = homeViewModel.tableViewSnapshotDelegate else {
                return
            }
            
            tableViewSnapshotDelegate.tableViewDidInstantiateSnapshot!(navigationView.state == .tvShows
                                                                       ? .tvShows
                                                                       : .movies)
        }
        
        item.isSelected.toggle()
    }
    
    func navigationItemDidLongPress(_ navigationItem: NavigationItem) {
        guard let item = item else {
            return
        }
        
        gestureRecognizer = .longPress
        
        item.contentView.setAlphaAnimation(using: gestureRecognizer == .tap
                                           ? tapGestureRecognizer
                                           : longPressGestureRecignizer)
        
        item.isSelected.toggle()
    }
    
    
    func configurationDidRegisterRecognizers(_ configuration: NavigationItemConfiguration) {
        guard
            let item = item,
            let delegate = delegate
        else {
            return
        }
        
        tapGestureRecognizer = UITapGestureRecognizer(target: delegate,
                                                      action: #selector(delegate.navigationItemDidTap(_:)))
        
        longPressGestureRecignizer = UILongPressGestureRecognizer(target: delegate,
                                                                  action: #selector(delegate.navigationItemDidLongPress(_:)))
        
        item.addGestureRecognizer(tapGestureRecognizer)
        item.addGestureRecognizer(longPressGestureRecignizer)
    }
}



// MARK: - NavigationItemDelegate

protocol NavigationItemDelegate: AnyObject {
    
    func navigationItemWillPerformAnimations(_ navigationItem: NavigationItem,
                                             withCompletionBlock completion: @escaping (HomeViewModel, NavigationView) -> Void)
    
    func navigationItem(_ navigationItem: NavigationItem,
                        imageForItem image: UIImage)
    
    func navigationItemDidChangeSizeForTitle(_ navigationItem: NavigationItem)
    
    func navigationItemDidConfigure(_ navigationItem: NavigationItem)
    
    func navigationItemDidEntitle(_ navigationItem: NavigationItem)
    
    func navigationItemWillBeginReusing(_ navigationItem: NavigationItem)
}



// MARK: - NavigationItem

class NavigationItem: UIView {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    
    @IBOutlet private(set) weak var titleLabel: UILabel! = nil
    
    
    open var isSelected = false
    
    open var systemImage: String! = nil
    
    open var title: String! = nil
    
    open var imageView: UIImageView! = nil
    
    
    fileprivate var configuration: NavigationItemConfiguration!  = nil
    
    
    private(set) weak var delegate: NavigationItemDelegate! = nil
    
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.configuration = .init(self)
        
        self.delegate = self
    }
    
    deinit {
        configuration = nil
        delegate = nil
        homeViewController = nil
    }
}



// MARK: - NavigationItemDelegate Implementation

extension NavigationItem: NavigationItemDelegate {
    
    func navigationItemWillPerformAnimations(_ navigationItem: NavigationItem,
                                             withCompletionBlock completion: @escaping (HomeViewModel, NavigationView) -> Void) {
        guard
            let homeViewController = homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?,
            let navigationView = homeViewController.navigationView,
            let placeholderView = homeViewController.placeholderView,
            let tableView = homeViewController.tableView,
            let snapshotDelegate = homeViewModel.snapshot.delegate,
            let placeholderViewDelegate = placeholderView.delegate
        else {
            return
        }
        
        switch navigationView.state {
        case .tvShows:
            guard homeViewModel.currentSnapshot != .tvShows else { return }
            
        case .movies:
            guard homeViewModel.currentSnapshot != .movies else { return }
            
        default: return
        }
        
        placeholderViewDelegate.placeholderViewDidShow(tableView)
        snapshotDelegate.tableViewDidHide?(tableView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            completion(homeViewModel, navigationView)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                
                placeholderViewDelegate.placeholderViewDidHide(tableView)
                snapshotDelegate.tableViewDidShow?(tableView)
            }
        }
    }
    
    func navigationItem(_ navigationItem: NavigationItem, imageForItem image: UIImage) {
        navigationItem.imageView.image = image
    }
    
    func navigationItemDidChangeSizeForTitle(_ navigationItem: NavigationItem) {
        guard let state: NavigationView.State = .init(rawValue: navigationItem.tag) else {
            return
        }
        
        switch state {
        case .tvShowsAllCategories,
                .moviesAllCategories:
            
            let size = CGFloat(13)
            navigationItem.titleLabel.font = UIFont.systemFont(ofSize: size)
            
        default: return
        }
    }
    
    func navigationItemDidConfigure(_ navigationItem: NavigationItem) {
        guard let delegate = delegate else {
            return
        }
        
        let image: UIImage! = .init(systemName: navigationItem.systemImage)
        
        delegate.navigationItem(self, imageForItem: image)
        delegate.navigationItemDidChangeSizeForTitle(self)
    }
    
    func navigationItemDidEntitle(_ navigationItem: NavigationItem) {
        navigationItem.titleLabel.text = navigationItem.title
    }
    
    func navigationItemWillBeginReusing(_ navigationItem: NavigationItem) {
        navigationItem.systemImage = nil
        navigationItem.title = nil
        navigationItem.isSelected = false
    }
}



// MARK: - NavigationItemView

final class NavigationItemView: NavigationItem, Nibable {
    
    // MARK: Properties
    
    override var isSelected: Bool {
        didSet {
            guard let delegate = delegate else {
                return
            }
            
            delegate.navigationItemDidEntitle(self)
        }
    }
    
    override var systemImage: String! {
        get {
            guard
                let state: NavigationView.State = .init(rawValue: tag),
                let systemImage = "arrowtriangle.down.fill" as String?
            else {
                return nil
            }
            
            switch state {
            case .categories:
                imageView.alpha = 1.0
                
            default:
                imageView.alpha = 0.0
            }
            
            return systemImage
        }
        set {}
    }
    
    override var title: String! {
        get {
            guard let state: NavigationView.State = .init(rawValue: tag) else {
                return nil
            }
            
            switch state {
            case .home: return ""
            case .tvShows: return "TV Shows"
            case .movies: return "Movies"
            case .categories: return "Categories"
            case .tvShowsAllCategories: return "All Categories"
            case .moviesAllCategories: return "All Categories"
            }
        }
        set {}
    }
    
    
    // MARK: Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.loadNib()
        
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.navigationItemWillBeginReusing(self)
        
        
        self.imageView = .init(frame: .zero)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.tintColor = .white
        
        self.contentView.addSubview(imageView)
        
        
        delegate.navigationItemDidConfigure(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 2),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
}
