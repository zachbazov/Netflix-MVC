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
            
            let dummyLayout: ComputableFlowLayout = .init(.original)
            
            self.collectionView = .init(frame: bounds, collectionViewLayout: dummyLayout)
            self.collectionView.backgroundColor = .black
            self.collectionView.showsVerticalScrollIndicator = false
            self.collectionView.showsHorizontalScrollIndicator = false
            
            self.contentView.addSubview(collectionView)
            
            self.collectionView.register(Cell.nib, forCellWithReuseIdentifier: Cell.reuseIdentifier)
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            
            let index: SectionIndices? = .init(rawValue: self.section.id)
            let layout: ComputableFlowLayout
            
            switch index {
            case .display:
                break
            case .ratable:
                self.section = self.sort(.rating, sliceBy: 10)
                
                layout = .init(.original)
                self.collectionView.setCollectionViewLayout(layout, animated: false)
            case .resumable:
                
                layout = .init(.standard)
                self.collectionView.setCollectionViewLayout(layout, animated: false)
            case .blockbuster:
                
                layout = .init(.blockbuster)
                self.collectionView.setCollectionViewLayout(layout, animated: false)
            case .myList:
                layout = .init(.standard)
                DispatchQueue.main.async {
                    
                    self.collectionView?.setCollectionViewLayout(layout, animated: false)
                }
            default:
                
                layout = .init(.standard)
                self.collectionView.setCollectionViewLayout(layout, animated: false)
                
                self.dataSet = .init(self.section, for: self, with: homeViewController)
                self.snapshot = .init(self.dataSet, with: homeViewController)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.collectionView.delegate = self.snapshot
                    self.collectionView.dataSource = self.snapshot
                    self.collectionView.prefetchDataSource = self.snapshot
                    
                    self.collectionView.reloadData()
                }
                
                return
            }
            
            self.dataSet = .init(self.section, requireMyList: index == .myList ? true : false, with: homeViewController)
            self.snapshot = .init(self.dataSet, with: homeViewController)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
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
                section.media = section.media.sorted {
                    return $0.rating! > $1.rating!
                }
            }() : {
                section.movies = section.movies.sorted {
                    return $0.rating! > $1.rating!
                }
            }()
            
            if let length = length as Int? {
                let slice = homeViewController.homeViewModel.currentSnapshot == .tvShows ? section.media.prefix(length) : section.movies.prefix(length)
                
                homeViewController.homeViewModel.currentSnapshot == .tvShows ? {
                    section.media = Array(slice)
                }() : {
                    section.movies = Array(slice)
                }()
            }
            
            return section
        }
    }
    
    func slice(_ length: Int) -> SectionViewModel? {
        let slice = homeViewController.homeViewModel.currentSnapshot == .tvShows ? section.media.prefix(length) : section.movies.prefix(length)
        
        homeViewController.homeViewModel.currentSnapshot == .tvShows ? {
            section.media = Array(slice)
        }() : {
            section.movies = Array(slice)
        }()
        
        return section
    }
}
