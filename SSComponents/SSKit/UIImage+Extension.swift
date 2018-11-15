//
//  UIImage+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UIImage {
    
    //MARK: - 将图片旋转任意弧度radians
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
    
    //MARK: - 将图片旋转角度degrees
    func imageRotatedDegrees(_ degrees: CGFloat) -> UIImage? {
        return self.imageRotatedRadians((CGFloat(Double.pi) / 180 * degrees))
    }
    
    //MARK: - 图片着色
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
    
    //MARK: - 渲染图片颜色
    func tintAnyColor(_ anyColor: UIColor) -> UIImage {
        return self.tint(anyColor, blendMode: CGBlendMode.destinationIn)
    }
    
    //MARK: - 生成纯色图片
    class func generate(with color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

private class PDFImageCache {
    static private var __instance = PDFImageCache()
    class var `default`: PDFImageCache {
        return __instance
    }
    private var cache: NSCache<NSString, UIImage>
    init() {
        cache = NSCache<NSString, UIImage>()
    }
    
    func set(_ image: UIImage, key: NSString) {
        cache.setObject(image, forKey: key)
    }
    
    func value(_ key: NSString) -> UIImage? {
        return cache.object(forKey: key)
    }
}

extension UIImage {
    
    //MARK: - dpf 转 image
    class func pdfConvertImage(with filePath: String, tintColor: UIColor? = nil, for size: CGSize) -> UIImage? {
        let key = NSString(format: "%@_%@_%@", filePath, tintColor ?? UIColor.white, size as CVarArg)
        if let image = PDFImageCache.default.value(key) { return image }
        
        let fileURL = URL(fileURLWithPath: filePath) as CFURL
        guard let pdf = CGPDFDocument(fileURL) else { return nil }
        
        guard let page1 = pdf.page(at: 1) else { return nil }
        let mediaRect = CGPDFPage.getBoxRect(page1)(CGPDFBox.cropBox)
        
        var imageSize = mediaRect.size
        if imageSize.height < size.height && size.height != CGFloat(MAXFLOAT) {
            imageSize.width = round(size.height / imageSize.height * imageSize.width)
            imageSize.height = size.height
        }
        if imageSize.width < size.width && size.width != CGFloat(MAXFLOAT) {
            imageSize.height = round(size.width / imageSize.width * imageSize.height)
            imageSize.width = size.width
        }
        if imageSize.height > size.height {
            imageSize.width = round(size.height / imageSize.height * imageSize.width)
            imageSize.height = size.height
        }
        if imageSize.width > size.width {
            imageSize.height = round(size.width / imageSize.width * imageSize.height)
            imageSize.width = size.width
        }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let scale = min(imageSize.width / mediaRect.size.width, imageSize.height / mediaRect.size.height)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        ctx.ctm.translatedBy(x: 0, y: -imageSize.height)
        ctx.ctm.scaledBy(x: 1, y: -1)
        ctx.ctm.concatenating(page1.getDrawingTransform(.mediaBox, rect: CGRect(x: 0, y: 0, width: imageSize.width, height: -imageSize.height), rotate: 0, preserveAspectRatio: true))
        ctx.ctm.scaledBy(x: scale, y: scale)
        ctx.drawPDFPage(page1)
        
        defer { UIGraphicsEndImageContext() }
        guard var image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        if let tintColor = tintColor {
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
            if
                let ctx = UIGraphicsGetCurrentContext(),
                let cgImage = image.cgImage {
                ctx.ctm.scaledBy(x: 1, y: -1)
                ctx.ctm.translatedBy(x: 0, y: -imageSize.height)
                ctx.ctm.scaledBy(x: scale, y: scale)
                let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
                ctx.clip(to: rect, mask: cgImage)
                tintColor.setFill()
                ctx.fill(rect)
                defer { UIGraphicsEndImageContext() }
                if let _image = UIGraphicsGetImageFromCurrentImageContext() {
                    PDFImageCache.default.set(_image, key: key)
                    return _image
                }
            }
        }
        PDFImageCache.default.set(image, key: key)
        return image
    }
}


extension UIImage {
    //MARK: - 获取某像素点颜色
    func color(at point: CGPoint) -> UIColor? {
        if point.x < 0 || point.y < 0 { return nil }
        if !CGRect(x: 0, y: 0, width: size.width, height: size.height).contains(point) { return nil }
        guard let cgimage = self.cgImage else { return nil }
        
        let width: CGFloat = CGFloat(cgimage.width)
        let height: CGFloat = CGFloat(cgimage.height)
        
        if point.x >= width || point.y >= height { return nil }
        
        let colorSpa = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * 1
        let bitsPerComponent = 8
        let pixelData: UnsafeMutablePointer<CUnsignedChar>
        pixelData = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        for i in 0 ..< 4 {
            pixelData[i] = CUnsignedChar(0)
        }
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue |
            CGImageAlphaInfo.premultipliedFirst.rawValue).rawValue
        guard let context = CGContext(data: pixelData,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpa,
                                      bitmapInfo: bitmapInfo) else {
                                        return nil
        }
        
        let pX = trunc(point.x)
        let pY = trunc(point.y)
        context.setBlendMode(.copy)
        context.translateBy(x: -pX, y: pY - CGFloat(height))
        context.draw(cgimage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let red   = CGFloat(pixelData[1]) / 255.0
        let green = CGFloat(pixelData[2]) / 255.0
        let blue  = CGFloat(pixelData[3]) / 255.0
        let alpha = CGFloat(pixelData[0]) / 255.0
        
        pixelData.deallocate()
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIImage {
    
    //MARK: - 裁剪
    func crop(to rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        self.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    //MARK: - 缩放
    func scale(to size: CGSize) -> UIImage? {
        if size == self.size {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    //
    func scaleFit(to fitSize: CGSize) -> UIImage? {
        let aspect = size.width / size.height
        if size.width / aspect <= size.height {
            return self.scale(to: CGSize.init(width: size.width, height: size.height / aspect))
        } else {
            return self.scale(to: CGSize.init(width: size.height * aspect, height: size.height))
        }
    }
    
    func scaledFill(to fillSize: CGSize) -> UIImage? {
        if self.size == size {
            return self
        }
        let aspect = self.size.width / self.size.height
        if size.width / aspect >= size.height {
            return scale(to: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return scale(to: CGSize(width: size.height * aspect, height: size.height))
        }
    }
    
    func setMask(with image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        guard let cgimage = image.cgImage else { return nil }
        ctx.clip(to: CGRect.init(x: 0, y: 0, width: size.width, height: size.height), mask: cgimage)
        self.draw(at: CGPoint.zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    /*

     */
    
}



