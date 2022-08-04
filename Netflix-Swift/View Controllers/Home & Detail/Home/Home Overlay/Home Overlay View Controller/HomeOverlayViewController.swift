//
//  HomeOverlayViewController.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 30/03/2022.
//

import UIKit

// MARK: - HomeOverlayDataSet & HomeOverlaySnapshot

typealias HomeOverlayDataSet = CollectionViewSnapshotDataSet<StandardCollectionViewCell>
typealias HomeOverlaySnapshot = CollectionViewSnapshot<StandardCollectionViewCell, HomeOverlayDataSet>


// MARK: - HomeOverlayViewControllerDelegate

protocol HomeOverlayViewControllerDelegate: AnyObject {
    func homeOverlayViewControllerDidShow(_ homeOverlayViewController: HomeOverlayViewController)
    func homeOverlayViewControllerDidHide(_ homeOverlayViewController: HomeOverlayViewController)
}


// MARK: - HomeOverlayViewController

final class HomeOverlayViewController: PrototypeViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView! = nil
    
    var dataSet: HomeOverlayDataSet! = nil
    var snapshot: HomeOverlaySnapshot! = nil
    
    var showsOverlay = false {
        didSet {
            guard let delegate = delegate else { return }
            showsOverlay
                ? delegate.homeOverlayViewControllerDidShow(self)
                : delegate.homeOverlayViewControllerDidHide(self)
        }
    }
    
    weak var homeViewController: HomeViewController! = nil
    weak var delegate: HomeOverlayViewControllerDelegate! = nil
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let layout = ComputableFlowLayout(.homeOverlay, .vertical)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
        self.collectionView.register(StandardCollectionViewCell.nib,
                                     forCellWithReuseIdentifier: StandardCollectionViewCell.reuseIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let homeViewController = homeViewController else { return }
        switch segue.destination {
        case let navigationController as UINavigationController:
            let destination = navigationController.viewControllers.first as! DetailViewController
            destination.homeViewController = homeViewController
        default: return
        }
    }
}


// MARK: - HomeOverlayViewControllerDelegate Implementation

extension HomeOverlayViewController: HomeOverlayViewControllerDelegate {
    
    func homeOverlayViewControllerDidShow(_ homeOverlayViewController: HomeOverlayViewController) {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut) { [weak self] in
            guard
                let self = self,
                let homeViewController = self.homeViewController,
                let navigationView = homeViewController.navigationView,
                let navigationOverlayView = homeViewController.navigationOverlayView,
                let statusBarBackgroundView = homeViewController.statusBarBackgroundView,
                let statusBarBackgroundViewDelegate = statusBarBackgroundView.delegate
            else { return }
            navigationOverlayView.dismiss(navigationOverlayView.dismissButton)
            homeViewController.homeOverlayContainerViewTop.constant = 0.0
            homeViewController.homeOverlayContainerView.alpha = 1.0
            navigationView.backgroundColor = .black
            statusBarBackgroundViewDelegate.statusBarBackgroundView(statusBarBackgroundView,
                                                                    willChange: .black,
                                                                    withAlphaComponent: 1.0)
            homeViewController.view.layoutIfNeeded()
        }
    }
    
    func homeOverlayViewControllerDidHide(_ homeOverlayViewController: HomeOverlayViewController) {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut) { [weak self] in
            guard
                let self = self,
                let homeViewController = self.homeViewController,
                let navigationView = homeViewController.navigationView,
                let statusBarBackgroundView = homeViewController.statusBarBackgroundView,
                let statusBarBackgroundViewDelegate = statusBarBackgroundView.delegate
            else { return }
            homeViewController.homeOverlayContainerViewTop.constant = homeViewController.homeOverlayContainerView.bounds.size.height
            homeViewController.homeOverlayContainerView.alpha = 0.0
            navigationView.backgroundColor = .clear
            statusBarBackgroundViewDelegate.statusBarBackgroundView(statusBarBackgroundView,
                                                                    willChange: .black,
                                                                    withAlphaComponent: 0.75)
            homeViewController.view.layoutIfNeeded()
        }
        dataSet = nil
        snapshot = nil
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.prefetchDataSource = nil
    }
}
