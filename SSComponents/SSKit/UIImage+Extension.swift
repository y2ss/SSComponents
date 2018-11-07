//
//  UIImage+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UIImage {
    
    /** 将图片旋转任意弧度radians */
    func imageRotatedRadians(_ radians: CGFloat) -> UIImage? {
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap!.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
        
        // Rotate the image context
        bitmap!.rotate(by: radians)
        
        // Now, draw the rotated/scaled image into the context
        bitmap!.scaleBy(x: 1.0, y: -1.0)
        bitmap!.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /** 将图片旋转角度degrees */
    func imageRotatedDegrees(_ degrees: CGFloat) -> UIImage? {
        return self.imageRotatedRadians((CGFloat(Double.pi) / 180 * degrees))
    }
    
    /*图片着色*/
    func tint(_ color: UIColor, blendMode: CGBlendMode) -> UIImage {
        let drawRect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    //渲染图片颜色
    func tintAnyColor(_ anyColor: UIColor) -> UIImage {
        return self.tint(anyColor, blendMode: CGBlendMode.destinationIn)
    }
}
