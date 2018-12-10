//
//  SSRippleLayer.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/3.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

@objc protocol RippleLayerDelegate: class, NSObjectProtocol {
    @objc optional func rippleLayerDidCompletedEffect(with layer: SSRippleLayer, duration: TimeInterval)
}

class SSRippleLayer: CALayer {
    
    private let ScaleAnimationKey = "scale"
    private let PositionAnimationKey = "position"
    private let shadowAnimationKey = "shadow"
    
    weak var layerDelegate: RippleLayerDelegate?
    
    var isEnableRipple: Bool = true
    

    var isEnableElevation: Bool = true {
        willSet {
            enableElevation(newValue, resting: true)
        }
    }
    var isEnableMask: Bool = true {
        willSet {
            self.mask = newValue ? maskLayer : nil
        }
    }
    var restingElevation: Float = 2 {
        didSet {
            enableElevation(isEnableElevation, resting: true)
        }
    }
    var rippleScaleRatio: CGFloat = 1 {
        didSet {
            calculteRippleSize()
        }
    }
    var effectSpeed: CGFloat = 140
    var effectColor: UIColor = UIColor.clear {
        willSet {
            rippleLayer.fillColor = newValue.withAlphaComponent(CGFloat(rippleTransparent)).cgColor
            backgroundLayer.fillColor = newValue.withAlphaComponent(CGFloat(backgroundTransparent)).cgColor
        }
    }
    
    func setEffectColor(with color: UIColor, rippleAlpha: Float, backgroundAlpha: Float) {
        effectColor = color
        let copyRippleAlpha = rippleTransparent
        let copyBackgroundTransparent = backgroundTransparent
        rippleTransparent = rippleAlpha
        backgroundTransparent = backgroundAlpha
        effectColor = color
        rippleTransparent = copyRippleAlpha
        backgroundTransparent = copyBackgroundTransparent
    }
    
    private var rippleTransparent: Float = 0.5
    private var backgroundTransparent: Float = 0.3
    private var elevationOffset: Float = 6
    private var clearEffectionDuration: Float = 0.3
    
    private weak var superLayer: CALayer?
    private weak var superView: UIView?
    private lazy var rippleLayer: CAShapeLayer = {
        let l = CAShapeLayer()
        l.opacity = 0
        return l
    }()
    private lazy var backgroundLayer: CAShapeLayer = {
        let l = CAShapeLayer()
        l.opacity = 0
        l.frame = superlayer?.bounds ?? CGRect.zero
        return l
    }()
    private lazy var maskLayer = CAShapeLayer()
    private var effectIsRunning: Bool = false
    private var userIsHolding: Bool = false

    override init(layer: Any) {
        super.init(layer: layer)
        self.setup()
    }

    init(superLayer layer: CALayer) {
        super.init()
        self.superLayer = layer
        self.setup()
    }
    
    init(superView view: UIView) {
        super.init()
        self.superView = view
        self.superLayer = view.layer
        let tgr = TouchGestureRecognizer(target: self, action: nil)
        tgr.tDelegate = self
        tgr.delegate = self
        superView?.addGestureRecognizer(tgr)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSublayer(rippleLayer)
        addSublayer(backgroundLayer)
        setMaskLayerCornerRadius(superLayer?.cornerRadius ?? 0)
        self.mask = maskLayer
        self.frame = superLayer?.bounds ?? CGRect.zero
        superLayer?.insertSublayer(self, at: UInt32(superLayer?.sublayers?.count ?? 0))
        superLayer?.addObserver(self, forKeyPath: "bounds", options: .init(rawValue: 0), context: nil)
        superLayer?.addObserver(self, forKeyPath: "cornerRadius", options: .init(rawValue: 0), context: nil)
        enableElevation(isEnableElevation, resting: true)
        superLayerDidResize()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let superLayer = superLayer else { return }
        if keyPath == "bounds" {
            superLayerDidResize()
        } else if keyPath == "cornerRadius" {
            setMaskLayerCornerRadius(superLayer.cornerRadius)
        }
    }
    
