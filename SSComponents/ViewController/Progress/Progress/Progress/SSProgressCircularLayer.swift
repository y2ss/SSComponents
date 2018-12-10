//
//  SSProgressCircularLayer.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/3.
//  Copyright © 2018年 y2ss. All rights reserved.
//


class SSProgressCircularLayer: SSProgressLayer {

    private let rotateAnimationKey = "rotate"
    private let strokeAnimationKey = "stroke"
    var circleDiameter: CGFloat = 90 {
        didSet {
            updateFrame()
            updateContents()
        }
    }
    private let arcsCount: CGFloat = 20
    private let maxStrokeLength: CGFloat = 0.75
    private let minStrokeLenght: CGFloat = 0.05
    private let animDuration: TimeInterval = 0.75
    private let rotateAnimDuration: TimeInterval = 2
    private let timmingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    private let anArc: CGFloat = 1.0 / 20.0
    
    override var progressColor: UIColor {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    override var trackColor: UIColor {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    override var trackWidth: CGFloat {
        didSet {
            progressLayer.lineWidth = trackWidth
            trackLayer.lineWidth = trackWidth
        }
    }
    
    override var drawTrack: Bool {
        didSet {
            if drawTrack {
                trackLayer.opacity = 1
            } else {
                trackLayer.opacity = 0
            }
        }
    }
    
    override var determinate: Bool {
        didSet {
            if determinate {
                stopAnimating()
            } else {
                startAnimating()
            }
        }
    }
    
    override var progress: CGFloat {
        didSet {
            if self.determinate {
                progressLayer.strokeEnd = anArc * progress
                progressLayer.transform = CATransform3DMakeRotation(progress * 3 * (.pi * 0.5), 0, 0, 1)
            }
        }
    }

    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = progressColor.cgColor
        layer.fillColor = nil
        layer.lineWidth = trackWidth
        layer.strokeStart = 0
        layer.strokeEnd = 0.5
        return layer
    }()
    
    private lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = trackColor.cgColor
        layer.fillColor = nil
        layer.lineWidth = trackWidth
        layer.strokeStart = 0
        layer.strokeEnd = 1
        return layer
    }()
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init(superLayer: CALayer) {
        super.init(superLayer: superLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        updateFrame()
        trackLayer.frame = self.bounds
        progressLayer.frame = self.bounds
        self.addSublayer(trackLayer)
        self.addSublayer(progressLayer)
        updateContents()
        
        if !self.drawTrack {
            trackLayer.opacity = 0
        }
    }
    
    override func superLayerDidResize() {
        updateFrame()
    }
    
    private func updateFrame() {
        if let center = self.superLayer?.bounds.center {
            self.frame = CGRect.init(x: center.x - circleDiameter * 0.5, y: center.y - circleDiameter * 0.5, width: circleDiameter, height: circleDiameter)
            trackLayer.frame = self.bounds
            progressLayer.frame = self.bounds
        }
    }
    
    private func updateContents() {
        let center = self.bounds.center
        let radius = min(self.bounds.width * 0.5, self.bounds.height * 0.5) - progressLayer.lineWidth * 0.5
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = (arcsCount * 2 + 1.5) * .pi
        let path = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        progressLayer.path = path.cgPath
        trackLayer.path = path.cgPath
    }
    
    override func startAnimating() {
        super.startAnimating()
        if self.isAnimating || self.determinate { return }
        
        let rotateAnimation = CABasicAnimation.init(keyPath: "transform.rotation")
        rotateAnimation.duration = rotateAnimDuration
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = 2 * CGFloat.pi
        rotateAnimation.repeatCount = MAXFLOAT
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = .forwards
        add(rotateAnimation, forKey:rotateAnimationKey)
        progressLayer.add(indeterminateAnimation(), forKey: strokeAnimationKey)
        self.isAnimating = true
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        if !self.isAnimating { return }
        removeAllAnimations()
        progressLayer.removeAllAnimations()
        self.isAnimating = false
    }
    
    private static var animationGroup: CAAnimationGroup?
    private func indeterminateAnimation() -> CAAnimationGroup {
        if SSProgressCircularLayer.animationGroup == nil {
            SSProgressCircularLayer.animationGroup = CAAnimationGroup()
            var anims = [CABasicAnimation]()
            var startValue: CGFloat = 0
            var startTime: TimeInterval = 0
            var i = 0
            repeat {
                anims += createAnimationFromStartValue(startValue, beginTime: startTime, circle: anArc)
                startValue += anArc * (maxStrokeLength + minStrokeLenght)
                startTime += animDuration * 2
                i += 1
            //} while i <= 1
           } while fmodf(floorf(Float(startValue * 1000)), 1000) != 0
            SSProgressCircularLayer.animationGroup?.duration = startTime
            SSProgressCircularLayer.animationGroup?.animations = anims
            SSProgressCircularLayer.animationGroup?.repeatCount = MAXFLOAT
            SSProgressCircularLayer.animationGroup?.isRemovedOnCompletion = false
            SSProgressCircularLayer.animationGroup?.fillMode = .forwards
        }
        return SSProgressCircularLayer.animationGroup!
    }
    
    private func createAnimationFromStartValue(_ beginValue: CGFloat, beginTime: TimeInterval, circle: CGFloat) -> [CABasicAnimation] {
        let hanim = CABasicAnimation.init(keyPath: "strokeEnd")
        hanim.duration = animDuration
        hanim.beginTime = beginTime
        hanim.fromValue = beginValue
        hanim.toValue = beginValue + circle * (maxStrokeLength + minStrokeLenght)
        hanim.timingFunction = timmingFunction
        
        let tanim = CABasicAnimation.init(keyPath: "strokeStart")
        tanim.duration = animDuration
        tanim.beginTime = beginTime
        tanim.fromValue = beginValue - circle * minStrokeLenght
        tanim.toValue = beginValue
        tanim.timingFunction = timmingFunction

        let ehanim = CABasicAnimation.init(keyPath: "strokeEnd")
        ehanim.duration = animDuration
        ehanim.beginTime = beginTime + animDuration
        ehanim.fromValue = beginValue + circle * (maxStrokeLength + minStrokeLenght)
        ehanim.toValue = beginValue + circle * (maxStrokeLength + minStrokeLenght)
        ehanim.timingFunction = timmingFunction

        let etanim = CABasicAnimation.init(keyPath: "strokeStart")
        etanim.duration = animDuration
        etanim.beginTime = beginTime + animDuration
        etanim.fromValue = beginValue
        etanim.toValue = beginValue + circle * maxStrokeLength
        etanim.timingFunction = timmingFunction
        return [hanim, tanim, ehanim, etanim]
    }
}


private extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

