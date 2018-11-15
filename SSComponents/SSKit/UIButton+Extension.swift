//
//  UIButton+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/10.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

//MARK: - 点击区域
extension UIButton {
    
    private struct AssociateObject {
        fileprivate static var touchAreInsetsKey: UInt8 = 0
    }
    
    var touchAreaInsets: UIEdgeInsets? {
        set {
            if let value = newValue {
                let value = NSValue(uiEdgeInsets: value)
                objc_setAssociatedObject(self, &AssociateObject.touchAreInsetsKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &AssociateObject.touchAreInsetsKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            if let value = objc_getAssociatedObject(self, &AssociateObject.touchAreInsetsKey) as? NSValue {
                return value.uiEdgeInsetsValue
            }
            return nil
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let touchAreaInsets = touchAreaInsets {
            var bounds = self.bounds
            bounds = CGRect(x: bounds.origin.x - touchAreaInsets.left,
                            y: bounds.origin.y - touchAreaInsets.top,
                            width: bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                            height: bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom)
            return bounds.contains(point)
        }
        return super.point(inside: point, with: event)
    }
}


//MARK: - 图片位置
private class ImagePositionCache {
    
    static let __instance = ImagePositionCache()
    class var `default`: ImagePositionCache {
        return __instance
    }
    
    private var cache: NSCache<NSString, PositionCacheModel>
    
    class PositionCacheModel: NSObject {
        var imageEdgeInsets: UIEdgeInsets
        var titleEdgeInsets: UIEdgeInsets
        var contentEdgeInsets: UIEdgeInsets
        
        init(_ imageEdgeInsets: UIEdgeInsets, _ titleEdgeInsets: UIEdgeInsets, _ contentEdgeInsets: UIEdgeInsets) {
            self.imageEdgeInsets = imageEdgeInsets
            self.titleEdgeInsets = titleEdgeInsets
            self.contentEdgeInsets = contentEdgeInsets
            super.init()
        }
    }
    
    func set(_ key: NSString, value: PositionCacheModel) {
        cache.setObject(value, forKey: key)
    }
    
    func value(for key: NSString) -> PositionCacheModel? {
        return cache.object(forKey: key)
    }
    
    private init() {
        cache = NSCache<NSString, PositionCacheModel>()
    }
}

extension UIButton {
    enum ImagePosition: Int {
        case top = 0
        case bottom
        case right
        case left
    }

    func setImagePosition(_ position: ImagePosition, spacing: CGFloat = 0) {
        guard let image = imageView?.image, let titleLabel = titleLabel, let text = titleLabel.text else {
            print("请先设置image和title")
            return
        }
        
        let cacheKey = NSString(format: "%@_%d_%d", text, titleLabel.font.hashValue, position.rawValue)
        if let cache = ImagePositionCache.default.value(for: cacheKey) {
            self.imageEdgeInsets = cache.imageEdgeInsets
            self.titleEdgeInsets = cache.titleEdgeInsets
            self.contentEdgeInsets = cache.contentEdgeInsets
            return
        }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let labelSize = NSString(string: text).size(withAttributes: [NSAttributedString.Key.font: titleLabel.font])
        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        let imageOffsetX = (imageWidth + labelWidth) * 0.5 - imageWidth * 0.5
        let imageOffsetY = imageHeight * 0.5 + spacing * 0.5
        let labelOffsetX = imageWidth + labelWidth * 0.5 - (imageWidth + labelWidth) * 0.5
        let labelOffsetY = labelHeight * 0.5 + spacing * 0.5
        let tempWidth = max(labelWidth, imageWidth)
        let changedWidth = labelWidth + imageWidth - tempWidth
        let tempHeight = max(labelHeight, imageHeight)
        let changedHeight = labelHeight + imageHeight + spacing - tempHeight
        var imageEdgeInsets = UIEdgeInsets.zero
        var titleEdgeInsets = UIEdgeInsets.zero
        var contentEdgeInsets = UIEdgeInsets.zero
        
        switch position {
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing * 0.5, bottom: 0, right: spacing * 0.5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing * 0.5, bottom: 0, right: -spacing * 0.5)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing * 0.5, bottom: 0, right: spacing * 0.5)
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth + spacing * 0.5, bottom: 0, right: -(labelWidth + spacing * 0.5))
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageWidth + spacing * 0.5), bottom: 0, right: imageWidth + spacing * 0.5)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing * 0.5, bottom: 0, right: spacing * 0.5)
        case .top:
            imageEdgeInsets = UIEdgeInsets(top: -imageOffsetY, left: imageOffsetX, bottom: imageOffsetY, right: -imageOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: labelOffsetY, left: -labelOffsetX, bottom: -labelOffsetY, right: labelOffsetX)
            contentEdgeInsets = UIEdgeInsets(top: imageOffsetY, left: -changedWidth * 0.5, bottom: changedHeight - imageOffsetY, right: -changedWidth * 0.5)
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: imageOffsetY, left: imageOffsetX, bottom: -imageOffsetY, right: -imageOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: -labelOffsetY, left: -labelOffsetX, bottom: labelOffsetY, right: labelOffsetX)
            contentEdgeInsets = UIEdgeInsets.init(top: changedHeight - imageOffsetY, left: -changedWidth * 0.5, bottom: imageOffsetY, right: changedWidth * 0.5)
        }
        
        let model = ImagePositionCache.PositionCacheModel(imageEdgeInsets, titleEdgeInsets, contentEdgeInsets)
        ImagePositionCache.default.set(cacheKey, value: model)
        
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.contentEdgeInsets = contentEdgeInsets
    }
}

