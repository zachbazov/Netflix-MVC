//
//  UITableView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/03/2022.
//

import UIKit

// MARK: - UITableView

extension UITableView {
    
    func register<T: UITableViewCell>(class cell: T.Type) {
        self.register(cell, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UITableViewCell>(nib cell: T.Type) {
        self.register(cell.nib, forCellReuseIdentifier: cell.reuseIdentifier)
    }
    
    func register(_ identifiers: [String]) {
        for identifier in identifiers {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }
    
    func register<T: UITableViewHeaderFooterView>(_ headerFooterType: T.Type) {
        self.register(headerFooterType, forHeaderFooterViewReuseIdentifier: headerFooterType.reuseIdentifier)
    }
    
    
    func dequeueCell<T>(for cell: T.Type,
                        as identifier: StandardTableViewCell.Identifier? = nil,
                        at indexPath: IndexPath) -> UITableViewCell?
    where T: UITableViewCell {
        let identifier = identifier != nil ? identifier!.stringValue : cell.reuseIdentifier
        
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell \(cell.reuseIdentifier)")
        }
        
        return cell
    }
}
