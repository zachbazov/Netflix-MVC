//
//  TableViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/06/2022.
//

import UIKit

// MARK: - TableViewCell

class TableViewCell<Cell>: UITableViewCell, Configurable where Cell: UICollectionViewCell {
    
    // MARK: SortOptions

    enum SortOptions {
        case rating
    }
    
    
    // MARK: Properties
    
    var collectionView: UICollectionView! = nil
    var section: SectionViewModel! = nil
    
    var dataSet: CollectionViewSnapshotDataSet<Cell>! = nil
    var snapshot: CollectionViewSnapshot<Cell, CollectionViewSnapshotDataSet<Cell>>! = nil
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: TableViewCell.reuseIdentifier)
        self.backgroundColor = .black
        self.contentView.backgroundColor = .black
        let dummyLayout = ComputableFlowLayout(.original)
        self.collectionView = UICollectionView(frame: bounds, collectionViewLayout: dummyLayout)
        self.collectionView.backgroundColor = .black
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.contentView.addSubview(collectionView)
        self.collectionView.register(Cell.nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        collectionView = nil
        section = nil
        dataSet = nil
        snapshot = nil
        homeViewController = nil
    }
    
    
    //
    
    func configure(_ section: SectionViewModel? = nil, with homeViewController: HomeViewController? = nil) {
        if let homeViewController = homeViewController {
            self.homeViewController = homeViewController
            self.section = section
            let index = SectionIndices(rawValue: self.section.id)
            let layout: ComputableFlowLayout
            switch index {
            case .display:
                break
            case .ratable:
                self.section = self.sort(.rating, sliceBy: 10)
                layout = ComputableFlowLayout(.original)
                collectionView.setCollectionViewLayout(layout, animated: false)
            case .resumable:
                layout = ComputableFlowLayout(.standard)
                collectionView.setCollectionViewLayout(layout, animated: false)
            case .blockbuster:
                layout = ComputableFlowLayout(.blockbuster)
                collectionView.setCollectionViewLayout(layout, animated: false)
            case .myList:
                layout = ComputableFlowLayout(.standard)
                collectionView?.setCollectionViewLayout(layout, animated: false)
            default:
                layout = ComputableFlowLayout(.standard)
                collectionView.setCollectionViewLayout(layout, animated: false)
                dataSet = .init(self.section, homeViewController: homeViewController, standardCell: self)
                snapshot = .init(self.dataSet, homeViewController)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.delegate = self.snapshot
                    self.collectionView.dataSource = self.snapshot
                    self.collectionView.prefetchDataSource = self.snapshot
                    self.collectionView.reloadData()
                }
                return
            }
            dataSet = .init(self.section,
                                 homeViewController: homeViewController,
                                 loadsMyList: index == .myList ? true : false)
            snapshot = .init(dataSet, homeViewController)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.delegate = self.snapshot
                self.collectionView.dataSource = self.snapshot
                self.collectionView.prefetchDataSource = self.snapshot
                self.collectionView.reloadData()
            }
        }
    }
}


// MARK: - Mutable

extension TableViewCell: Mutable {
    
    func sort(_ sortOptions: SortOptions, sliceBy length: Int) -> SectionViewModel? {
        switch sortOptions {
        case .rating:
            homeViewController.homeViewModel.currentSnapshot == .tvShows ? {
                section.tvshows = section.tvshows.sorted {
                    return $0.rating! > $1.rating!
                }
            }() : {
                section.movies = section.movies.sorted {
                    return $0.rating! > $1.rating!
                }
            }()
            if let length = length as Int? {
                let slice = homeViewController.homeViewModel.currentSnapshot == .tvShows
                    ? section.tvshows.prefix(length)
                    : section.movies.prefix(length)
                homeViewController.homeViewModel.currentSnapshot == .tvShows ? {
                    section.tvshows = Array(slice)
                }() : {
                    section.movies = Array(slice)
                }()
            }
            return section
        }
    }
    
    func slice(_ length: Int) -> SectionViewModel? {
        let slice = homeViewController.homeViewModel.currentSnapshot == .tvShows
            ? section.tvshows.prefix(length)
            : section.movies.prefix(length)
        homeViewController.homeViewModel.currentSnapshot == .tvShows ? {
            section.tvshows = Array(slice)
        }() : {
            section.movies = Array(slice)
        }()
        return section
    }
}
