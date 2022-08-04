//
//  HomeViewModel.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/02/2022.
//

import UIKit

// MARK: - HomeViewModelDelegate

protocol HomeViewModelDelegate: AnyObject {
    func filter(_ sections: [SectionViewModel])
    func filter(_ sections: [SectionViewModel], at index: Int)
    func filter(_ sections: [SectionViewModel], at index: Int, minimumRating value: CGFloat)
    func section(at index: SectionIndices) -> SectionViewModel
    func randomObject(at section: SectionViewModel) -> MediaViewModel?
}


// MARK: - HomeViewModel

final class HomeViewModel: NSObject {
    
    // MARK: Properties
    
    var tvShows: [SectionViewModel]! = nil
    var movies: [SectionViewModel]! = nil
    
    private var minRating: CGFloat = 7.5
    
    private(set) var snapshot: TableViewSnapshot! = nil
    private(set) var currentSnapshot: TableViewSnapshot.State = .tvShows
    
    private(set) var myList: MyList! = nil
    
    var displayMedia: MediaViewModel! = nil
    var detailMedia: MediaViewModel! = nil
    
    private(set) weak var delegate: HomeViewModelDelegate! = nil
    private(set) weak var tableViewSnapshotDelegate: TableViewSnapshotDelegate! = nil
    
    weak var homeViewController: HomeViewController! = nil {
        didSet {
            guard let tableViewSnapshotDelegate = tableViewSnapshotDelegate else { return }
            tableViewSnapshotDelegate.tableViewDidInstantiateSnapshot?(currentSnapshot)
        }
    }
    
    
    // MARK: Initialization
    
    override init() {
        super.init()
        self.delegate = self
        self.tableViewSnapshotDelegate = self
    }
}



// MARK: - HomeViewModelDelegate Implementation

extension HomeViewModel: HomeViewModelDelegate {
    
    func filter(_ sections: [SectionViewModel], at index: Int) {
        currentSnapshot == .tvShows ? {
            sections[index].tvshows = sections.first!.tvshows.filter {
                return $0.genres!.contains(sections[index].title)
            }
        }() : {
            sections[index].movies = sections.first!.movies.filter {
                return $0.genres!.contains(sections[index].title)
            }
        }()
    }
    
    func filter(_ sections: [SectionViewModel], at index: Int, minimumRating value: CGFloat) {
        currentSnapshot == .tvShows ? {
            sections[index].tvshows = sections.first!.tvshows.filter {
                return $0.rating! > value
            }
        }() : {
            sections[index].movies = sections.first!.movies.filter {
                return $0.rating! > value
            }
        }()
    }
    
    func filter(_ sections: [SectionViewModel]) {
        for i in SectionIndices.allCases {
            guard let delegate = delegate else { return }
            switch i {
            case .display,
                    .ratable,
                    .resumable:
                currentSnapshot == .tvShows ? {
                    sections[i.rawValue].tvshows = sections.first!.tvshows
                }() : {
                    sections[i.rawValue].movies = sections.first!.movies
                }()
            case .action,
                    .sciFi,
                    .crime,
                    .thriller,
                    .adventure,
                    .comedy,
                    .drama,
                    .horror,
                    .anime,
                    .familyNchildren,
                    .documentary:
                delegate.filter(sections, at: i.rawValue)
            case .blockbuster:
                delegate.filter(sections, at: i.rawValue, minimumRating: minRating)
            default: break
            }
        }
    }
    
    func section(at index: SectionIndices) -> SectionViewModel {
        return snapshot.sections[index.rawValue]
    }
    
    func randomObject(at section: SectionViewModel) -> MediaViewModel? {
        guard let media = currentSnapshot == .tvShows ? section.tvshows.randomElement() : section.movies.randomElement() else { return nil }
        return media
    }
}


// MARK: - TableViewSnapshotProvider Implementation

extension HomeViewModel: TableViewSnapshotDelegate {
    
    func tableViewDidInstantiateSnapshot(_ state: TableViewSnapshot.State) {
        guard
            let delegate = delegate,
            let homeViewController = homeViewController,
            let sections = state == .tvShows ? tvShows : movies as [SectionViewModel]?,
            let listKey = state == .tvShows ? .tvShows : .movies as ListKey?
        else { return }
        snapshot = nil
        homeViewController.tableView.delegate = nil
        homeViewController.tableView.dataSource = nil
        homeViewController.tableView.prefetchDataSource = nil
        currentSnapshot = state
        let section = state == .tvShows ? tvShows.first! : movies.first!
        let media = delegate.randomObject(at: section)
        displayMedia = media
        detailMedia = media
        snapshot = TableViewSnapshot(state, homeViewController)
        homeViewController.tableView.reloadData()
        myList = MyList(forKey: listKey)
        delegate.filter(sections)
    }
}