    override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        superLayer?.removeObserver(self, forKeyPath: "bounds")
        superLayer?.removeObserver(self, forKeyPath: "cornerRadius")
    }
    
    private func superLayerDidResize() {
        guard let superLayer = superLayer else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.frame = superLayer.bounds
        setMaskLayerCornerRadius(superLayer.cornerRadius)
        calculteRippleSize()
        CATransaction.commit()
    }
    
    func startEffectsAtLocation(_ touchLocation: CGPoint) {
        userIsHolding = true
        rippleLayer.timeOffset = 0
        rippleLayer.speed = 1
        if isEnableRipple {
            startRippleEffect(nearsetInnerPoint(touchLocation))
        }
        if isEnableElevation {
            startShadowEffect()
        }
    }
    
    func stopEffects() {
        userIsHolding = false
        if !effectIsRunning {
            clearEffects()
        } else {
            rippleLayer.timeOffset = rippleLayer.convertTime(CACurrentMediaTime(), from: nil)
            rippleLayer.beginTime = CACurrentMediaTime()
            rippleLayer.speed = 4
        }
    }
    
    func stopEffectsImmediately() {
        userIsHolding = false
        effectIsRunning = false
        if isEnableRipple {
            rippleLayer.removeAllAnimations()
            backgroundLayer.removeAllAnimations()
            rippleLayer.opacity = 0
            backgroundLayer.opacity = 0
        }
        if isEnableElevation {
            superLayer?.removeAnimation(forKey: shadowAnimationKey)
            superLayer?.shadowRadius = CGFloat(restingElevation * 0.25)
            superLayer?.shadowOffset = CGSize.init(width: 0, height: Int(restingElevation * 0.25 + 0.5))
        }
    }
    
    private func nearsetInnerPoint(_ point: CGPoint) -> CGPoint {
        let dx: Double = Double(point.x - self.bounds.midX)
        let dy: Double = Double(point.y - self.bounds.midY)
        let dist = sqrt(dx * dx + dy * dy)
        if dist <= Double(backgroundLayer.bounds.width * 0.5) {
            return point
        } else {
            let d = backgroundLayer.bounds.width / CGFloat(2 * dist)
            let x = self.bounds.midX + d * (point.x - self.bounds.midX)
            let y = self.bounds.midY + d * (point.y - self.bounds.midY)
            return CGPoint(x: x, y: y)
        }
    }
    
    private func enableElevation(_ enable: Bool, resting: Bool) {
        if enable {
            let elevation = resting ? restingElevation : restingElevation + elevationOffset
            superLayer?.shadowOpacity = 0.5
            superLayer?.shadowRadius = CGFloat(elevation * 0.25)
            superLayer?.shadowColor = UIColor.black.cgColor
            superLayer?.shadowOffset = CGSize(width: 0, height: CGFloat(restingElevation * 0.25 + 0.5))
        } else {
            superLayer?.shadowRadius = 0
            superLayer?.shadowColor = UIColor.clear.cgColor
            superLayer?.shadowOffset = CGSize(width: 0, height: 0)
        }
    }
    
    private func clearEffects() {
        rippleLayer.timeOffset = 0
        rippleLayer.speed = 1
        
        if isEnableRipple {
            rippleLayer.removeAllAnimations()
            backgroundLayer.removeAllAnimations()
            removeAllAnimations()
            
            let oAnim = CABasicAnimation.init(keyPath: "opacity")
            oAnim.fromValue = 1
            oAnim.toValue = 0
            oAnim.duration = CFTimeInterval(clearEffectionDuration)
            oAnim.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            oAnim.isRemovedOnCompletion = false
            oAnim.fillMode = .forwards
            oAnim.delegate = self
            self.add(oAnim, forKey: "opacityAnim")
        }
        
        if isEnableElevation {
            let rAnim = CABasicAnimation.init(keyPath: "shadowRadius")
            rAnim.fromValue = NSNumber.init(value: (restingElevation + elevationOffset) * 0.25)
            rAnim.toValue = NSNumber.init(value: restingElevation * 0.25)
            
            let oAnim = CABasicAnimation.init(keyPath: "shadowOffset")
            oAnim.fromValue = NSValue.init(cgSize: CGSize.init(width: 0, height: CGFloat((restingElevation + elevationOffset) * 0.25)))
            oAnim.toValue = NSValue.init(cgSize: CGSize.init(width: 0, height: CGFloat(restingElevation * 0.25 + 0.5)))
            
            let gAnim = CAAnimationGroup()
            gAnim.duration = CFTimeInterval(clearEffectionDuration)
            gAnim.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
            gAnim.isRemovedOnCompletion = false
            gAnim.fillMode = .forwards
            gAnim.animations = [rAnim, oAnim]
            superLayer?.add(gAnim, forKey: shadowAnimationKey)
        }
    }
    
    func startRippleEffect(_ touchLocation: CGPoint) {
        guard let superLayer = superLayer else { return }
        removeAllAnimations()
        self.opacity = 1
        let time = rippleLayer.bounds.width / effectSpeed
        rippleLayer.removeAllAnimations()
        backgroundLayer.removeAllAnimations()
        superLayer.removeAnimation(forKey: shadowAnimationKey)
        
        let sAnim = CABasicAnimation.init(keyPath: "transform.scale")
        sAnim.fromValue = 0
        sAnim.toValue = 1
        sAnim.duration = CFTimeInterval(time)
        sAnim.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
        
        let mAnim = CABasicAnimation.init(keyPath: "position")
        mAnim.fromValue = NSValue.init(cgPoint: touchLocation)
        mAnim.toValue = NSValue.init(cgPoint: superLayer.bounds.center)
        mAnim.duration = CFTimeInterval(time)
        mAnim.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
        
        sAnim.delegate = self
        effectIsRunning = true
        rippleLayer.opacity = 1
        backgroundLayer.opacity = 1
        
        rippleLayer.add(mAnim, forKey: PositionAnimationKey)
        rippleLayer.add(sAnim, forKey: ScaleAnimationKey)
    }
    
    func startShadowEffect() {
        let rAnim = CABasicAnimation(keyPath: "shadowRadius")
        rAnim.fromValue = NSNumber.init(value: restingElevation * 0.25)
        rAnim.toValue = NSNumber.init(value: (restingElevation + elevationOffset) * 0.25)
        
        let oAnim = CABasicAnimation.init(keyPath: "shadowOffset")
        oAnim.fromValue = NSValue.init(cgSize: CGSize.init(width: 0, height: CGFloat(restingElevation * 0.25 + 0.5)))
        oAnim.toValue = NSValue.init(cgSize: CGSize.init(width: 0, height: CGFloat(restingElevation + elevationOffset) * 0.25))
        
        let gAnim = CAAnimationGroup()
        gAnim.duration = CFTimeInterval(clearEffectionDuration)
        gAnim.timingFunction = CAMediaTimingFunction.init(name: .easeIn)
        gAnim.isRemovedOnCompletion = false
        gAnim.fillMode = .forwards
        gAnim.animations = [rAnim, oAnim]
        superLayer?.add(gAnim, forKey: shadowAnimationKey)
    }

    
    private func setMaskLayerCornerRadius(_ cornerRadius: CGFloat) {
        let path = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: cornerRadius)
        maskLayer.path = path.cgPath
    }
    
    private func calculteRippleSize() {
        guard let superLayer = superLayer else { return }
        let w: Float = Float(superLayer.bounds.width)
        let h: Float = Float(superLayer.bounds.height)
        let center = superLayer.bounds.center
        let circleDiameter: CGFloat = CGFloat(sqrtf(powf(w, 2) + powf(h, 2))) * rippleScaleRatio
        let subX = center.x - circleDiameter * 0.5
        let subY = center.y - circleDiameter * 0.5
        rippleLayer.frame = CGRect.init(x: subX, y: subY, width: circleDiameter, height: circleDiameter)
        backgroundLayer.frame = rippleLayer.frame
        rippleLayer.path = UIBezierPath.init(ovalIn: rippleLayer.bounds).cgPath
        backgroundLayer.path = rippleLayer.path
    }
}

