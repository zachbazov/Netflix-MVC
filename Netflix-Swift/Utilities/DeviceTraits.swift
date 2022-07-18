//
//  DeviceTraits.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 14/04/2022.
//

import UIKit

// MARK: - DeviceTraits

enum DeviceTraits {
    
    case wRhR,
         wChR,
         wRhC,
         wChC
    
    static var current: DeviceTraits {
        switch (UIScreen.main.traitCollection.horizontalSizeClass, UIScreen.main.traitCollection.verticalSizeClass) {
        case (UIUserInterfaceSizeClass.regular, UIUserInterfaceSizeClass.regular):
            return .wRhR
        case (UIUserInterfaceSizeClass.compact, UIUserInterfaceSizeClass.regular):
            return .wChR
        case (UIUserInterfaceSizeClass.regular, UIUserInterfaceSizeClass.compact):
            return .wRhC
        case (UIUserInterfaceSizeClass.compact, UIUserInterfaceSizeClass.compact):
            return .wChC
        default:
            return .wChR
        }
    }
}
