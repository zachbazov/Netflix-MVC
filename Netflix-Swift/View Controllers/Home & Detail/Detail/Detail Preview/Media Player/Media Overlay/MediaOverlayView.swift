//
//  MediaOverlayView.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 06/04/2022.
//

import AVKit
import Combine

// MARK: - MediaOverlayViewDelegate

@objc protocol MediaOverlayViewDelegate: AnyObject {
    func mediaOverlayViewDidSetup(_ mediaOverlayView: MediaOverlayView)
    func mediaOverlayViewDidRegisterObservers(_ mediaOverlayView: MediaOverlayView)
    func mediaOverlayViewDidSetupPlayButton(_ mediaOverlayView: MediaOverlayView)
    func mediaOverlayViewDidChangeOverlayState(_ mediaOverlayView: MediaOverlayView)
    func mediaOverlayViewDidEntitle(_ title: String)
    @objc func mediaOverlayViewDidShow()
    @objc func mediaOverlayViewDidHide()
}


// MARK: - MediaOverlayView

final class MediaOverlayView: UIView, Nibable {
    
    // MARK: State
    
    private enum State: Int {
        case airPlay, rotate, backward, play, forward, mute
    }
    
    
    // MARK: Properties
    
    @IBOutlet weak var contentView: UIView! = nil
    @IBOutlet private(set) weak var rotateButton: UIButton! = nil
    @IBOutlet private(set) weak var airPlayButton: UIButton! = nil
    @IBOutlet private(set) weak var playButton: UIButton! = nil
    @IBOutlet private(set) weak var muteButton: UIButton! = nil
    @IBOutlet private(set) weak var progressView: UIProgressView! = nil
    @IBOutlet private(set) weak var trackingSlider: UISlider! = nil
    @IBOutlet private(set) weak var titleLabel: UILabel! = nil
    @IBOutlet private(set) weak var slashLabel: UILabel! = nil
    @IBOutlet private(set) weak var backwardButton: UIButton! = nil
    @IBOutlet private(set) weak var forwardButton: UIButton! = nil
    @IBOutlet private(set) weak var startTimeLabel: UILabel! = nil
    @IBOutlet private(set) weak var durationLabel: UILabel! = nil
    
    var timeObserverToken: Any! = nil
    var playerItemStatusObserver: NSKeyValueObservation! = nil
    var playerItemFastForwardObserver: NSKeyValueObservation! = nil
    var playerItemReverseObserver: NSKeyValueObservation! = nil
    var playerItemFastReverseObserver: NSKeyValueObservation! = nil
    var playerTimeControlStatusObserver: NSKeyValueObservation! = nil
    var playerItemDidEndPlayObserver: AnyCancellable! = nil
    var cancelBag: Set<AnyCancellable> = []
    
    weak var delegate: MediaOverlayViewDelegate! = nil
    
    weak var mediaPlayerView: MediaPlayerView! = nil {
        didSet {
            guard let delegate = delegate else { return }
            delegate.mediaOverlayViewDidRegisterObservers(self)
            delegate.mediaOverlayViewDidSetup(self)
        }
    }
    
    
    // MARK: Initialization & Deinitialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNib()
        self.delegate = self
    }
    
    deinit {
        playerItemStatusObserver.invalidate()
        playerItemFastForwardObserver.invalidate()
        playerItemReverseObserver.invalidate()
        playerItemFastReverseObserver.invalidate()
        playerTimeControlStatusObserver.invalidate()
        timeObserverToken = nil
        playerItemStatusObserver = nil
        playerItemFastForwardObserver = nil
        playerItemReverseObserver = nil
        playerItemFastReverseObserver = nil
        playerTimeControlStatusObserver = nil
        playerItemDidEndPlayObserver = nil
        cancelBag = []
        delegate = nil
        mediaPlayerView = nil
    }
    
    
    // MARK: Action Outlets
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        guard
            let state = State(rawValue: sender.tag),
            let mediaPlayerView = mediaPlayerView,
            let player = mediaPlayerView.player as AVPlayer?
        else { return }
        switch state {
        case .airPlay:
            break
        case .rotate:
            if UIDevice.current.orientation == .portrait
                || UIDevice.current.orientation == .unknown {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue,
                                          forKey: "orientation")
                return
            }
            if UIDevice.current.orientation == .landscapeLeft
                || UIDevice.current.orientation == .landscapeRight {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                          forKey: "orientation")
            }
        case .backward:
            if player.currentItem?.currentTime() == .zero {
                if let itemDuration = player.currentItem?.duration {
                    DispatchQueue.main.async { [weak player] in
                        player?.currentItem?.seek(to: itemDuration, completionHandler: nil)
                    }
                }
            }
            let time = CMTime(value: 15, timescale: 1)
            DispatchQueue.main.async { [weak player, weak progressView] in
                player!.seek(to: player!.currentTime() - time)
                progressView!.progress = Float(player!.currentTime().seconds)
                                        / Float(player!.currentItem?.duration.seconds ?? 0.0) - 10.0
                                        / Float(player!.currentItem?.duration.seconds ?? 0.0)
            }
        case .play:
            DispatchQueue.main.async { [weak player] in
                player!.timeControlStatus == .playing ? player!.pause() : player!.play()
            }
        case .forward:
            if player.currentItem?.currentTime() == player.currentItem?.duration {
                DispatchQueue.main.async { [weak player] in
                    player!.currentItem?.seek(to: .zero, completionHandler: nil)
                }
            }
            let time = CMTime(value: 15, timescale: 1)
            DispatchQueue.main.async { [weak player, weak progressView] in
                player!.seek(to: player!.currentTime() + time)
                progressView!.progress = Float(player!.currentTime().seconds)
                                        / Float(player!.currentItem?.duration.seconds ?? 0.0) + 10.0
                                        / Float(player!.currentItem?.duration.seconds ?? 0.0)
            }
        case .mute:
            break
        }
    }
    
    @IBAction func trackingSliderChange(_ sender: UISlider) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard
                let self = self,
                let mediaDisplayView = self.mediaPlayerView,
                let player = mediaDisplayView.player as AVPlayer?
            else { return }
            let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
            DispatchQueue.main.async { [weak player, weak self] in
                player!.seek(to: newTime,
                            toleranceBefore: .zero,
                            toleranceAfter: .zero)
                self?.progressView.setProgress(self!.progressView.progress + Float(newTime.seconds), animated: false)
            }
        }
    }
}


