//
//  UIView+Extension.swift
//  SSComponents
//
//  Created by y2ss 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func toImage(_ size: CGSize = .zero) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size == .zero ? self.bounds.size : size, false, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: ctx)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - 任意视图切成圆
    func clipCircleByLayer() {
        self.layer.cornerRadius = self.bounds.width / 2
        self.clipsToBounds = true
    }
    
    func clipCircleByCtx() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ctx.addEllipse(in: rect)
        ctx.clip()
        self.draw(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


extension UIView {
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var boderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    
    // MARK: - 自动旋转动画(360°无限转动)
    func startRotateAnimation(duration: CFTimeInterval = 12) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z") //让其在z轴旋转
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0) //旋转角度
        rotationAnimation.duration = duration // 转360°所需要的时间
        rotationAnimation.isCumulative = true // 累加角度
        rotationAnimation.repeatCount = MAXFLOAT //旋转次数
        rotationAnimation.isRemovedOnCompletion = false
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // MARK: - 暂停动画
    func pauseRotateAnimation() {
        //1.取出当前的动画时间点,就是要暂停的时间点
        let pauseTime = self.layer.convertTime(CACurrentMediaTime(), from: nil)
        //2.设置动画的时间偏移量，指定时间偏移量的目的是让动画定在时间点
        self.layer.timeOffset = pauseTime
        //3.将动画的运行速度设置为0.默认为  1.0
        self.layer.speed = 0
    }
    
    // MARK: - 继续动画
    func resumeRotateAnimation() {
        //1.将动画的时间偏移量作为暂停时间点
        let pauseTime = self.layer.timeOffset
        //2.根据媒体时间计算出准确的启动动画时间。对之前暂停动画的时间进行修正。
        let beginTime = CACurrentMediaTime() - pauseTime
        //2.5设置偏移时间点清0
        self.layer.timeOffset = 0
        //3.设置播放开始时间
        self.layer.beginTime = beginTime
        //4.设置速度
        self.layer.speed = 1.0
    }
}

