//
//  UIColor.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 20/07/2022.
//

import UIKit

// MARK: - UIColor

extension UIColor {
    
    static var lightGrayText: UIColor = .colorFromHex("#9D9D9D")
    
    static func rgbColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
    static func colorFromHex(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        if hexString.count != 6 {
            return UIColor.magenta
        }
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
                       green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
                       blue: CGFloat(rgb & 0x0000FF) / 255,
                       alpha: 1.0)
    }
}
