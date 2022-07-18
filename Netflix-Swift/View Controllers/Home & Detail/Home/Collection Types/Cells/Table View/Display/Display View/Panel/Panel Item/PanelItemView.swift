//
//  PanelItemView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/02/2022.
//

import UIKit

// MARK: - PanelItemConfigurationDelegate

@objc private protocol PanelItemConfigurationDelegate: AnyObject {
    
    func configurationDidRegisterRecognizers(_ configuration: PanelItemConfiguration)
    
    
    @objc func panelItemDidTap(_ panelItem: PanelItem)
    
    @objc func panelItemDidLongPress(_ panelItem: PanelItem)
}



// MARK: - PanelItemConfiguration

private final class PanelItemConfiguration: NSObject {
    
    // MARK: GestureRecognizer
    
    fileprivate enum GestureRecognizer {
        case tap, longPress
    }
    
    
    // MARK: Item
    
    fileprivate enum Item: Int {
        case myList, info
    }
    
    
    // MARK: Properties
    
    fileprivate var gestureRecognizer: GestureRecognizer = .tap
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer! = nil
    
    fileprivate var longPressGestureRecignizer: UILongPressGestureRecognizer! = nil
    
    
    private weak var item: PanelItem! = nil
    
    
    fileprivate weak var delegate: PanelItemConfigurationDelegate! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    convenience init(_ item: PanelItem) {
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



// MARK: - PanelItemConfigurationDelegate Implementation

extension PanelItemConfiguration: PanelItemConfigurationDelegate {
    
    func configurationDidRegisterRecognizers(_ configuration: PanelItemConfiguration) {
        guard
            let item = item,
            let delegate = delegate
        else {
            return
        }
        
        tapGestureRecognizer = UITapGestureRecognizer(target: delegate,
                                                      action: #selector(delegate.panelItemDidTap(_:)))
        
        longPressGestureRecignizer = UILongPressGestureRecognizer(target: delegate,
                                                                  action: #selector(delegate.panelItemDidLongPress(_:)))
        
        item.addGestureRecognizer(tapGestureRecognizer)
        item.addGestureRecognizer(longPressGestureRecignizer)
    }
    
    
    func panelItemDidTap(_ panelItem: PanelItem) {
        guard
            let item = item,
            let homeViewController = item.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else {
            return
        }
        
        guard let itemTag = PanelItemConfiguration.Item(rawValue: item.tag) else {
            return
        }
        
        gestureRecognizer = .tap
        
        item.contentView.setAlphaAnimation(using: gestureRecognizer == .tap
                                                 ? tapGestureRecognizer
                                                 : longPressGestureRecignizer)
        
        switch itemTag {
        case .myList:
            if let snapshot = homeViewModel.snapshot {
                homeViewModel
                    .myList
                    .shouldInsertOrRemove(homeViewModel.displayMedia!,
                                          for: homeViewModel.currentSnapshot == .tvShows
                                            ? .tvShows : .movies,
                                          insertObjectTo: &homeViewController.homeViewModel.myList.data)
                
                DispatchQueue.main.async {
                    snapshot.myListCell?.collectionView.reloadData()
                }
            }
            
        case .info:
            homeViewModel.detailMedia = homeViewModel.displayMedia
            
            homeViewController.segue.current = .detail
            
            let genre = homeViewModel.detailMedia!.genres!.first!
            
            _ = SectionIndices.allCases.contains { index in
                guard let detailViewController = homeViewController.detailViewController else {
                    return false
                }
                
                detailViewController.detailViewModel.section = homeViewModel.section(at: index)
                
                return index.stringValue == genre
            }
        }
        
        item.isSelected.toggle()
    }
    
    func panelItemDidLongPress(_ panelItem: PanelItem) {
        guard
            let item = item,
            let itemTag = PanelItemConfiguration.Item(rawValue: item.tag) else {
            return
        }
        
        gestureRecognizer = .longPress
        
        item.contentView.setAlphaAnimation(using: gestureRecognizer == .tap
                                                 ? tapGestureRecognizer
                                                 : longPressGestureRecignizer)
        
        switch itemTag {
        case .myList: print(gestureRecognizer, itemTag, itemTag.rawValue)
        case .info: print(gestureRecognizer, itemTag, itemTag.rawValue)
        }
        
        item.isSelected.toggle()
    }
}



// MARK: - PanelItemDelegate

private protocol PanelItemDelegate: AnyObject {
    
    func panelItemDidConfigureTitle(_ panelItem: PanelItem)
    
    func panelItemDidConfigureImage(_ panelItem: PanelItem)
    
    
    func selectIfNeeded()
}



// MARK: - PanelItem

class PanelItem: UIView {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    
    @IBOutlet private(set) weak var titleLabel: UILabel! = nil
    
    @IBOutlet private(set) weak var imageView: UIImageView! = nil
    
    
    open var isSelected = false
    
    open var systemImage: String! = nil
    
    open var title: String! = nil
    
    
    fileprivate var configuration: PanelItemConfiguration! = nil
    
    fileprivate weak var delegate: PanelItemDelegate! = nil
    
    
    weak var homeViewController: HomeViewController! = nil {
        didSet {
            delegate?.selectIfNeeded()
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.configuration = .init(self)
        
        self.delegate = self
    }
    
    deinit {
        delegate = nil
        homeViewController = nil
    }
}



// MARK: PanelItemDelegate Implementation

extension PanelItem: PanelItemDelegate {
    
    func panelItemDidConfigureTitle(_ panelItem: PanelItem) {
        panelItem.imageView.image = UIImage(systemName: systemImage!)!
    }
    
    func panelItemDidConfigureImage(_ panelItem: PanelItem) {
        panelItem.titleLabel.text = title!
    }
    
    fileprivate func selectIfNeeded() {
        guard
            let homeViewController = homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?,
            let item: PanelItemConfiguration.Item = .init(rawValue: tag)
        else {
            return
        }
        
        switch item {
        case .myList:
            homeViewModel.myList.data.contains(homeViewModel.displayMedia!)
                ? { isSelected = true }()
                : { isSelected = false }()
            
        default: return
        }
    }
}



// MARK: - PanelItemView

final class PanelItemView: PanelItem, Nibable {
    
    // MARK: Properties
    
    override var isSelected: Bool {
        didSet {
            guard let delegate = delegate else {
                return
            }
            
            delegate.panelItemDidConfigureImage(self)
            delegate.panelItemDidConfigureTitle(self)
        }
    }
    
    override var systemImage: String! {
        get {
            let leadingButton = !isSelected ? "plus" : "checkmark"
            let trailingButton = "info.circle"
            
            return tag == 0 ? leadingButton : trailingButton
        }
        set {}
    }
    
    override var title: String! {
        get {
            let leadingButton = "My List"
            let trailingButton = "Info"
            
            return tag == 0 ? leadingButton : trailingButton
        }
        set {}
    }
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.loadNib()
        
        self.prepareForReuse()
    }
    
    
    // MARK: Methods
    
    func prepareForReuse() {
        systemImage = nil
        title = nil
        isSelected = false
    }
}
