//
//  CollectionViewSnapshot.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 09/06/2022.
//

import UIKit

// MARK: - CollectionViewDelegate

protocol CollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: CollectionViewCell, forItemAt indexPath: IndexPath)
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: CollectionViewCell, forItemAt indexPath: IndexPath)
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, with homeViewController: HomeViewController)
}



// MARK: - CollectionViewDataSource

protocol CollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView, willConfigure cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> UICollectionViewCell?
}



// MARK: - CollectionViewDataSourcePrefetching

protocol CollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath])
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath])
}



// MARK: - CollectionViewSnapshotDataSet

final class CollectionViewSnapshotDataSet<Cell>: CollectionViewDelegate,
                                                 CollectionViewDataSource,
                                                 CollectionViewDataSourcePrefetching
where Cell: UICollectionViewCell {
    
    // MARK: Properties
    
    typealias T = Cell
    
    
    var section: SectionViewModel
    
    
    var requiresMyList = false
    
    
    var items: [MediaViewModel]! = nil
    
    
    var myList: [MediaViewModel] {
        return Array(homeViewController.homeViewModel.myList.data)
    }
    
    
    weak var collectionView: UICollectionView! = nil
    
    weak var standardCell: TableViewCell<Cell>! = nil
    
    weak var homeViewController: HomeViewController! = nil
    
    weak var detailViewController: DetailViewController! = nil
    
    weak var homeOverlayViewController: HomeOverlayViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    init(_ section: SectionViewModel,
         requireMyList required: Bool? = false,
         for cell: TableViewCell<Cell>? = nil,
         with homeViewController: HomeViewController? = nil,
         withItems items: [MediaViewModel]? = nil,
         withCollectionView collectionView: UICollectionView? = nil,
         withHomeOverlayViewController homeOverlayViewController: HomeOverlayViewController? = nil,
         withDetailViewController detailViewController: DetailViewController? = nil) {
        
        self.section = section
        
        if let homeViewController = homeViewController {
            self.homeViewController = homeViewController
        }
        
        if let required = required {
            self.requiresMyList = required
            self.homeViewController = homeViewController
        }
        
        if let standardCell = cell {
            self.standardCell = standardCell
        }
        
        if let items = items,
           let collectionView = collectionView,
           let homeOverlayViewController = homeOverlayViewController {
            self.items = items
            self.collectionView = collectionView
            self.homeOverlayViewController = homeOverlayViewController
        }
        
        if let detailViewController = detailViewController {
            self.detailViewController = detailViewController
        }
    }
    
    deinit {
        items = nil
        collectionView = nil
        homeOverlayViewController = nil
        detailViewController = nil
        standardCell = nil
        homeViewController = nil
    }
    
    
    // MARK: CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let detailViewController = detailViewController {
            guard
                let homeViewModel = detailViewController.homeViewController.homeViewModel as HomeViewModel?,
                let detailViewModel = detailViewController.detailViewModel as DetailViewModel?,
                let section = detailViewModel.section
            else {
                return .zero
            }
            
            if detailViewModel.section != nil {
                return homeViewModel.currentSnapshot == .tvShows ? section.media.count : section.movies.count
            } else {
                return homeViewModel.currentSnapshot == .tvShows ? self.section.media.count : self.section.movies.count
            }
        }
        
        if let items = items {
            return items.count
        }
        
        guard standardCell == nil else {
            return homeViewController.homeViewModel.currentSnapshot == .tvShows ? self.section.media.count : self.section.movies.count
        }
        
        guard let indices: SectionIndices = .init(rawValue: self.section.id) else {
            return .zero
        }
        
        switch indices {
        case .myList: return myList.count
        default: return homeViewController.homeViewModel.currentSnapshot == .tvShows ? self.section.media.count : self.section.movies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell \(T.self)")
        }
        
        return self.collectionView(collectionView, willConfigure: cell, forItemAt: indexPath)!
    }
    
    func collectionView(_ collectionView: UICollectionView, willConfigure cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        guard
            let media = requiresMyList
                ? myList[indexPath.row] as MediaViewModel?
                : {
                    detailViewController != nil
                    ? {
                        detailViewController.homeViewController.homeViewModel.currentSnapshot == .tvShows ? detailViewController.detailViewModel.section.media[indexPath.row] as MediaViewModel? : detailViewController.detailViewModel.section.movies[indexPath.row] as MediaViewModel?
                    }()
                    : {
                        items != nil ? items[indexPath.row] : {
                            homeViewController.homeViewModel.currentSnapshot == .tvShows ? section.media[indexPath.row] as MediaViewModel? : section.movies[indexPath.row] as MediaViewModel?
                        }()
                    }()
                }(),
            let identifier = "smallCover_\(media.id!)" as NSString?
        else {
            fatalError("Unexpected indexpath for object at \(indexPath).")
        }
        
        if let image = URLService.shared.object(for: identifier) {
            switch cell {
            case let cell as RatableCollectionViewCell:
                let attributes = (identifier, image) as (NSString, UIImage)?
                
                cell.configure(cell, attributes: attributes, at: indexPath)
                
            case let cell as ResumableCollectionViewCell:
                cell.configure(cell, section: section, media: media, image: image, at: indexPath, with: homeViewController)
                
            case let cell as BlockbusterCollectionViewCell:
                cell.configure(cell, image: image)
                
            case let cell as MyListCollectionViewCell:
                cell.configure(cell, image: image)
                
            case let cell as StandardCollectionViewCell:
                cell.configure(cell, image: image)
                
            default: break
            }
            
        } else {
            switch cell {
            case let cell as RatableCollectionViewCell:
                cell.configure(nil, attributes: nil, at: nil)
                
            case let cell as ResumableCollectionViewCell:
                cell.configure(nil, section: nil, media: nil, image: nil, at: nil, with: nil)
                
            case let cell as BlockbusterCollectionViewCell:
                cell.configure(nil, image: nil)
                
            case let cell as MyListCollectionViewCell:
                cell.configure(nil, image: nil)
                
            case let cell as StandardCollectionViewCell:
                cell.configure(nil, image: nil)
                
            default: break
            }
            
            if let smallCover = media.smallCover,
               let url = URL(string: smallCover) {
                URLService.shared.downloadImage(url, for: identifier) { [weak self] image in
                    guard let self = self else {
                        return
                    }
                    
                    switch cell {
                    case let cell as RatableCollectionViewCell:
                        let attributes = (identifier, image) as (NSString, UIImage)?
                        
                        cell.configure(cell, attributes: attributes, at: indexPath)
                        
                    case let cell as ResumableCollectionViewCell:
                        cell.configure(cell, section: self.section, media: media, image: image, at: indexPath, with: self.homeViewController)
                        
                    case let cell as BlockbusterCollectionViewCell:
                        cell.configure(cell, image: image)
                        
                    case let cell as MyListCollectionViewCell:
                        cell.configure(cell, image: image)
                        
                    case let cell as StandardCollectionViewCell:
                        cell.configure(cell, image: image)
                        
                    default: return
                    }
                }
            }
        }
        
        return cell
    }
    
    
    // MARK: CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: CollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let media = requiresMyList
                ? myList[indexPath.row] as MediaViewModel?
                : {
                    detailViewController != nil
                    ? {
                        detailViewController.homeViewController.homeViewModel.currentSnapshot == .tvShows ? detailViewController.detailViewModel.section.media[indexPath.row] as MediaViewModel? : detailViewController.detailViewModel.section.movies[indexPath.row] as MediaViewModel?
                    }()
                    : {
                        items != nil ? items[indexPath.row] : {
                            homeViewController.homeViewModel.currentSnapshot == .tvShows ? section.media[indexPath.row] as MediaViewModel? : section.movies[indexPath.row] as MediaViewModel?
                        }()
                    }()
                }(),
            let identifier = "smallCover_\(media.id!)" as NSString?
        else {
            return
        }
        
        cell.coverImageView.image = URLService.shared.object(for: identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: CollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.coverImageView.image = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, with homeViewController: HomeViewController) {
        
        if let detailViewController = detailViewController {
            detailViewController
                .detailPreviewView
                .mediaPlayerView
                .delegate?.mediaPlayerWillStopPlaying(detailViewController.detailPreviewView.mediaPlayerView.mediaPlayer)
            
            let newDetailInstance = UIStoryboard
                                        .init(name: "Home", bundle: nil)
                                        .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            newDetailInstance.homeViewController = detailViewController.homeViewController
            
            guard
                let homeViewController = detailViewController.homeViewController,
                let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
            else {
                return
            }
            
            guard let media = homeViewModel.currentSnapshot == .tvShows ? detailViewController.detailViewModel.section.media[indexPath.row] as MediaViewModel? : detailViewController.detailViewModel.section.movies[indexPath.row] as MediaViewModel? else {
                return
            }
            
            homeViewModel.detailMedia = media
            
            newDetailInstance.detailViewModel.section = detailViewController.detailViewModel.section!
            
            detailViewController.navigationController?.pushViewController(newDetailInstance, animated: true)
            
            return
        }
        
        guard
            let media = requiresMyList
                ? myList[indexPath.row] as MediaViewModel?
                : {
                    detailViewController != nil
                    ? {
                        detailViewController.homeViewController.homeViewModel.currentSnapshot == .tvShows ? detailViewController.detailViewModel.section.media[indexPath.row] as MediaViewModel? : detailViewController.detailViewModel.section.movies[indexPath.row] as MediaViewModel?
                    }()
                    : {
                        items != nil ? items[indexPath.row] : {
                            homeViewController.homeViewModel.currentSnapshot == .tvShows ? section.media[indexPath.row] as MediaViewModel? : section.movies[indexPath.row] as MediaViewModel?
                        }()
                    }()
                }(),
            let homeViewController = homeViewController as HomeViewController?,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else {
            return
        }
        
        homeViewModel.detailMedia = media
        homeViewController.segue.current = .detail
        
        guard
            let detailViewController = homeViewController.detailViewController,
            let detailViewModel = detailViewController.detailViewModel as DetailViewModel?
        else {
            return
        }
        
        detailViewModel.section = section
    }
    
    
    // MARK: CollectionViewDataSourcePrefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard
                let media = requiresMyList
                    ? myList[indexPath.row] as MediaViewModel?
                    : {
                        detailViewController != nil
                        ? {
                            homeViewController.homeViewModel.currentSnapshot == .tvShows ? detailViewController.detailViewModel.section.media[indexPath.row] as MediaViewModel? : detailViewController.detailViewModel.section.movies[indexPath.row] as MediaViewModel?
                        }()
                        : {
                            items != nil ? items[indexPath.row] : {
                                homeViewController.homeViewModel.currentSnapshot == .tvShows ? section.media[indexPath.row] as MediaViewModel? : section.movies[indexPath.row] as MediaViewModel?
                            }()
                        }()
                    }(),
                let smallCover = media.smallCover,
                let url = URL(string: smallCover),
                let identifier = "smallCover_\(media.id!)" as NSString?
            else {
                return
            }
            
            URLService.shared.downloadImage(url, for: identifier)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard
                let media = requiresMyList
                    ? myList[indexPath.row] as MediaViewModel?
                    : {
                        detailViewController != nil
                        ? {
                            homeViewController.homeViewModel.currentSnapshot == .tvShows ? detailViewController.detailViewModel.section.media[indexPath.row] as MediaViewModel? : detailViewController.detailViewModel.section.movies[indexPath.row] as MediaViewModel?
                        }()
                        : {
                            items != nil ? items[indexPath.row] : {
                                homeViewController.homeViewModel.currentSnapshot == .tvShows ? section.media[indexPath.row] as MediaViewModel? : section.movies[indexPath.row] as MediaViewModel?
                            }()
                        }()
                    }(),
                let identifier = "smallCover_\(media.id!)" as NSString?
            else {
                return
            }
            
            URLService.shared.cancelTask(for: identifier)
        }
    }
}



// MARK: - CollectionViewSnapshot

final class CollectionViewSnapshot<Cell, DataSet: CollectionViewDelegate
                                    & CollectionViewDataSource
                                    & CollectionViewDataSourcePrefetching>:
                                        NSObject,
                                        UICollectionViewDelegate,
                                        UICollectionViewDataSource,
                                        UICollectionViewDataSourcePrefetching {
    
    // MARK: Properties
    
    var dataSet: DataSet
    
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    init(_ dataSet: DataSet,
         with homeViewController: HomeViewController) {
        self.dataSet = dataSet
        self.homeViewController = homeViewController
    }
    
    deinit {
        homeViewController = nil
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSet.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSet.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        dataSet.collectionView(collectionView, willDisplay: cell as! CollectionViewCell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        dataSet.collectionView(collectionView, didEndDisplaying: cell as! CollectionViewCell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSet.collectionView(collectionView, didSelectItemAt: indexPath, with: homeViewController!)
    }
    
    
    // MARK: UICollectionViewDataSourcePrefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        dataSet.collectionView(collectionView, prefetchItemsAt: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        dataSet.collectionView(collectionView, cancelPrefetchingForItemsAt: indexPaths)
    }
}
