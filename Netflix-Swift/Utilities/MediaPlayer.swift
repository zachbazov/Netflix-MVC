//
//  MediaPlayer.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 06/04/2022.
//

import AVKit

// MARK: - MediaPlayer

final class MediaPlayer: UIView {
    
    // MARK: Properties
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var player: AVPlayer! {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
}
