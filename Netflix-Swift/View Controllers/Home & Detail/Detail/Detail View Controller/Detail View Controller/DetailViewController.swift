//
//  DetailViewController.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 10/03/2022.
//

import AVKit

// MARK: - DetailDataSet & DetailSnapshot

typealias DetailDataSet = CollectionViewSnapshotDataSet<StandardCollectionViewCell>

typealias DetailSnapshot = CollectionViewSnapshot<StandardCollectionViewCell, DetailDataSet>



// MARK: - DetailViewController

final class DetailViewController: PrototypeViewController {
    
    // MARK: Properties
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    
    
    @IBOutlet private(set) weak var scrollView: UIScrollView! = nil
    
    @IBOutlet private(set) weak var contentView: UIView! = nil
    
    @IBOutlet private(set) weak var detailPreviewView: DetailPreviewView! = nil
    
    @IBOutlet private weak var detailInfoView: DetailInfoView! = nil
    
    @IBOutlet private weak var detailDescriptionView: DetailDescriptionView! = nil
    
    @IBOutlet private(set) weak var detailPanelView: DetailPanelView! = nil
    
    @IBOutlet private weak var detailNavigationView: DetailNavigationView! = nil
    
    @IBOutlet private(set) weak var collectionView: UICollectionView! = nil
    
    @IBOutlet private weak var maskView: MaskView! = nil
    
    @IBOutlet private(set) weak var contentViewHeightConstraint: NSLayoutConstraint! = nil
    
    
    private(set) var flowLayout: ComputableFlowLayout! = nil
    
    
    fileprivate var dataSet: DetailDataSet! = nil
    
    fileprivate var snapshot: DetailSnapshot! = nil
    
    
    private(set) var detailViewModel: DetailViewModel = .init()
    
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        flowLayout = .init(.detail, .vertical)
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        
        collectionView.register(StandardCollectionViewCell.nib,
                                forCellWithReuseIdentifier: StandardCollectionViewCell.reuseIdentifier)
        
        guard let section = detailViewModel.section else {
            return
        }
        
        dataSet = .init(section, withDetailViewController: self)
        
        snapshot = .init(dataSet, with: homeViewController)
        
        collectionView.delegate = snapshot
        collectionView.dataSource = snapshot
        collectionView.prefetchDataSource = snapshot
        
        
        guard let detailViewModelDelegate = detailViewModel.delegate else {
            return
        }
        
        detailViewModelDelegate.detailViewModelDidValidateScrollViewBounds(scrollView,
                                                                           with: contentViewHeightConstraint)
        
        
        WeakInjector.shared.inject([detailPreviewView,
                                    detailInfoView,
                                    detailDescriptionView,
                                    detailPanelView],
                                   with: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.orientation = .all
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AppDelegate.orientation = .portrait
        
        guard let homeViewController = homeViewController else {
            return
        }
        
        homeViewController.detailViewController = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (UIUserInterfaceSizeClass.regular, UIUserInterfaceSizeClass.regular):
            return
            
        case (UIUserInterfaceSizeClass.compact, UIUserInterfaceSizeClass.regular):
            detailPreviewView.imageView.alpha = 1.0
            
        case (UIUserInterfaceSizeClass.regular, UIUserInterfaceSizeClass.compact),
            (UIUserInterfaceSizeClass.compact, UIUserInterfaceSizeClass.compact):
            detailPreviewView.imageView.alpha = 0.0
            
        default: return
        }
    }
    
    
    // MARK: Deinitialization
    
    deinit {
        guard let mediaPlayerViewDelegate = detailPreviewView.mediaPlayerView.delegate else {
            return
        }
        
        mediaPlayerViewDelegate.mediaPlayerWillStopPlaying(detailPreviewView.mediaPlayerView.mediaPlayer)
        
        WeakInjector.shared.eject([detailPreviewView,
                                   detailInfoView,
                                   detailDescriptionView,
                                   detailPanelView])
        
        dataSet = nil
        snapshot = nil
        
        detailViewModel.scheduledTimer?.delegate.invalidateTimer()
        
        detailViewModel.section = nil
        detailViewModel.detailViewController = nil
        
        homeViewController = nil
    }
}
