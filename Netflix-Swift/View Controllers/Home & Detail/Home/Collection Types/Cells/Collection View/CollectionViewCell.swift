//
//  CollectionViewCell.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 22/06/2022.
//

import UIKit

enum LogoPosition: String {
    case top,
         midTop = "mid-top",
         mid,
         bottomMid = "mid-bottom",
         bottom
}


// MARK: - CollectionViewCell

class CollectionViewCell: UICollectionViewCell, Attributable {
    
    // MARK: Properties
    
    @IBOutlet weak var coverImageView: UIImageView! = nil
    @IBOutlet weak var logoImageView: UIImageView! = nil
    @IBOutlet weak var coverOverlayView: UIView! = nil
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint! = nil
    
    var representedIdentifier: NSString?
    
    weak var homeViewController: HomeViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .black
    }
    
    deinit {
        homeViewController = nil
    }
    
    
    // MARK:
    
    func configure(section: SectionViewModel? = nil,
                   media: MediaViewModel? = nil,
                   cover: UIImage? = nil,
                   logo: UIImage? = nil,
                   at indexPath: IndexPath? = nil,
                   with homeViewController: HomeViewController? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.coverImageView.contentMode = .scaleAspectFill
            self.coverImageView.image = cover
            self.logoImageView.image = logo
            switch media?.logoPosition {
            case "top":
                self.logoBottomConstraint.constant = self.coverImageView.bounds.maxY - self.logoImageView.bounds.size.height
            case "mid-top":
                self.logoBottomConstraint.constant = 64.0
            case "mid":
                self.logoBottomConstraint.constant = 40.0
            case "mid-bottom":
                self.logoBottomConstraint.constant = 24.0
            case "bottom":
                self.logoBottomConstraint.constant = 8.0
            default:
                break
            }
        }
        switch self {
        case let cell as RatableCollectionViewCell:
            guard let indexPath = indexPath else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if indexPath.row == 0 {
                    cell.textLayerView.frame = CGRect(x: 0.0, y: -30.0,
                                                      width: self.bounds.width, height: 160.0)
                } else {
                    cell.textLayerView.frame = CGRect(x: -8.0, y: -30.0,
                                                      width: self.bounds.width, height: 160.0)
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
            }
        case let cell as ResumableCollectionViewCell:
            if let homeViewController = homeViewController as HomeViewController? {
                self.homeViewController = homeViewController
                switch homeViewController.homeViewModel.currentSnapshot {
                case .tvShows:
                    guard
                        let media = media,
                        let duration = media.duration! as String?
                    else { return }
                    DispatchQueue.main.async {
                        cell.lengthLabel.text = duration
                    }
                case .movies:
                    guard
                        let media = media,
                        let length = media.length! as String?
                    else { return }
                    DispatchQueue.main.async {
                        cell.lengthLabel.text = length
                    }
                }
            }
        case let cell as BlockbusterCollectionViewCell:
            DispatchQueue.main.async {
                cell.logoBottomConstraint.constant = 48.0
            }
        default: break
        }
    }
}