extension SSRippleLayer: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == self.animation(forKey: "opacityAnim") {
            self.opacity = 0
        } else if flag {
            if userIsHolding {
                effectIsRunning = false
                layerDelegate?.rippleLayerDidCompletedEffect?(with: self, duration: anim.duration)
            } else {
                clearEffects()
            }
        }
    }
}

extension SSRippleLayer: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SSRippleLayer: TouchGestureRecognizerDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let superView = superView, let point = touches.first?.location(in: superView) {
            startEffectsAtLocation(point)
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        stopEffects()
    }
    
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        stopEffects()
    }
}

@objc protocol TouchGestureRecognizerDelegate: class, NSObjectProtocol {
    @objc optional func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
    @objc optional func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent)
    @objc optional func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent)
    @objc optional func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent)
}

private class TouchGestureRecognizer: UIGestureRecognizer {
    weak var tDelegate: TouchGestureRecognizerDelegate?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.cancelsTouchesInView = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if state != .began {
            self.state = .began
            tDelegate?.touchesBegan?(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .changed
        tDelegate?.touchesMoved?(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began || self.state == .changed {
            self.state = .cancelled
        }
        tDelegate?.touchesCancelled?(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began || self.state == .changed {
            self.state = .ended
        }
        tDelegate?.touchesEnded?(touches, with: event)
    }
    
}

private extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

