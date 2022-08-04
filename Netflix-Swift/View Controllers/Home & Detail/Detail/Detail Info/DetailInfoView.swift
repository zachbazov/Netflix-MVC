//
//  DetailInfoView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/03/2022.
//

import UIKit

// MARK: - DetailInfoViewDelegate

protocol DetailInfoViewDelegate: AnyObject {
    func detailInfoViewDidSetup(_ detailInfoView: DetailInfoView)
}


// MARK: - DetailInfoView

final class DetailInfoView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private weak var gradientView: UIView! = nil
    @IBOutlet private weak var titleLabel: UILabel! = nil
    @IBOutlet private weak var yearLabel: UILabel! = nil
    @IBOutlet private weak var ageRestrictionView: AgeRestrictionView! = nil
    @IBOutlet private weak var lengthLabel: UILabel! = nil
    @IBOutlet private weak var hdView: HDView! = nil
    @IBOutlet private weak var playButton: UIButton! = nil
    @IBOutlet private weak var downloadButton: UIButton! = nil
    
    weak var delegate: DetailInfoViewDelegate! = nil
    
    weak var detailViewController: DetailViewController! = nil {
        didSet {
            guard let delegate = delegate else { return }
            delegate.detailInfoViewDidSetup(self)
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
        self.gradientView.addGradientLayer(frame: gradientView.bounds,
                                           colors: [.init(red: 25.0/255,
                                                          green: 25.0/255,
                                                          blue: 25.0/255,
                                                          alpha: 1.0),
                                                    .clear],
                                           locations: [0.3, 1.0])
    }
    
    deinit {
        delegate = nil
        detailViewController = nil
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        switch sender.tag {
        case 0: UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        case 1: return
        default: return
        }
    }
}


// MARK: - DetailInfoViewDelegate Implementation

extension DetailInfoView: DetailInfoViewDelegate {
    
    func detailInfoViewDidSetup(_ detailInfoView: DetailInfoView) {
        guard
            let detailViewController = detailViewController,
            let homeViewController = detailViewController.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else { return }
        guard
            let media = homeViewModel.detailMedia,
            let title = media.title,
            let downloadTitle = "Download \(title)" as String?
        else { return }
        detailInfoView.titleLabel.text = media.title
        switch homeViewModel.currentSnapshot {
        case .tvShows:
            guard let duration = media.duration else {
                detailInfoView.yearLabel.text = "N/A"
                return
            }
            detailInfoView.yearLabel.text = String(describing: duration)
            detailInfoView.lengthLabel.text = String(describing: media.seasonCount!)
        case .movies:
            guard let year = media.year else {
                detailInfoView.yearLabel.text = "N/A"
                return
            }
            detailInfoView.yearLabel.text = String(describing: year)
            detailInfoView.lengthLabel.text = media.length
        }
        _ = detailInfoView.hdView.isHidden ? (media.isHD ?? true) : false
        detailInfoView.downloadButton.setTitle(downloadTitle, for: .normal)
    }
}