// MARK: - MediaOverlayViewDelegate Implementation

extension MediaOverlayView: MediaOverlayViewDelegate {
    
    func mediaOverlayViewDidSetup(_ mediaOverlayView: MediaOverlayView) {
        guard
            let mediaPlayerView = mediaPlayerView,
            let detailViewController = mediaPlayerView.detailViewController,
            let homeViewModel = detailViewController.homeViewController!.homeViewModel as HomeViewModel?,
            let delegate = delegate
        else { return }
        delegate.mediaOverlayViewDidEntitle(homeViewModel.detailMedia!.title!)
        delegate.mediaOverlayViewDidShow()
    }
    
    func mediaOverlayViewDidRegisterObservers(_ mediaOverlayView: MediaOverlayView) {
        guard
            let mediaPlayerView = mediaPlayerView,
            let player = mediaPlayerView.player as AVPlayer?
        else { return }
        playerItemDidEndPlayObserver = NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { _ in
                player.seek(to: CMTime.zero)
            }
        playerItemDidEndPlayObserver.store(in: &cancelBag)
        playerTimeControlStatusObserver = player.observe(\AVPlayer.timeControlStatus,
                                                          options: [.initial, .new],
                                                          changeHandler: { [weak self] _, _ in
            guard
                let self = self,
                let mediaOverlayViewDelegate = mediaOverlayView.delegate
            else { return }
            mediaOverlayViewDelegate.mediaOverlayViewDidSetupPlayButton(self)
        })
        let interval = CMTime(value: 1, timescale: 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let timeElapsed = Float(time.seconds)
            let duration = Float(player.currentItem?.duration.seconds ?? 0.0).rounded()
            mediaOverlayView.progressView.progress = timeElapsed / duration
            mediaOverlayView.trackingSlider.value = timeElapsed
            mediaOverlayView.startTimeLabel.text = mediaPlayerView.mediaPlayerViewModel.createTimeString(time: timeElapsed)
        }
        playerItemFastForwardObserver = player.observe(\AVPlayer.currentItem?.canPlayFastForward, options: [.new, .initial], changeHandler: { player, _ in
            mediaOverlayView.forwardButton.isEnabled = player.currentItem?.canPlayFastForward ?? false
        })
        playerItemReverseObserver = player.observe(\AVPlayer.currentItem?.canPlayReverse, options: [.new, .initial], changeHandler: { player, _ in
            mediaOverlayView.backwardButton.isEnabled = player.currentItem?.canPlayReverse ?? false
        })
        playerItemFastReverseObserver = player.observe(\AVPlayer.currentItem?.canPlayFastReverse, options: [.new, .initial], changeHandler: { player, _ in
            mediaOverlayView.backwardButton.isEnabled = player.currentItem?.canPlayFastReverse ?? false
        })
        playerItemStatusObserver = player.observe(\AVPlayer.currentItem?.status,
                                                   options: [.new, .initial],
                                                   changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            self.mediaPlayerView?.mediaOverlayView.delegate?.mediaOverlayViewDidChangeOverlayState(self)
        })
    }
    
    func mediaOverlayViewDidSetupPlayButton(_ mediaOverlayView: MediaOverlayView) {
        guard
            let mediaPlayerView = mediaPlayerView,
            let player = mediaPlayerView.player as AVPlayer?,
            let detailViewController = mediaPlayerView.detailViewController,
            let detailViewModel = detailViewController.detailViewModel as DetailViewModel?,
            let scheduledTimerDelegate = detailViewModel.scheduledTimer?.delegate
        else { return }
        var systemImage: UIImage!
        switch player.timeControlStatus {
        case .playing:
            systemImage = UIImage(systemName: "pause")
            scheduledTimerDelegate.startTimer()
        case .paused, .waitingToPlayAtSpecifiedRate:
            systemImage = UIImage(systemName: "arrowtriangle.right.fill")
            scheduledTimerDelegate.invalidateTimer()
        @unknown default:
            systemImage = UIImage(systemName: "pause")
            scheduledTimerDelegate.invalidateTimer()
        }
        guard let image = systemImage else { return }
        DispatchQueue.main.async { [weak playButton] in
            playButton?.setImage(image, for: .normal)
        }
    }
    
    func mediaOverlayViewDidChangeOverlayState(_ mediaOverlayView: MediaOverlayView) {
        guard
            let mediaPlayerView = mediaPlayerView,
            let player = mediaPlayerView.player as AVPlayer?,
            let currentItem = player.currentItem
        else { return }
        switch currentItem.status {
        case .failed:
            playButton.isEnabled = false
            trackingSlider.isEnabled = false
            startTimeLabel.isEnabled = false
            durationLabel.isEnabled = false
        case .readyToPlay:
            playButton.isEnabled = true
            let newDurationSeconds = Float(currentItem.duration.seconds)
            let currentTime = Float(CMTimeGetSeconds(player.currentTime()))
            trackingSlider.isEnabled = true
            startTimeLabel.isEnabled = true
            durationLabel.isEnabled = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.progressView?.setProgress(currentTime, animated: false)
                self.trackingSlider?.maximumValue = newDurationSeconds
                self.trackingSlider?.value = currentTime
                self.startTimeLabel?.text = mediaPlayerView.mediaPlayerViewModel.createTimeString(time: currentTime)
                self.durationLabel?.text = mediaPlayerView.mediaPlayerViewModel.createTimeString(time: newDurationSeconds)
            }
        default:
            playButton.isEnabled = false
            trackingSlider.isEnabled = false
            startTimeLabel.isEnabled = false
            durationLabel.isEnabled = false
        }
    }
    
    func mediaOverlayViewDidEntitle(_ title: String) {
        titleLabel.text = title
    }
    
    func mediaOverlayViewDidShow() {
        guard let detailViewController = mediaPlayerView?.detailViewController else { return }
        detailViewController.detailViewModel.scheduledTimer?.delegate.startTimer()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                self.playButton.alpha = 1.0
                self.backwardButton.alpha = 1.0
                self.forwardButton.alpha = 1.0
                self.rotateButton.alpha = 1.0
                self.airPlayButton.alpha = 1.0
                self.muteButton.alpha = 1.0
                self.trackingSlider.alpha = 1.0
                self.progressView.alpha = 0.0
                self.slashLabel.alpha = 1.0
                self.startTimeLabel.alpha = 1.0
                self.durationLabel.alpha = 1.0
                self.titleLabel.alpha = 1.0
                self.mediaPlayerView?.maskedView.alpha = 0.5
                self.layoutIfNeeded()
            }
        }
    }
    
    func mediaOverlayViewDidHide() {
        guard let detailViewController = mediaPlayerView?.detailViewController else { return }
        detailViewController.detailViewModel.scheduledTimer?.delegate.invalidateTimer()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.playButton.alpha = 0.0
                self.backwardButton.alpha = 0.0
                self.forwardButton.alpha = 0.0
                self.rotateButton.alpha = 0.0
                self.airPlayButton.alpha = 0.0
                self.muteButton.alpha = 0.0
                self.trackingSlider.alpha = 0.0
                self.progressView.alpha = 1.0
                self.slashLabel.alpha = 0.0
                self.startTimeLabel.alpha = 0.0
                self.durationLabel.alpha = 0.0
                self.titleLabel.alpha = 0.0
                self.mediaPlayerView?.maskedView.alpha = 0.0
                self.layoutIfNeeded()
            }
        }
    }
}
