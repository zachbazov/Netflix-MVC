//
//  MediaPlayerView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 25/03/2022.
//

import AVKit

// MARK: - MediaPlayerConfigurationDelegate

protocol MediaPlayerConfigurationDelegate: AnyObject {
    func configurationDidRegisterRecognizers(_ configuration: MediaPlayerConfiguration)
}



// MARK: - MediaPlayerConfiguration

final class MediaPlayerConfiguration {
    
    // MARK: Properties
    
    private var gesture: UITapGestureRecognizer! = nil
    
    
    private(set) var overlayDuration: CGFloat = 3.0
    
    
    private var color: UIColor = .black
    
    private var alpha: CGFloat = 0.7
    
    
    private weak var delegate: MediaPlayerConfigurationDelegate! = nil
    
    
    private weak var mediaPlayerView: MediaPlayerView! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    init(_ mediaPlayerView: MediaPlayerView) {
        self.mediaPlayerView = mediaPlayerView
        
        self.delegate = self
        
        self.delegate.configurationDidRegisterRecognizers(self)
    }
    
    deinit {
        gesture = nil
        delegate = nil
        mediaPlayerView = nil
    }
}



// MARK: - MediaPlayerConfigurationDelegate Implementation

extension MediaPlayerConfiguration: MediaPlayerConfigurationDelegate {
    
    func configurationDidRegisterRecognizers(_ configuration: MediaPlayerConfiguration) {
        guard
            let mediaPlayerView = mediaPlayerView,
            let mediaOverlayView = mediaPlayerView.mediaOverlayView,
            let mediaOverlayViewDelegate = mediaOverlayView.delegate
        else {
            return
        }
        
        gesture = UITapGestureRecognizer(target: mediaOverlayView,
                                         action: #selector(mediaOverlayViewDelegate.mediaOverlayViewDidShow))
        
        mediaOverlayView.addGestureRecognizer(gesture)
    }
}



// MARK: - MediaPlayerDelegate

protocol MediaPlayerViewDelegate: AnyObject {
    
    func mediaPlayerDidSetup(_ mediaPlayer: MediaPlayer)
    
    func mediaPlayerWillPlayMedia(_ mediaPlayer: MediaPlayer)
    
    func mediaPlayerWillStopPlaying(_ mediaPlayer: MediaPlayer)
    
    func mediaPlayer(_ mediaPlayer: MediaPlayer, itemDidChange media: MediaViewModel)
    
    func mediaPlayerShouldVerifyUrl(of urlString: String) -> Bool
}



// MARK: - MediaPlayerView

final class MediaPlayerView: UIView, Nibable {
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    
    @IBOutlet private(set) weak var mediaPlayer: MediaPlayer! = nil
    
    @IBOutlet private(set) weak var mediaOverlayView: MediaOverlayView! = nil
    
    @IBOutlet private(set) weak var maskedView: MaskView! = nil
    
    
    private(set) var mediaPlayerViewModel: MediaPlayerViewModel = .init()
    
    
    let player: AVPlayer = .init()
    
    
    private(set) var configuration: MediaPlayerConfiguration! = nil
    
    
    weak var delegate: MediaPlayerViewDelegate! = nil
    
    
    weak var detailViewController: DetailViewController! = nil {
        didSet {
            guard let delegate = delegate else {
                return
            }
            
            delegate.mediaPlayerDidSetup(mediaPlayer)
            delegate.mediaPlayerWillPlayMedia(mediaPlayer)
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.loadNib()
        
        self.configuration = .init(self)
        
        self.mediaOverlayView.mediaPlayerView = self
        
        self.delegate = self
    }
    
    deinit {
        mediaPlayer.player = nil
        
        configuration = nil
        
        mediaPlayer = nil
        mediaOverlayView.mediaPlayerView = nil
        mediaOverlayView = nil
        
        delegate = nil
    }
}



// MARK: - MediaPlayerDelegate Implementation

extension MediaPlayerView: MediaPlayerViewDelegate {
    
    func mediaPlayerDidSetup(_ mediaPlayer: MediaPlayer) {
        mediaPlayer.player = player
        mediaPlayer.playerLayer.videoGravity = .resizeAspectFill
        mediaPlayer.playerLayer.frame = mediaPlayer.bounds
    }
    
    func mediaPlayerWillPlayMedia(_ mediaPlayer: MediaPlayer) {
        guard
            let detailViewController = detailViewController,
            let homeViewController = detailViewController.homeViewController,
            let detailViewModel = detailViewController.detailViewModel as DetailViewModel?,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else {
            return
        }
        
        switch homeViewModel.currentSnapshot {
        case .tvShows:
            guard
                let previewURL = homeViewModel.detailMedia!.trailers?.first,
                let url = URL(string: previewURL),
                mediaPlayerShouldVerifyUrl(of: url.absoluteURL.absoluteString)
            else {
                return
            }
            
            let playerItem = AVPlayerItem(url: url)
            
            player.replaceCurrentItem(with: playerItem)
            player.play()
            
        case .movies:
            guard
                let previewURL = homeViewModel.detailMedia!.previewURL,
                let url = URL(string: previewURL),
                mediaPlayerShouldVerifyUrl(of: url.absoluteURL.absoluteString)
            else {
                return
            }
            
            let playerItem = AVPlayerItem(url: url)
            
            player.replaceCurrentItem(with: playerItem)
            player.play()
            
        default: return
        }
        
        detailViewModel.scheduledTimer?.delegate.startTimer()
    }
    
    func mediaPlayerWillStopPlaying(_ mediaPlayer: MediaPlayer) {
        guard player.currentItem != nil else {
            return
        }
        
        self.player.replaceCurrentItem(with: nil)
    }
    
    func mediaPlayer(_ mediaPlayer: MediaPlayer, itemDidChange media: MediaViewModel) {
        guard
            let detailViewController = detailViewController,
            let homeViewController = detailViewController.homeViewController,
            let homeViewModel = homeViewController.homeViewModel as HomeViewModel?
        else {
            return
        }
        
        switch homeViewModel.currentSnapshot {
        case .tvShows:
            guard
                let player = mediaPlayer.player,
                let preview = media.trailers!.first,
                let previewURL = URL(string: preview)
            else {
                return
            }
            
            DispatchQueue.main.async { [weak player, weak mediaOverlayView] in
                
                guard
                    let mediaOverlayView = mediaOverlayView,
                    let mediaOverlayViewDelegate = mediaOverlayView.delegate
                else {
                    return
                }
                
                player!.replaceCurrentItem(with: AVPlayerItem(url: previewURL))
                
                mediaOverlayViewDelegate.mediaOverlayViewDidEntitle(media.title ?? "")
            }
            
        case .movies:
            guard
                let player = mediaPlayer.player,
                let preview = media.previewURL,
                let previewURL = URL(string: preview)
            else {
                return
            }
            
            DispatchQueue.main.async { [weak player, weak mediaOverlayView] in
                
                guard
                    let mediaOverlayView = mediaOverlayView,
                    let mediaOverlayViewDelegate = mediaOverlayView.delegate
                else {
                    return
                }
                
                player!.replaceCurrentItem(with: AVPlayerItem(url: previewURL))
                
                mediaOverlayViewDelegate.mediaOverlayViewDidEntitle(media.title ?? "")
            }
            
        default: return
        }
    }
    
    func mediaPlayerShouldVerifyUrl(of urlString: String) -> Bool {
        guard let urlString = urlString as String? else {
            return false
        }
        
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        
        return false
    }
}
