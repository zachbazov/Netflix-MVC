//
//  MediaDisplayView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/03/2022.
//

import UIKit

// MARK: - MediaDisplayViewDelegate

protocol MediaDisplayViewDelegate: AnyObject {
    func mediaDisplayView(_ mediaDisplayView: MediaDisplayView, willDisplay media: MediaViewModel)
    func mediaDisplayView(_ mediaDisplay: MediaDisplayView, genreForItem media: MediaViewModel)
}


// MARK: - MediaDisplayView

final class MediaDisplayView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private(set) weak var coverImageView: UIImageView! = nil
    @IBOutlet private weak var logoImageView: UIImageView! = nil
    @IBOutlet private weak var bottomGradientView: UIView! = nil
    @IBOutlet private(set) weak var genresLabel: UILabel! = nil
    @IBOutlet weak var typeImageView: UIImageView!
    
    private var mediaViewModel: MediaViewModel! = nil
    
    private weak var delegate: MediaDisplayViewDelegate! = nil
    
    weak var homeViewController: HomeViewController! = nil {
        didSet {
            guard
                let homeViewController = homeViewController,
                let homeViewModel = homeViewController.homeViewModel as HomeViewModel?,
                let delegate = delegate
            else { return }
            homeViewModel.currentSnapshot == .tvShows ? {
                guard homeViewModel.currentSnapshot != .movies else { return }
            }() : {
                guard homeViewModel.currentSnapshot != .tvShows else { return }
            }()
            guard mediaViewModel != homeViewController.homeViewModel.displayMedia! else { return }
            mediaViewModel = homeViewController.homeViewModel.displayMedia!
            delegate.mediaDisplayView(self, willDisplay: mediaViewModel)
            delegate.mediaDisplayView(self, genreForItem: mediaViewModel)
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
        self.bottomGradientView.addGradientLayer(frame: bottomGradientView.bounds,
                                                 colors: [.clear, .black],
                                                 locations: [0.0, 0.66])
    }
    
    deinit {
        bottomGradientView.removeFromSuperview()
        delegate = nil
        mediaViewModel = nil
        homeViewController = nil
    }
}


// MARK: - MediaDisplayViewDelegate Implementation

extension MediaDisplayView: MediaDisplayViewDelegate {
    
    func mediaDisplayView(_ mediaDisplayView: MediaDisplayView, willDisplay media: MediaViewModel) {
        guard
            let displayCover = media.displayCover,
            let logo = media.logo,
            let coverURL = URL(string: displayCover),
            let logoURL = URL(string: logo),
            let identifier = "MediaDisplayView.cover.\(media.id!)" as NSString?,
            let logoIdentifier = "MediaDisplayView.logo.\(media.id!)" as NSString?
        else { return }
        URLService.shared.load(url: coverURL, identifier: identifier) { [weak self] image in
            guard
                let self = self,
                let homeViewController = self.homeViewController,
                let blurryView = homeViewController.navigationOverlayView.blurryView,
                let blurryViewDelegate = blurryView.delegate
            else { return }
            DispatchQueue.main.async {
                self.coverImageView.image = image
                blurryViewDelegate.blurryView(blurryView, insertImage: image)
            }
        }
        URLService.shared.load(url: logoURL, identifier: logoIdentifier) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.logoImageView.image = image
                if self.homeViewController.homeViewModel.currentSnapshot == .tvShows {
                    self.typeImageView.image = UIImage(named: "netflix-series")
                } else {
                    self.typeImageView.image = nil
                }
            }
        }
    }
    
    func mediaDisplayView(_ mediaDisplay: MediaDisplayView, genreForItem media: MediaViewModel) {
        let genresLabelSeparator = " · "
        guard
            let symbol = genresLabelSeparator as String?,
            let genres = media.genres
        else { return }
        let fontSize = CGFloat(16.0)
        let separatorSize = CGFloat(24.0)
        let mutableGenresString = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.init(name: "MontserratRoman-SemiBold", size: fontSize)!]
        let attributedGenres = genres.enumerated().map {
            NSAttributedString(string: $0.element, attributes: attributes)
        }
        for attributedGenre in attributedGenres {
            mutableGenresString.append(attributedGenre)
            let separatorAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: separatorSize, weight: .heavy)]
            let attributedSeparator = NSAttributedString(string: symbol, attributes: separatorAttributes)
            if attributedGenre == attributedGenres.last { continue }
            mutableGenresString.append(attributedSeparator)
        }
        guard let label = mediaDisplay.genresLabel else { return }
        DispatchQueue.main.async {
            label.attributedText = mutableGenresString
        }
    }
}
