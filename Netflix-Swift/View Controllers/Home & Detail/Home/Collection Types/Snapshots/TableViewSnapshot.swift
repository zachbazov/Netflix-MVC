//
//  TableViewSnapshot.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/04/2022.
//

import UIKit

// MARK: - TableViewSnapshotDelegate

@objc protocol TableViewSnapshotDelegate: AnyObject {
    
    @objc optional func tableViewDidChangeSnapshot(_ tableView: UITableView)
    
    @objc optional func tableViewDidRegisterCells(_ tableView: UITableView)
    
    @objc optional func tableViewDidInstantiateSnapshot(_ type: TableViewSnapshot.State)
    
    @objc optional func tableView(_ tableView: UITableView,
                                  willConfigure cell: UITableViewCell,
                                  at indexPath: IndexPath)
    
    @objc optional func typeForRow(in section: Int) -> UITableViewCell.Type
    
    @objc optional func tableViewDidShow(_ tableView: UITableView)
    
    @objc optional func tableViewDidHide(_ tableView: UITableView)
    
    @objc optional func tableViewWillBeginLoading(_ tableView: UITableView)
}



// MARK: - TableViewSnapshot

final class TableViewSnapshot: NSObject {
    
    // MARK: State

    @objc enum State: Int {
        case tvShows, movies
    }
    
    
    // MARK: Properties
    
    private var tableView: UITableView
    
    private(set) var sections: [SectionViewModel]
    
    
    private var requiresInitialLoading = true
    
    
    private(set) var singleCell: DisplayTableViewCell! = nil
    
    private var ratableCell: RatableTableViewCell! = nil
    
    private var resumableCell: ResumableTableViewCell! = nil
    
    private var blockbusterCell: BlockbusterTableViewCell! = nil
    
    private(set) var myListCell: MyListTableViewCell! = nil
    
    private var standardCell: StandardTableViewCell! = nil
    
    
    weak var delegate: TableViewSnapshotDelegate! = nil
    
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    init(_ state: TableViewSnapshot.State, with homeViewController: HomeViewController) {
        self.homeViewController = homeViewController
        self.tableView = homeViewController.tableView
        self.sections = state == .tvShows
            ? homeViewController.homeViewModel.tvShows
            : homeViewController.homeViewModel.movies
        
        super.init()
        
        self.delegate = self
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tableViewDidRegisterCells!(tableView)
        delegate.tableViewDidChangeSnapshot!(tableView)
    }
    
    deinit {
        singleCell = nil
        ratableCell = nil
        resumableCell = nil
        blockbusterCell = nil
        myListCell = nil
        standardCell = nil
        
        delegate = nil
        
        homeViewController = nil
    }
}



// MARK: - TableViewSnapshotDelegate Implementation

extension TableViewSnapshot: TableViewSnapshotDelegate {
    
    func tableViewDidChangeSnapshot(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    }
    
