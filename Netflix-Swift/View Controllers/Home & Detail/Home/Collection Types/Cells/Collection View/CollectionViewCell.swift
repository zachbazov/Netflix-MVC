//
//  CollectionViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 22/06/2022.
//

import UIKit

// MARK: - CollectionViewCell

class CollectionViewCell: UICollectionViewCell, Attributable {
    
    // MARK: Properties
    
    @IBOutlet weak var coverImageView: UIImageView! = nil
    
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Deinitialization
    
    deinit {
        homeViewController = nil
    }
    
    
    // MARK:
    
    func configure(_ cell: CollectionViewCell?,
                   section: SectionViewModel? = nil,
                   media: MediaViewModel? = nil,
                   image: UIImage? = nil,
                   attributes: (NSString, UIImage)? = nil,
                   at indexPath: IndexPath? = nil,
                   with homeViewController: HomeViewController? = nil) {
        
        switch cell {
        case let cell as RatableCollectionViewCell:
            
            guard
                let indexPath = indexPath,
                let image = attributes?.1 as UIImage?
            else {
                return
            }
            
            if indexPath.row == 0 {
                cell.textLayerView.frame = CGRect(x: 0.0, y: -30.0,
                                             width: bounds.width, height: 160.0)
            } else {
                cell.textLayerView.frame = CGRect(x: -8.0, y: -30.0,
                                             width: bounds.width, height: 160.0)
            }
            
            let index = "\(indexPath.row + 1)"
            let attributedString = NSAttributedString(string: index,
                                                      attributes: [.font: UIFont(name: "NoticiaText-Bold",
                                                                                 size: 96.0)!,
                                                                   .strokeColor: UIColor.white,
                                                                   .strokeWidth: -2.5,
                                                                   .foregroundColor: UIColor.black.cgColor])
            
            cell.layerContainer.layer.insertSublayer(cell.textLayerView, at: 1)
            
            cell.textLayerView.string = attributedString
            
            coverImageView.contentMode = .scaleAspectFill
            coverImageView.image = image
            
        case let cell as ResumableCollectionViewCell:
            
            if let homeViewController = homeViewController as HomeViewController? {
                self.homeViewController = homeViewController
                
                switch homeViewController.homeViewModel.currentSnapshot {
                case .tvShows:
                    guard
                        let media = media,
                        let duration = media.duration! as String?
                    else {
                        return
                    }
                    
                    cell.lengthLabel.text = duration
                    
                case .movies:
                    guard
                        let media = media,
                        let length = media.length! as String?
                    else {
                        return
                    }
                    
                    cell.lengthLabel.text = length
                }
                
                coverImageView.contentMode = .scaleAspectFill
                coverImageView.image = image
            }
            
        default:
            coverImageView.contentMode = .scaleAspectFill
            coverImageView.image = image
        }
    }
}
