//
//  DetailViewModel.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 06/04/2022.
//

import UIKit

// MARK: - DetailViewModelDelegate

protocol DetailViewModelDelegate: AnyObject {
    
    func detailViewModelDidPopulateMediaForSection(_ detailViewModel: DetailViewModel)
    
    func detailViewModelDidValidateScrollViewBounds(_ scrollView: UIScrollView,
                                                    with constraint: NSLayoutConstraint)
}



// MARK: - DetailViewModel

final class DetailViewModel {
    
    // MARK: Properties
    
    var scheduledTimer: ScheduledTimer! = nil
    
    
    var section: SectionViewModel! = nil
    
    
    weak var delegate: DetailViewModelDelegate! = nil
    
    
    weak var detailViewController: DetailViewController! = nil {
        didSet {
            guard let delegate = delegate else {
                return
            }
            
            delegate.detailViewModelDidPopulateMediaForSection(self)
            
            guard let detailViewController = detailViewController else {
                return
            }
            
            scheduledTimer = .init(.mediaOverlay, with: detailViewController)
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    init() {
        self.delegate = self
    }
    
    deinit {
        section = nil
        scheduledTimer = nil
        
        delegate = nil
        detailViewController = nil
    }
}



// MARK: - DetailViewModelDelegate Implementation

extension DetailViewModel: DetailViewModelDelegate {
    
    func detailViewModelDidPopulateMediaForSection(_ detailViewModel: DetailViewModel) {
        guard
            let detailViewController = detailViewController as DetailViewController?,
            let homeViewController = detailViewController.homeViewController,
            let detailViewModel = detailViewController.detailViewModel as DetailViewModel?,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else {
            return
        }
        
        let media = homeViewModel.detailMedia
        
        switch homeViewModel.currentSnapshot {
        case .tvShows:
            detailViewModel.section = homeViewModel.tvShows.first(where: { section in
                return section.title.elementsEqual(media!.genres!.first!)
            })
            
        case .movies:
            detailViewModel.section = homeViewModel.movies.first(where: { section in
                return section.title.elementsEqual(media!.genres!.first!)
            })
        }
    }
    
    func detailViewModelDidValidateScrollViewBounds(_ scrollView: UIScrollView,
                                                    with constraint: NSLayoutConstraint) {
        guard
            let detailViewController = detailViewController,
            let homeViewModel = detailViewController.homeViewController.homeViewModel as HomeViewModel?,
            let itemsPerLine = detailViewController.flowLayout.itemsPerLine as Int?,
            let section = section
        else {
            return
        }
        
        let cellHeight: CGFloat = detailViewController.flowLayout.height
        
        let moviesCount = CGFloat(homeViewModel.currentSnapshot == .tvShows ? section.media.count : section.movies.count)
        
        let totalLines = moviesCount / CGFloat(itemsPerLine).rounded()
        
        constraint.constant
            = detailViewController.collectionView.inferredFrame!.origin.y
            + (cellHeight * (totalLines + 0.3))
            - 128.0
    }
}
