//
//  BlockbusterCollectionViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 10/03/2022.
//

import UIKit

// MARK: - BlockbusterCollectionViewCell

final class BlockbusterCollectionViewCell: CollectionViewCell {
    
    // MARK: Properties
    
    @IBOutlet private weak var gradientView: UIView! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.gradientView.addGradientLayer(frame: self.gradientView.bounds,
                                           colors: [.clear,
                                                    .black.withAlphaComponent(1.0)],
                                           locations: [0.0, 0.66])
        self.coverOverlayView.addGradientLayer(frame: self.coverOverlayView.bounds,
                                           colors: [.clear,
                                                    .black.withAlphaComponent(0.33)],
                                           locations: [0.0, 0.66])
    }
    
    deinit {
        gradientView.removeFromSuperview()
        coverOverlayView.removeFromSuperview()
    }
}
