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
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> CollectionViewCell
    func collectionView(_ collectionView: UICollectionView, willConfigure cell: CollectionViewCell, forItemAt indexPath: IndexPath) -> CollectionViewCell?
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
    
    let cache: NSCache<NSString, UIImage> = URLService.shared.cache
    
    var loadsMyList: Bool = false
    var homeOverlayItems: [MediaViewModel]! = nil
    var myList: [MediaViewModel] {
        return Array(homeViewController.homeViewModel.myList.data)
    }
    
    weak var standardCell: TableViewCell<Cell>! = nil
    weak var homeViewController: HomeViewController! = nil
    weak var homeOverlayViewController: HomeOverlayViewController! = nil
    weak var detailViewController: DetailViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    init(_ section: SectionViewModel, homeViewController: HomeViewController? = nil) {
        self.section = section
        if let homeViewController = homeViewController {
            self.homeViewController = homeViewController
        }
    }
    
    convenience init(_ section: SectionViewModel, homeViewController: HomeViewController, loadsMyList: Bool) {
        self.init(section, homeViewController: homeViewController)
        self.loadsMyList = loadsMyList
    }
    
    convenience init(_ section: SectionViewModel, homeViewController: HomeViewController, standardCell: TableViewCell<Cell>) {
        self.init(section, homeViewController: homeViewController)
        self.standardCell = standardCell
    }
    
    convenience init(_ section: SectionViewModel, homeViewController: HomeViewController, homeOverlayItems: [MediaViewModel], homeOverlayViewController: HomeOverlayViewController) {
        self.init(section, homeViewController: homeViewController)
        self.homeOverlayItems = homeOverlayItems
        self.homeOverlayViewController = homeOverlayViewController
    }
    
    convenience init(_ section: SectionViewModel, homeViewController: HomeViewController? = nil, detailViewController: DetailViewController) {
        self.init(section)
        self.detailViewController = detailViewController
    }
    
    deinit {
        detailViewController = nil
        homeOverlayItems = nil
        homeOverlayViewController = nil
        standardCell = nil
        homeViewController = nil
    }
    
    
    // MARK: CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let detailViewController = detailViewController,
           detailViewController.detailViewModel.section != nil {
            return detailViewController.homeViewController.homeViewModel.currentSnapshot == .tvShows
                ? detailViewController.detailViewModel.section.tvshows.count
                : detailViewController.detailViewModel.section.movies.count
        }
        if let items = homeOverlayItems {
            return items.count
        }
        guard let indices = SectionIndices(rawValue: self.section.id) else { return .zero }
        switch indices {
        case .display, .ratable, .resumable, .blockbuster:
            return homeViewController.homeViewModel.currentSnapshot == .tvShows
                ? self.section.tvshows.count
                : self.section.movies.count
        case .myList:
            guard loadsMyList else { return .zero }
            return myList.count
        default:
            guard let standardCell = standardCell else { return .zero }
            return homeViewController.homeViewModel.currentSnapshot == .tvShows
                ? standardCell.section.tvshows.count
                : standardCell.section.movies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> CollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? CollectionViewCell else {
            fatalError("Could not dequeue cell \(T.self)")
        }
        return self.collectionView(collectionView, willConfigure: cell, forItemAt: indexPath)!
    }
    
    func collectionView(_ collectionView: UICollectionView, willConfigure cell: CollectionViewCell, forItemAt indexPath: IndexPath) -> CollectionViewCell? {
        guard
            let media = media(for: indexPath),
            let identifier = "cover_\(media.id!)" as NSString?,
            let logoIdentifier = "logo_\(media.id!)" as NSString?,
            let coverURL = URL(string: media.covers!.first!),
            let logoURL = URL(string: media.logo!)
        else {
            fatalError("Unexpected indexpath for object at \(indexPath).")
        }
        cell.representedIdentifier = identifier
        guard
            let cover = cache.object(forKey: identifier),
            let logo = cache.object(forKey: logoIdentifier)
        else {
            cell.configure(section: nil)
            cell.configure(section: section, media: media, at: indexPath, with: homeViewController)
            URLService.shared.load(url: coverURL, identifier: identifier) { image in
                guard cell.representedIdentifier == identifier else { return }
                DispatchQueue.main.async {
                    cell.coverImageView.image = image
                }
            }
            URLService.shared.load(url: logoURL, identifier: logoIdentifier) { image in
                guard cell.representedIdentifier == identifier else { return }
                DispatchQueue.main.async {
                    cell.logoImageView.image = image
                }
            }
            return cell
        }
        cell.configure(section: section, media: media, cover: cover, logo: logo, at: indexPath, with: homeViewController)
        return cell
    }
    
    
    // MARK: CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: CollectionViewCell, forItemAt indexPath: IndexPath) {
        guard
            let media = media(for: indexPath),
            let identifier = "cover_\(media.id!)" as NSString?,
            let logoIdentifier = "logo_\(media.id!)" as NSString?
        else {
            fatalError("Unexpected indexpath for object at \(indexPath).")
        }
        if let cover = cache.object(forKey: identifier),
           let logo = cache.object(forKey: logoIdentifier) {
            DispatchQueue.main.async {
                cell.coverImageView.image = cover
                cell.logoImageView.image = logo
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: CollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            cell.coverImageView.image = nil
            cell.logoImageView.image = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, with homeViewController: HomeViewController) {
        if let detailViewController = detailViewController {
            detailViewController
                .detailPreviewView
                .mediaPlayerView
                .delegate?.mediaPlayerWillStopPlaying(detailViewController.detailPreviewView.mediaPlayerView.mediaPlayer)
            guard
                let homeViewController = detailViewController.homeViewController,
                let homeViewModel = homeViewController.homeViewModel as HomeViewModel?,
                let media = media(for: indexPath)
            else { return }
            let newDetailInstance = UIStoryboard
                                        .init(name: "Home", bundle: nil)
                                        .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            newDetailInstance.homeViewController = detailViewController.homeViewController
            homeViewModel.detailMedia = media
            newDetailInstance.detailViewModel.section = detailViewController.detailViewModel.section!
            detailViewController.navigationController?.pushViewController(newDetailInstance, animated: true)
            return
        }
        guard
            let media = media(for: indexPath),
            let homeViewController = homeViewController as HomeViewController?,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else { return }
        homeViewModel.detailMedia = media
        homeViewController.segue.current = .detail
        guard
            let detailViewController = homeViewController.detailViewController,
            let detailViewModel = detailViewController.detailViewModel as DetailViewModel?
        else { return }
        detailViewModel.section = section
    }
    
    
    // MARK: CollectionViewDataSourcePrefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard
                let media = media(for: indexPath),
                let coverURL = URL(string: media.covers!.first!),
                let logoURL = URL(string: media.logo!),
                let coverIdentifier = "cover_\(media.id!)" as NSString?,
                let logoIdentifier = "logo_\(media.id!)" as NSString?
            else { return }
            URLService.shared.load(url: coverURL, identifier: coverIdentifier) { _ in }
            URLService.shared.load(url: logoURL, identifier: logoIdentifier) { _ in }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {}
    
    
    // MARK: Private Methods
    
    private func media(for indexPath: IndexPath) -> MediaViewModel? {
        if loadsMyList {
            return myList[indexPath.row]
        }
        if detailViewController != nil {
            return detailViewController.homeViewController.homeViewModel.currentSnapshot == .tvShows
                ? detailViewController.detailViewModel.section.tvshows[indexPath.row] as MediaViewModel?
                : detailViewController.detailViewModel.section.movies[indexPath.row] as MediaViewModel?
        }
        if homeOverlayItems != nil {
            return homeOverlayItems[indexPath.row]
        }
        return homeViewController.homeViewModel.currentSnapshot == .tvShows
            ? section.tvshows[indexPath.row] as MediaViewModel?
            : section.movies[indexPath.row] as MediaViewModel?
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
         _ homeViewController: HomeViewController) {
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
