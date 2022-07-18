//
//  ResumableCollectionViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 15/02/2022.
//

import UIKit

// MARK: - ResumableCollectionViewCell

final class ResumableCollectionViewCell: CollectionViewCell {
    
    // MARK: Properties
    
    @IBOutlet private weak var actionBoxView: UIView! = nil
    
    @IBOutlet private weak var optionsButton: UIButton! = nil
    
    @IBOutlet private weak var infoButton: UIButton! = nil
    
    @IBOutlet private(set) weak var lengthLabel: UILabel! = nil
    
    @IBOutlet private weak var gradientView: UIView! = nil
    
    @IBOutlet private weak var playButton: UIButton! = nil
    
    
    private var requireTransform = true
    
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.playButton.layer.borderWidth = 2.0
        self.playButton.layer.borderColor = UIColor.white.cgColor
        self.playButton.layer.cornerRadius = playButton.bounds.size.height / 2
        
        self.gradientView.addGradientLayer(frame: gradientView.bounds,
                                           colors: [.clear,
                                                    .black.withAlphaComponent(0.75)],
                                           locations: [0.0, 1.0])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard requireTransform else {
            return
        }
        
        optionsButton.transform = optionsButton.transform.rotated(by: CGFloat(Double.pi / 2))
        
        requireTransform = false
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            guard let homeViewController = homeViewController else {
                return
            }
            
            homeViewController.segue.current = .detail
            
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            
        default: return
        }
    }
}
