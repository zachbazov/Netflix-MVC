//
//  StandardCollectionViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/02/2022.
//

import UIKit

// MARK: - StandardCollectionViewCell

final class StandardCollectionViewCell: CollectionViewCell {
    
    // MARK: Initialization & Deinitialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.coverOverlayView.addGradientLayer(frame: self.coverOverlayView.bounds,
                                               colors: [.clear,
                                                        .black.withAlphaComponent(0.33)],
                                               locations: [0.0, 0.66])
    }
    
    deinit {
        coverOverlayView.removeFromSuperview()
    }
}
