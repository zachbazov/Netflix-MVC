//
//  DetailDescriptionView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/03/2022.
//

import UIKit

// MARK: - DetailDescriptionViewDelegate

protocol DetailDescriptionViewDelegate: AnyObject {
    func detailDescriptionViewDidSetup(_ detailDescriptionView: DetailDescriptionView)
}


// MARK: - DetailDescriptionView

final class DetailDescriptionView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private weak var descriptionTextView: UITextView! = nil
    @IBOutlet private weak var castLabel: UILabel! = nil
    @IBOutlet private weak var writersLabel: UILabel! = nil
    
    weak var delegate: DetailDescriptionViewDelegate! = nil
    
    weak var detailViewController: DetailViewController! = nil {
        didSet {
            guard let delegate = delegate else { return }
            delegate.detailDescriptionViewDidSetup(self)
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
    }
    
    deinit {
        delegate = nil
        detailViewController = nil
    }
}


// MARK: - DetailDescriptionViewDelegate Implementation

extension DetailDescriptionView: DetailDescriptionViewDelegate {
    
    func detailDescriptionViewDidSetup(_ detailDescriptionView: DetailDescriptionView) {
        guard
            let detailViewController = detailViewController,
            let homeViewController = detailViewController.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else { return }
        guard let media = homeViewModel.detailMedia else { return }
        detailDescriptionView.descriptionTextView.text = media.description
        detailDescriptionView.descriptionTextView.flashScrollIndicators()
        detailDescriptionView.castLabel.text = "Cast: \(media.cast ?? "N/A")"
        switch homeViewModel.currentSnapshot {
        case .tvShows:
            break
        case .movies:
            detailDescriptionView.writersLabel.text = "Writers: \(media.writers ?? "N/A")"
        }
    }
}