    func tableViewDidRegisterCells(_ tableView: UITableView) {
        tableView.register(TitleHeaderView.self)
        
        tableView.register(nib: DisplayTableViewCell.self)
        tableView.register(class: RatableTableViewCell.self)
        tableView.register(class: ResumableTableViewCell.self)
        tableView.register(class: BlockbusterTableViewCell.self)
        tableView.register(class: MyListTableViewCell.self)
        
        for identifier in StandardTableViewCell.Identifier.allCases {
            tableView.register(StandardTableViewCell.self,
                               forCellReuseIdentifier: identifier.stringValue)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   willConfigure cell: UITableViewCell,
                   at indexPath: IndexPath) {
        guard
            let homeViewController = homeViewController,
            let indices: SectionIndices = .init(rawValue: indexPath.section),
            let section = sections[indices.rawValue] as SectionViewModel?
        else {
            DispatchError.unexpectedIndexPathForSection(indexPath.section).dispatch
        }
        
//        delegate!.tableViewWillBeginLoading?(self.tableView)
        
        switch cell {
        case let cell as DisplayTableViewCell:
            cell.configure(nil, with: homeViewController)
            
        case let cell as RatableTableViewCell:
            cell.configure(section, with: homeViewController)
            
        case let cell as ResumableTableViewCell:
            cell.configure(section, with: homeViewController)
            
        case let cell as BlockbusterTableViewCell:
            cell.configure(section, with: homeViewController)
            
        case let cell as MyListTableViewCell:
            cell.configure(homeViewController.homeViewModel.section(at: .myList), with: homeViewController)
            
        case let cell as StandardTableViewCell:
            cell.configure(section, with: homeViewController)
            
        default: return
        }
    }
    
    func typeForRow(in section: Int) -> UITableViewCell.Type {
        guard let indices: SectionIndices = .init(rawValue: section) else {
            return UITableViewCell.self
        }
        
        switch indices {
        case .display: return DisplayTableViewCell.self
        case .ratable: return RatableTableViewCell.self
        case .resumable: return ResumableTableViewCell.self
        case .blockbuster: return BlockbusterTableViewCell.self
        case .myList: return MyListTableViewCell.self
        default: return StandardTableViewCell.self
        }
    }
    
    func tableViewDidShow(_ tableView: UITableView) {
        UIView.animate(withDuration: 1.0, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.tableView.alpha = .shown
        }
    }

    func tableViewDidHide(_ tableView: UITableView) {
        UIView.animate(withDuration: 1.0, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.tableView.alpha = .hidden
        }
    }
    
    func tableViewWillBeginLoading(_ tableView: UITableView) {
        guard
            let homeViewController = homeViewController,
            let delegate = delegate,
            let placeholderViewDelegate = homeViewController.placeholderView.delegate
        else {
            return
        }
        
        guard requiresInitialLoading else {
            return
        }
        
        placeholderViewDelegate.placeholderViewDidShow(tableView)
        delegate.tableViewDidHide!(tableView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak delegate] in
            guard let delegate = delegate else {
                return
            }
            
            placeholderViewDelegate.placeholderViewDidHide(tableView)
            delegate.tableViewDidShow!(tableView)
        }
        
        requiresInitialLoading = false
    }
}



// MARK: - UITableViewDelegate & UITableViewDataSource Implementation

