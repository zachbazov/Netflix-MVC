//
//  MediaPlayerViewModel.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 07/04/2022.
//

import UIKit

// MARK: - MediaPlayerViewModel

final class MediaPlayerViewModel {
    
    // MARK: Properties
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    
    // MARK: Methods
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(for: components as DateComponents)!
    }
}
