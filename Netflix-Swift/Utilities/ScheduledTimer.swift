//
//  ScheduledTimer.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 22/06/2022.
//

import Foundation

// MARK: - Schedulable

protocol Schedulable {
    
    var timer: Timer! { get set }
    
    var timeInterval: TimeInterval { get }
    
    var repeats: Bool { get }
}



// MARK: - ScheduledTimerDelegate

protocol ScheduledTimerDelegate: AnyObject {
    
    func scheduledTimer(timeInterval: TimeInterval, target: Any, selector: Selector, repeats: Bool)
    
    func invalidateTimer()
    
    func startTimer()
}



// MARK: - ScheduledTimer

final class ScheduledTimer: Schedulable {
    
    // MARK: State
    
    enum State {
        case mediaOverlay
    }
    
    
    // MARK: Properties
    
    var timer: Timer! = nil
    
    var timeInterval: TimeInterval
    
    var repeats: Bool
    
    
    private(set) weak var delegate: ScheduledTimerDelegate! = nil
    
    private weak var detailViewController: DetailViewController! = nil
    
    
    // MARK: Initialization & Deinitialization
    
    private init(timeInterval: TimeInterval, repeats: Bool) {
        self.timeInterval = timeInterval
        self.repeats = repeats
        
        self.delegate = self
    }
    
    convenience init(_ state: State, with detailViewController: DetailViewController) {
        switch state {
        case .mediaOverlay:
            self.init(timeInterval: 3.0, repeats: true)
            
            self.detailViewController = detailViewController
        }
    }
    
    deinit {
        timer = nil
        delegate = nil
        detailViewController = nil
    }
}



// MARK: - ScheduledTimerDelegate Implementation

extension ScheduledTimer: ScheduledTimerDelegate {
    
    func scheduledTimer(timeInterval: TimeInterval,
                        target: Any,
                        selector: Selector,
                        repeats: Bool) {
        
        invalidateTimer()
        
        timer = .scheduledTimer(timeInterval: timeInterval, target: target, selector: selector, userInfo: nil, repeats: repeats)
    }
    
    func invalidateTimer() {
        guard timer != nil else {
            return
        }
        
        timer.invalidate()
        timer = nil
    }
    
    func startTimer() {
        guard
            let detailViewController = detailViewController,
            let mediaPlayerView = detailViewController.detailPreviewView.mediaPlayerView,
            let mediaOverlayView = mediaPlayerView.mediaOverlayView
        else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: mediaPlayerView.configuration.overlayDuration,
                                     target: mediaOverlayView,
                                     selector: #selector(mediaOverlayView.delegate?.mediaOverlayViewDidHide),
                                     userInfo: nil,
                                     repeats: true)
    }
}
