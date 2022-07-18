//
//  NavigationOverlayViewTableViewSnapshot.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 23/05/2022.
//

import UIKit

// MARK: - NavigationOverlayViewTableViewSnapshotDelegate

protocol NavigationOverlayViewTableViewSnapshotDelegate: AnyObject {
    
    func tableViewWillSelectDefaultRows(_ tableView: UITableView)
    
    func tableViewWillSelectRows(_ tableView: UITableView)
}



// MARK: - NavigationOverlayViewTableViewSnapshot

final class NavigationOverlayViewTableViewSnapshot: NSObject {
    
    // MARK: Properties
    
    private(set) var items: [Valuable]
    
    
    private let userDefaults = UserDefaults.standard
    
    private var selectsDefaultRows = false
    
    
    private(set) weak var delegate: NavigationOverlayViewTableViewSnapshotDelegate! = nil
    
    
    private weak var navigationOverlayView: NavigationOverlayView! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    init(items: [Valuable], navigationOverlayView: NavigationOverlayView?) {
        self.items = items
        self.navigationOverlayView = navigationOverlayView
        
        super.init()
        
        self.delegate = self
        
        guard let navigationOverlayView = navigationOverlayView else {
            return
        }
        
        navigationOverlayView.tableView.register(TitleOverlayTableViewCell.nib,
                                                 forCellReuseIdentifier: TitleOverlayTableViewCell.reuseIdentifier)
    }
    
    deinit {
        delegate = nil
        navigationOverlayView = nil
    }
}



// MARK: - NavigationOverlayViewTableViewSnapshotDelegate Implementation

extension NavigationOverlayViewTableViewSnapshot: NavigationOverlayViewTableViewSnapshotDelegate {
    
    func tableViewWillSelectDefaultRows(_ tableView: UITableView) {
        switch items {
        case _ as [NavigationView.State]?:
            
            let indexPath: IndexPath = .init(row: 1, section: 0)
            
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
        case _ as [NavigationOverlayView.Category]?:
            
            let indexPath: IndexPath = .init(row: 0, section: 0)
            
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
        default: break
        }
        
        selectsDefaultRows = true
    }
    
    func tableViewWillSelectRows(_ tableView: UITableView) {
        
        let indexPath: IndexPath
        
        switch items {
        case _ as [NavigationView.State]?:
            
            guard let row = userDefaults.value(forKey: UserDefaults.stateRowKey) as? Int else {
                
                tableViewWillSelectDefaultRows(tableView)
                
                return
            }
            
            indexPath = .init(row: row, section: 0)
            
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
        case _ as [NavigationOverlayView.Category]?:
            
            guard let row = userDefaults.value(forKey: UserDefaults.categoryRowKey) as? Int else {
                
                tableViewWillSelectDefaultRows(tableView)
                
                return
            }
            
            indexPath = .init(row: row, section: 0)
            
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
        default: return
        }
    }
}



// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension NavigationOverlayViewTableViewSnapshot: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleOverlayTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? TitleOverlayTableViewCell else {
            fatalError("Could not dequeue cell: \(TitleOverlayTableViewCell.self), at: `\(Self.self)`.")
        }
        
        guard let navigationOverlayView = navigationOverlayView else {
            fatalError("Invalid `navigationOverlayView` property, at: `\(Self.self)`.")
        }
        
        switch navigationOverlayView.currentSnapshot {
        case .state:
            cell.configure(NavigationView.State.allCases[indexPath.row])
            
        case .category:
            cell.configure(NavigationOverlayView.Category.allCases[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        
        !selectsDefaultRows
            ? delegate.tableViewWillSelectDefaultRows(tableView)
            : delegate.tableViewWillSelectRows(tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let navigationOverlayView = navigationOverlayView,
            let homeViewController = navigationOverlayView.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?,
            let navigationView = homeViewController.navigationView,
            let homeOverlayViewController = homeViewController.homeOverlayViewController,
            let navigationOverlayViewDelegate = navigationOverlayView.delegate
        else {
            return
        }
        
        switch items {
        case let items as [NavigationView.State]?:
            
            if let state = items?[indexPath.row] {
                
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                
                userDefaults.set(indexPath.row, forKey: UserDefaults.stateRowKey)
                
                switch state {
                case .home:
                    homeOverlayViewController.showsOverlay = false
                    
                    navigationOverlayView.state = .home
                    navigationView.state = .home
                    
                case .tvShows:
                    homeOverlayViewController.showsOverlay = false
                    
                    navigationOverlayView.state = .tvShows
                    navigationView.state = .tvShows
                    
                    guard let tvShowsButtonDelegate = navigationView.tvShowsButton.delegate else {
                        return
                    }
                    
                    tvShowsButtonDelegate
                        .navigationItemWillPerformAnimations(navigationView.tvShowsButton) { homeViewModel, navigationView in
                            
                            guard let tableViewSnapshotDelegate = homeViewModel.tableViewSnapshotDelegate else {
                                return
                            }
                            
                            tableViewSnapshotDelegate.tableViewDidInstantiateSnapshot?(.tvShows)
                        }
                    
                case .movies:
                    homeOverlayViewController.showsOverlay = false
                    
                    navigationOverlayView.state = .movies
                    navigationView.state = .movies
                    
                    guard let moviesButtonDelegate = navigationView.moviesButton.delegate else {
                        return
                    }
                    
                    moviesButtonDelegate
                        .navigationItemWillPerformAnimations(navigationView.moviesButton) { homeViewModel, navigationView in
                            
                            guard let tableViewSnapshotDelegate = homeViewModel.tableViewSnapshotDelegate else {
                                return
                            }
                            
                            tableViewSnapshotDelegate.tableViewDidInstantiateSnapshot?(.movies)
                        }
                    
                default: return
                }
            }
            
        case let items as [NavigationOverlayView.Category]?:
            
            if let category = items?[indexPath.row] {
                
                userDefaults.set(indexPath.row, forKey: UserDefaults.categoryRowKey)
                
                switch category {
                case .home:
                    homeOverlayViewController.showsOverlay = false
                    
                    navigationView.state = .home
                    navigationOverlayView.category = .home
                    
                default:
                    let index: SectionIndices = .init(rawValue: category.rawValue)!
                    let section = homeViewModel.section(at: index)
                    
                    homeOverlayViewController.showsOverlay = true
                    
                    homeOverlayViewController.dataSet = .init(section,
                                                              withItems: category == .myList
                                                                ? Array(homeViewModel.myList.data)
                                                              : homeViewModel.currentSnapshot == .tvShows ? section.media : section.movies,
                                                              withCollectionView: homeOverlayViewController.collectionView,
                                                              withHomeOverlayViewController: homeOverlayViewController)
                    
                    homeOverlayViewController.snapshot = .init(homeOverlayViewController.dataSet,
                                                               with: homeViewController)
                    
                    
                    navigationView.state = homeViewModel.currentSnapshot == .tvShows ? .tvShows : .movies
                    
                    navigationOverlayView.category = category
                    
                    
                    homeOverlayViewController.collectionView.delegate = homeOverlayViewController.snapshot
                    homeOverlayViewController.collectionView.dataSource = homeOverlayViewController.snapshot
                    homeOverlayViewController.collectionView.prefetchDataSource = homeOverlayViewController.snapshot
                    
                    homeOverlayViewController.collectionView.reloadData()
                }
            }
            
        default: break
        }
        
        navigationOverlayViewDelegate.navigationOverlayViewDidHide(navigationOverlayView)
    }
}
