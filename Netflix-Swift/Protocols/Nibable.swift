//
//  Nibable.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/02/2022.
//

import UIKit

// MARK: - Nibable

protocol Nibable {
    var contentView: UIView! { get set }
}


// MARK: - Nibable Implementation

extension Nibable {
    
    func loadNib() {
        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        (self as! UIView).addSubview(contentView!)
        contentView!.frame = (self as! UIView).bounds
        contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
