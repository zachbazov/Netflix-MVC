//
//  DetailPreviewView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 16/03/2022.
//

import UIKit

// MARK: - DetailPreviewViewDelegate

protocol DetailPreviewViewDelegate: AnyObject {
    func detailPreviewViewDidConfigureImage(_ detailPreviewView: DetailPreviewView)
    func detailPreviewViewDidChangePipeStream(_ detailPreviewView: DetailPreviewView)
}


// MARK: - DetailPreviewView

final class DetailPreviewView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private(set) weak var imageView: UIImageView! = nil
    @IBOutlet private(set) weak var mediaPlayerView: MediaPlayerView! = nil
    
    weak var detailViewController: DetailViewController! = nil {
        didSet {
            guard let delegate = delegate else { return }
            delegate.detailPreviewViewDidConfigureImage(self)
            delegate.detailPreviewViewDidChangePipeStream(self)
        }
    }
    
    weak var delegate: DetailPreviewViewDelegate! = nil
    
    
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


// MARK: - DetailPreviewViewDelegate Implementation

extension DetailPreviewView: DetailPreviewViewDelegate {
    
    func detailPreviewViewDidConfigureImage(_ detailPreviewView: DetailPreviewView) {
        guard
            let detailViewController = detailViewController,
            let homeViewController = detailViewController.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?,
            let media = homeViewModel.detailMedia,
            let identifier = media.title! as NSString?,
            let detailCover = media.detailCover,
            let url = URL(string: detailCover)
        else { return }
        URLService.shared.load(url: url, identifier: identifier) { [weak imageView] image in
            guard let imageView = imageView else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
    }
    
    func detailPreviewViewDidChangePipeStream(_ detailPreviewView: DetailPreviewView) {
        guard let detailViewController = detailViewController else { return }
        WeakInjector.shared.inject(mediaPlayerView, with: detailViewController)
    }
}
