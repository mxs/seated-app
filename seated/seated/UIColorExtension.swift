//
//  UIColorExtension.swift
//
//

import UIKit

extension UIColor {
    convenience init(rgb: String, alpha:CGFloat) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        
        if rgb.hasPrefix("#") {
            let index   = advance(rgb.startIndex, 1)
            let hex     = rgb.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (countElements(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    convenience init(rgb: String) {
        self.init(rgb: rgb, alpha: 1.0)
    }
    
    class func textColour() -> UIColor {
        return UIColor(rgb: "#494949")
    }
    
    class func primaryColour() -> UIColor {
        return UIColor(rgb: "#ffdb61")
    }
    
    class func invalidPlaceholderColour() -> UIColor {
        return UIColor(rgb: "#ffd4d6")
    }
    
    class func validPlaceholderColour() -> UIColor {
        return UIColor(rgb: "#c1c1c7")
    }
    
}