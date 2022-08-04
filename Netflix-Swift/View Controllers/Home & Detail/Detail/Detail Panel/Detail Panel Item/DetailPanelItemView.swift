//
//  DetailPanelItemView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/03/2022.
//

import UIKit

// MARK: - DetailPanelItemConfigurationDelegate

@objc private protocol DetailPanelItemConfigurationDelegate: AnyObject {
    func configurationDidRegisterRecognizers(_ configuration: DetailPanelItemConfiguration)
    @objc func detailPanelItemDidTap(_ sender: Any)
    @objc func detailPanelItemDidLongPress(_ sender: Any)
}


// MARK: - DetailPanelItemConfiguration

@objc private final class DetailPanelItemConfiguration: NSObject {
    
    // MARK: GestureRecognizer
    
    fileprivate enum GestureRecognizer {
        case tap, longPress
    }
    
    
    // MARK: Item
    
    fileprivate enum Item: Int {
        case myList, rate, share
    }
    
    
    // MARK: Properties
    
    fileprivate var gestureRecognizer: GestureRecognizer = .tap
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer! = nil
    fileprivate var longPressGestureRecignizer: UILongPressGestureRecognizer! = nil
    
    weak var item: DetailPanelItem! = nil
    weak var delegate: DetailPanelItemConfigurationDelegate! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    convenience init(_ detailPanelItem: DetailPanelItem) {
        self.init()
        self.item = detailPanelItem
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


// MARK: - DetailPanelItemConfigurationDelegate Implementation

extension DetailPanelItemConfiguration: DetailPanelItemConfigurationDelegate {
    
    func configurationDidRegisterRecognizers(_ configuration: DetailPanelItemConfiguration) {
        guard
            let delegate = delegate,
            let item = item
        else { return }
        tapGestureRecognizer = UITapGestureRecognizer(target: delegate,
                                     action: #selector(delegate.detailPanelItemDidTap(_:)))
        longPressGestureRecignizer = UILongPressGestureRecognizer(target: delegate,
                                           action: #selector(delegate.detailPanelItemDidLongPress(_:)))
        item.addGestureRecognizer(tapGestureRecognizer)
        item.addGestureRecognizer(longPressGestureRecignizer)
    }
    
    @objc func detailPanelItemDidTap(_ sender: Any) {
        guard
            let item = item,
            let detailViewController = item.detailViewController,
            let homeViewController = detailViewController.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?,
            let configurationItem = DetailPanelItemConfiguration.Item(rawValue: item.tag),
            let homeOverlayViewController = homeViewController.homeOverlayViewController
        else { return }
        gestureRecognizer = .tap
        item.contentView.setAlphaAnimation(using: gestureRecognizer == .tap
                                            ? tapGestureRecognizer
                                            : longPressGestureRecignizer)
        switch configurationItem {
        case .myList:
            if let snapshot = homeViewModel.snapshot {
                homeViewModel
                    .myList
                    .shouldInsertOrRemove(homeViewModel.detailMedia!,
                                          for: homeViewModel.currentSnapshot == .tvShows ? .tvShows : .movies,
                                          insertObjectTo: &homeViewController.homeViewModel.myList.data)
                homeViewController.tableView.reloadRows(at: [.first], with: .automatic)
                DispatchQueue.main.async {
                    snapshot.myListCell?.collectionView?.reloadData()
                }
                homeOverlayViewController.dataSet = HomeOverlayDataSet(homeViewController.homeViewModel.section(at: .myList),
                                                          homeViewController: homeViewController,
                                                          homeOverlayItems: Array(homeViewController.homeViewModel.myList.data),
                                                          homeOverlayViewController: homeOverlayViewController)
                homeOverlayViewController.snapshot = HomeOverlaySnapshot(homeOverlayViewController.dataSet, homeViewController)
                homeOverlayViewController.collectionView.delegate = homeOverlayViewController.snapshot
                homeOverlayViewController.collectionView.dataSource = homeOverlayViewController.snapshot
                homeOverlayViewController.collectionView.prefetchDataSource = homeOverlayViewController.snapshot
                homeOverlayViewController.collectionView.reloadData()
            }
            item.isMyListButtonSelected.toggle()
        case .rate:
            item.isRateButtonSelected.toggle()
        case .share:
            break
        }
    }
    
    @objc func detailPanelItemDidLongPress(_ sender: Any) {
        guard
            let item = item,
            let configurationItem = DetailPanelItemConfiguration.Item(rawValue: item.tag)
        else { return }
        gestureRecognizer = .longPress
        item.contentView.setAlphaAnimation(using: gestureRecognizer == .tap
                                                ? tapGestureRecognizer
                                                : longPressGestureRecignizer)
        switch configurationItem {
        case .myList: print(gestureRecognizer, item, configurationItem.rawValue)
        case .rate: print(gestureRecognizer, item, configurationItem.rawValue)
        case .share: print(gestureRecognizer, item, configurationItem.rawValue)
        }
        item.isMyListButtonSelected.toggle()
    }
}


// MARK: - DetailPanelItemDelegate

protocol DetailPanelItemDelegate: AnyObject {
    func selectItemIfNeeded()
    func prepareForReuse()
}


// MARK: - DetailPanelItem

class DetailPanelItem: UIView {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private(set) weak var titleLabel: UILabel! = nil
    @IBOutlet private(set) weak var imageView: UIImageView! = nil
    
    open var isMyListButtonSelected = false
    open var isRateButtonSelected = false
    open var systemImage: String! = nil
    open var title: String! = nil
    
    fileprivate var configuration: DetailPanelItemConfiguration! = nil
    fileprivate weak var delegate: DetailPanelItemDelegate! = nil
    
    weak var detailViewController: DetailViewController! = nil {
        didSet {
            guard let delegate = delegate else { return }
            delegate.selectItemIfNeeded()
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configuration = .init(self)
        self.delegate = self
    }
    
    deinit {
        systemImage = nil
        title = nil
        delegate = nil
        detailViewController = nil
    }
}


// MARK: - DetailPanelItemDelegate Implementation

extension DetailPanelItem: DetailPanelItemDelegate {
    
    func selectItemIfNeeded() {
        guard
            let detailViewController = detailViewController,
            let homeViewController = detailViewController.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else { return }
        homeViewModel.myList.data.contains(homeViewModel.detailMedia!)
            ? { isMyListButtonSelected = true }()
            : { isMyListButtonSelected = false }()
    }
    
    func prepareForReuse() {
        systemImage = nil
        title = nil
        isMyListButtonSelected = false
        isRateButtonSelected = false
    }
}


// MARK: - PanelItemView

final class DetailPanelItemView: DetailPanelItem, Nibable {
    
    // MARK: Properties
    
    override var isMyListButtonSelected: Bool {
        didSet {
            guard
                let systemImage = systemImage,
                let title = title
            else { return }
            imageView.image = UIImage(systemName: systemImage)
            titleLabel.text = title
        }
    }
    
    override var isRateButtonSelected: Bool {
        didSet {
            guard
                let systemImage = systemImage,
                let title = title
            else { return }
            imageView.image = UIImage(systemName: systemImage)
            titleLabel.text = title
        }
    }
    
    override var systemImage: String? {
        get {
            let myListImage = !isMyListButtonSelected ? "plus" : "checkmark"
            let rateImage = !isRateButtonSelected ? "hand.thumbsup" : "hand.thumbsup.fill"
            let shareImage = "square.and.arrow.up"
            guard let item = DetailPanelItemConfiguration.Item(rawValue: tag) else { return nil }
            switch item {
            case .myList: return myListImage
            case .rate: return rateImage
            case .share: return shareImage
            }
        }
        set {}
    }
    
    override var title: String? {
        get {
            let myListImage = "My List"
            let rateImage = "Rate"
            let shareImage = "Share"
            guard let item = DetailPanelItemConfiguration.Item(rawValue: tag) else { return nil }
            switch item {
            case .myList: return myListImage
            case .rate: return rateImage
            case .share: return shareImage
            }
        }
        set {}
    }
    
    
    // MARK: Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate.prepareForReuse()
    }
}
