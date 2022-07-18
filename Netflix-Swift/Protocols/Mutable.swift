//
//  Mutable.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/06/2022.
//

import UIKit

// MARK: - Mutable

protocol Mutable {
    
    associatedtype Cell where Cell: UICollectionViewCell
    
    func sort(_ sortOptions: TableViewCell<Cell>.SortOptions, sliceBy length: Int) -> SectionViewModel?
    
    func slice(_ length: Int) -> SectionViewModel?
}
