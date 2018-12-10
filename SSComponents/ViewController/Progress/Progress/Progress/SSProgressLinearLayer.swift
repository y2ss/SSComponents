//
//  SSProgressLinearLayer.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/4.
//  Copyright © 2018年 y2ss. All rights reserved.
//

class SSProgressLinearLayer: SSProgressLayer {
    typealias this = SSProgressLinearLayer
    
    private let primaryAnimationKey = "primaryAnimation"
    private let secondaryAnimationKey = "secondaryAnimation"
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = progressColor.cgColor
        layer.fillColor = nil
        layer.lineWidth = trackWidth
        layer.strokeStart = 0
        layer.strokeEnd = 0
        layer.frame = self.bounds
        return layer
    }()
    private lazy var secondaryProgressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = progressColor.cgColor
        layer.fillColor = nil
        layer.lineWidth = trackWidth
        layer.strokeStart = 0
        layer.strokeEnd = 0
        return layer
    }()
    private lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = trackColor.cgColor
        layer.fillColor = nil
        layer.lineWidth = trackWidth
        layer.strokeStart = 0
        layer.strokeEnd = 1
        layer.frame = self.bounds
        return layer
    }()
    
    override init(superLayer: CALayer) {
        super.init(superLayer: superLayer)
    }
    
    override init(superView: UIView) {
        super.init(superView: superView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override func setup() {
        if let superLayer = self.superLayer {
            let center = superLayer.bounds.center
            self.frame = CGRect.init(x: 0, y: center.y - trackWidth * 0.5, width: superLayer.bounds.width, height: trackWidth)
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint.init(x: 0, y: self.bounds.midY))
            linePath.addLine(to: CGPoint.init(x: self.bounds.width, y: self.bounds.midY))
            
            progressLayer.path = linePath.cgPath
            secondaryProgressLayer.path = linePath.cgPath
            trackLayer.path = linePath.cgPath
            self.addSublayer(trackLayer)
            self.addSublayer(progressLayer)
            self.addSublayer(secondaryProgressLayer)
        }
    }
    
    override var progressColor: UIColor {
        willSet {
            progressLayer.strokeColor = newValue.cgColor
            secondaryProgressLayer.strokeColor = newValue.cgColor
        }
    }
    
    override var trackColor: UIColor {
        willSet {
            trackLayer.strokeColor = newValue.cgColor
        }
    }
    
    override var trackWidth: CGFloat {
        willSet {
            progressLayer.lineWidth = newValue
            secondaryProgressLayer.lineWidth = newValue
            trackLayer.lineWidth = trackWidth
        }
    }
    
    override var determinate: Bool {
        willSet {
            if determinate {
                stopAnimating()
            } else {
                startAnimating()
            }
        }
    }
    
    override var progress: CGFloat {
        willSet {
            if self.determinate {
                progressLayer.strokeEnd = newValue
            }
        }
    }
    
    override func startAnimating() {
        if self.isAnimating || self.determinate { return }
        progressLayer.add(primaryIndeterminateAnimation(), forKey: primaryAnimationKey)
        secondaryProgressLayer.add(secondaryIndeterminateAnimation(), forKey: secondaryAnimationKey)
        self.isAnimating = true
    }
    
    override func stopAnimating() {
        if self.isAnimating {
            progressLayer.removeAllAnimations()
            secondaryProgressLayer.removeAllAnimations()
            self.isAnimating = false
        }
    }
    
    override func superLayerDidResize() {
        guard let superLayer = superLayer else { return }
        let center = superLayer.bounds.center
        self.frame = CGRect.init(x: 0, y: center.y - trackWidth * 0.5, width: superLayer.bounds.width, height: trackWidth)
        trackLayer.frame = self.bounds
        secondaryProgressLayer.frame = self.bounds
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint.init(x: 0, y: self.bounds.midY))
        linePath.addLine(to: CGPoint.init(x: self.bounds.width, y: self.bounds.midY))
        trackLayer.path = linePath.cgPath
        progressLayer.path = linePath.cgPath
        secondaryProgressLayer.path = linePath.cgPath
    }
    
    private static var p_animGroups: CAAnimationGroup? = nil
    private func primaryIndeterminateAnimation() -> CAAnimationGroup {
        if this.p_animGroups == nil {
            let hinanim = CABasicAnimation.init(keyPath: "strokeEnd")
            hinanim.duration = 0.8
            hinanim.fromValue = 0
            hinanim.toValue = 1
            hinanim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
            let tinanim = CABasicAnimation.init(keyPath: "strokeStart")
            tinanim.duration = 1.2
            tinanim.fromValue = -0.1
            tinanim.toValue = 1
            tinanim.timingFunction = CAMediaTimingFunction(controlPoints: 0.3, 0.3, 0.9, 0.5)
            
            let houtanim = CABasicAnimation.init(keyPath: "strokeEnd")
            houtanim.beginTime = 0.8
            houtanim.duration = 0.4
            houtanim.fromValue = 1
            houtanim.toValue = 1
            houtanim.timingFunction = CAMediaTimingFunction(name: .linear)
            
            this.p_animGroups = CAAnimationGroup.init()
            this.p_animGroups?.animations = [hinanim, tinanim, houtanim]
            this.p_animGroups?.repeatCount = MAXFLOAT
            this.p_animGroups?.duration = 1.8
            this.p_animGroups?.isRemovedOnCompletion = false
            this.p_animGroups?.fillMode = .forwards
        }
        return this.p_animGroups!
    }
    
    private static var s_animGroups: CAAnimationGroup? = nil
    private func secondaryIndeterminateAnimation() -> CAAnimationGroup {
        if this.s_animGroups == nil {
            let hinanim = CABasicAnimation.init(keyPath: "strokeEnd")
            hinanim.beginTime = 1
            hinanim.duration = 0.6
            hinanim.fromValue = 0
            hinanim.toValue = 1
            hinanim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
            let tinanim = CABasicAnimation.init(keyPath: "strokeStart")
            tinanim.beginTime = 1.2
            tinanim.duration = 0.6
            tinanim.fromValue = 0
            tinanim.toValue = 1.2
            tinanim.timingFunction = CAMediaTimingFunction(name: .linear)
            
            let houtanim = CABasicAnimation.init(keyPath: "strokeEnd")
            houtanim.beginTime = 1.6
            houtanim.duration = 0.2
            houtanim.fromValue = 1
            houtanim.toValue = 1
            houtanim.timingFunction = CAMediaTimingFunction(name: .linear)
            
            this.s_animGroups = CAAnimationGroup()
            this.s_animGroups?.animations = [hinanim, tinanim, houtanim]
            this.s_animGroups?.repeatCount = MAXFLOAT
            this.s_animGroups?.duration = 1.8
            this.s_animGroups?.isRemovedOnCompletion = false
            this.s_animGroups?.fillMode = .forwards
        }
        return this.s_animGroups!
    }
}

private extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
