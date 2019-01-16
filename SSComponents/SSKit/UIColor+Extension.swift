//
//  UIColor+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    var redC: CGFloat {
        get {
            if let c = self.cgColor.components {
                return c.count >= 1 ? c[0] : 0
            }
            return 0
        }
    }
    
    var greenC: CGFloat {
        get {
            if let c = self.cgColor.components {
                return c.count >= 2 ? c[1] : 0
            }
            return 0
        }
    }
    
    var blueC: CGFloat {
        get {
            if let c = self.cgColor.components {
                return c.count >= 3 ? c[2] : 0
            }
            return 0
        }
    }
    
    var alpha: CGFloat {
        get {
            if let c = self.cgColor.components {
                return c.count >= 4 ? c[3] : 0
            }
            return 0
        }
    }
    
    func alpha(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: redC, green: greenC, blue: blueC, alpha: alpha)
    }
    
    func white(_ scale: CGFloat) -> UIColor {
        return UIColor(red: redC + (1 - redC) * scale,
                       green: greenC + (1 - greenC) * scale,
                       blue: blueC + (1 - blueC) * scale,
                       alpha:  1)
    }
    
    convenience init(hex:UInt) {
//        let alpha = (hex >> 24) & 0xFF
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex  & 0xFF
        
        self.init(red:CGFloat(red)/255, green:CGFloat(green)/255, blue:CGFloat(blue)/255, alpha:1)
    }
    
    convenience init(colorString:String) {
        
        var colorString = colorString
        
        if (colorString[colorString.startIndex] != "#") {
            fatalError("颜色必须以#开头，支持RGB与ARGB颜色值")
        }
        
        if ((colorString.count != 7) && (colorString.count != 9)) {
            fatalError("只支持7位和9位颜色值")
        }
        
        var noAlpha = false
        if (colorString.count == 7) {
            noAlpha = true
        }
        
        colorString.remove(at: colorString.startIndex)
        colorString = String(format:"0x%@", colorString)
        
        var hexColor = colorString.toHex()
        
        if (noAlpha) {
            //如果传入的是RGB则把Alpha设置为1
            hexColor |= (0xFF << 24)
        }
        
        self.init(hex:UInt(hexColor))
    }
    
    func getArrRGBFromColor() -> Array<CGFloat> {
        var R: CGFloat = 0.0 // 0
        var G: CGFloat = 0.0 // 1
        var B: CGFloat = 0.0 // 2
        var A: CGFloat = 0.0
        self.getRed(&R, green: &G, blue: &B, alpha: &A)
        return [R, G, B, A]
    }
    
    func getArrHueFromColor() -> Array<CGFloat> {
        
        var H: CGFloat = 0.0 // 0 色调 hue
        var S: CGFloat = 0.0 // 1 饱和度 saturation
        var B: CGFloat = 0.0 // 2 亮度 brightness
        var A: CGFloat = 0.0
        self.getHue(&H, saturation: &S, brightness: &B, alpha: &A)
        return [H, S, B, A]
    }
    
    //MARK: - 渐变色
    class func gradient(from color1: UIColor, to color2: UIColor, with size: CGSize) -> UIColor? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let colorComponents: NSArray = [color1.cgColor, color2.cgColor]
        if
            let ctx = UIGraphicsGetCurrentContext(),
            let gradient = CGGradient(colorsSpace: colorspace, colors: colorComponents, locations: nil) {
            ctx.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: size.width, y: size.height), options: .init(rawValue: 0))
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            defer { UIGraphicsEndImageContext() }
            return UIColor(patternImage: image)
        }
        return nil
    }
}
