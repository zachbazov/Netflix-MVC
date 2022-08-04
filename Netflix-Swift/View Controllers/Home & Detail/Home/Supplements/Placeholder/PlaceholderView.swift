//
//  PlaceholderView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 19/05/2022.
//

import UIKit

// MARK: - PlaceholderViewDelegate

protocol PlaceholderViewDelegate: AnyObject {
    func placeholderViewDidShow(_ tableView: UITableView)
    func placeholderViewDidHide(_ tableView: UITableView)
}


// MARK: - PlaceholderView

final class PlaceholderView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    
    weak var delegate: PlaceholderViewDelegate! = nil
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
    }
}


// MARK: - PlaceholderDelegate Implementation

extension PlaceholderView: PlaceholderViewDelegate {
    
    func placeholderViewDidShow(_ tableView: UITableView) {
        UIView.animate(withDuration: 1.0,
                       delay: 0.1,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            self.alpha = .shown
        }
    }
    
    func placeholderViewDidHide(_ tableView: UITableView) {
        UIView.animate(withDuration: 1.0,
                       delay: 0.1,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) { [weak self] in
            guard let self = self else { return }
            self.alpha = .hidden
        }
    }
}