extension TableViewSnapshot: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return .default
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let indices: SectionIndices = .init(rawValue: indexPath.section),
            let type = typeForRow(in: indices.rawValue) as UITableViewCell.Type?
        else {
            DispatchError.unexpectedIndexPathForSection(indexPath.section).dispatch
        }
        
        switch indices {
        case .display:
            singleCell = tableView.dequeueCell(for: type, at: indexPath)! as? DisplayTableViewCell
            return singleCell
            
        case .ratable:
            ratableCell = tableView.dequeueCell(for: type, at: indexPath)! as? RatableTableViewCell
            return ratableCell
            
        case .resumable:
            resumableCell = tableView.dequeueCell(for: type, at: indexPath)! as? ResumableTableViewCell
            return resumableCell
            
        case .blockbuster:
            blockbusterCell = tableView.dequeueCell(for: type, at: indexPath)! as? BlockbusterTableViewCell
            return blockbusterCell
            
        case .myList:
            myListCell = tableView.dequeueCell(for: type, at: indexPath)! as? MyListTableViewCell
            return myListCell
            
        default:
            let identifier: StandardTableViewCell.Identifier = .init(rawValue: indices.rawValue)!
            
            standardCell = tableView.dequeueCell(for: type, as: identifier, at: indexPath)! as? StandardTableViewCell
            return standardCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let homeViewController = homeViewController else {
            return .zero
        }
        
        guard let indices: SectionIndices = .init(rawValue: indexPath.section) else {
            return .zero
        }
        
        switch indices {
        case .display: return homeViewController.view.bounds.height * 0.72
        case .blockbuster: return .blockbusterHeight
        case .resumable: return .resumableHeight
        default: return homeViewController.view.bounds.height * 0.28 - 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleHeaderView.reuseIdentifier) as? TitleHeaderView,
            let indices: SectionIndices = .init(rawValue: section)
        else {
            return nil
        }
        
        let title = "\(sections[indices.rawValue].title)"
        let font = UIFont.boldSystemFont(ofSize: 17.0)
        
        header.titleLabel.text = title
        header.titleLabel.font = font
        
        header.backgroundView = .init()
        header.backgroundView?.backgroundColor = .black
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let indices: SectionIndices = .init(rawValue: section) else {
            return .zero
        }
        
        switch indices {
        case .display: return 0.0
        case .ratable: return 24.0 + 4.0
        case .myList: return 4.0
        case .resumable: return 24.0
        default: return 24.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        
        delegate.tableView?(tableView, willConfigure: cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let indices: SectionIndices = .init(rawValue: indexPath.section) else {
            return
        }
        
        switch indices {
        case .display: break
        case .ratable: ratableCell = nil
        case .resumable: resumableCell = nil
        case .blockbuster: blockbusterCell = nil
        case .myList: myListCell = nil
        default: standardCell = nil
        }
    }
}



// MARK: - UITableViewDataSourcePrefetching Implementation

extension TableViewSnapshot: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard
                let indices: SectionIndices = .init(rawValue: indexPath.section),
                let delegate = delegate
            else {
                return
            }
            
            switch indices {
            case .display:
                guard singleCell == nil else { return }
                
                singleCell = tableView.dequeueCell(for: DisplayTableViewCell.self, at: indexPath)! as? DisplayTableViewCell
                
//                delegate.tableView?(self.tableView, willConfigure: singleCell, at: indexPath)
                
            case .ratable:
                guard ratableCell == nil else { return }
                
                ratableCell = tableView.dequeueCell(for: RatableTableViewCell.self, at: indexPath)! as? RatableTableViewCell
                
//                delegate.tableView?(self.tableView, willConfigure: ratableCell, at: indexPath)
                
            case .resumable:
                guard resumableCell == nil else { return }
                
                resumableCell = tableView.dequeueCell(for: ResumableTableViewCell.self, at: indexPath)! as? ResumableTableViewCell
                
//                delegate.tableView?(self.tableView, willConfigure: resumableCell, at: indexPath)
                
            case .blockbuster:
                guard blockbusterCell == nil else { return }
                
                blockbusterCell = tableView.dequeueCell(for: BlockbusterTableViewCell.self, at: indexPath)! as? BlockbusterTableViewCell
                
//                delegate.tableView?(self.tableView, willConfigure: blockbusterCell, at: indexPath)
                
            case .myList:
                guard myListCell == nil else { return }
                
                myListCell = tableView.dequeueCell(for: MyListTableViewCell.self, at: indexPath)! as? MyListTableViewCell
                
//                delegate.tableView?(self.tableView, willConfigure: myListCell, at: indexPath)
                
            default:
                guard standardCell == nil else { return }
                
                standardCell = tableView.cellForRow(at: indexPath) as? StandardTableViewCell
            }
        }
    }
}



// MARK: - UIScrollViewDelegate Implementation

extension TableViewSnapshot {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            let homeViewController = homeViewController,
            let view = homeViewController.view,
            let constraint = homeViewController.navigationViewHeight,
            let translation = scrollView.panGestureRecognizer.translation(in: view) as CGPoint?
        else {
            return
        }
        
        translation.y < 0 ? {
            constraint.constant = .hidden
        }() : {
            constraint.constant = .navigationViewHeight
        }()
        
        UIView.animate(withDuration: 0.33) {
            translation.y < 0 ? {
                homeViewController.navigationView.alpha = .hidden
                homeViewController.statusBarBackgroundView.alpha = .hidden
            }() : {
                homeViewController.navigationView.alpha = .shown
                homeViewController.statusBarBackgroundView.alpha = .shown
            }()
            
            view.layoutIfNeeded()
        }
    }
}
