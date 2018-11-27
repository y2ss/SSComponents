//
//  SSCheckBox.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/24.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

@objc protocol SSCheckBoxDelegate: class {
    @objc optional func checkBoxDidTap(_ checkBox: SSCheckBox)
    @objc optional func animationDidStop(_ checkBox: SSCheckBox)
}

enum SSCheckBoxType {
    case circle
    case square
}

enum SSCheckBoxAnimationType {
    case stroke
    case fill
    case bounce
    case flat
    case oneStroke
    case fade
}

class SSCheckBox: UIControl {
    
    weak var delegate: SSCheckBoxDelegate?

    var on: Bool = false
    var lineWidth: CGFloat = 2 {
        didSet {
            reload()
        }
        willSet {
             pathMgr.lineWidth = newValue
        }
    }
    var animationDuration: CGFloat = 0.5 {
        willSet {
            animatorMgr.duration = Double(newValue)
        }
    }
    var hideBox: Bool = false
    var onTintColor: UIColor = UIColor(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            reload()
        }
    }
    var onFillColor: UIColor = UIColor.clear {
        didSet {
            reload()
        }
    }
    var offFillColor: UIColor = UIColor.clear {
        didSet {
            reload()
        }
    }
    var onCheckColor: UIColor = UIColor(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1) {
        didSet {
            reload()
        }
    }
    var type: SSCheckBoxType = .circle {
        willSet {
            pathMgr.type = newValue
        }
        didSet {
            reload()
        }
    }
    var onAnimateType: SSCheckBoxAnimationType = .stroke
    var offAnimateType: SSCheckBoxAnimationType = .stroke
    var minuimumTouchSize: CGSize = CGSize(width: 44, height: 44)
    
    override var cornerRadius: CGFloat {
        didSet {
            reload()
        }
        willSet {
            pathMgr.cornerRadius = newValue
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            drawOffBox()
        }
    }
    
    private var onBoxLayer: CAShapeLayer?
    private var offBoxLayer: CAShapeLayer?
    private var checkMarkLayer: CAShapeLayer?
    private lazy var animatorMgr: CheckBoxAnimation = {
        let mgr = CheckBoxAnimation(duration: Double(animationDuration))
        return mgr
    }()
    private lazy var pathMgr: CheckBoxPath = {
       let mgr = CheckBoxPath(size: height, lineWidth: lineWidth, cornerRadius: cornerRadius, type: type)
        return mgr
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        tintColor = UIColor.lightGray
        cornerRadius = 3
        self.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCheckBox(_:)))
        addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        pathMgr.size = self.height
        super.layoutSubviews()
    }
    
    private func reload() {
        offBoxLayer?.removeFromSuperlayer()
        offBoxLayer = nil
        
        onBoxLayer?.removeFromSuperlayer()
        onBoxLayer = nil
        
        checkMarkLayer?.removeFromSuperlayer()
        checkMarkLayer = nil
        
        setNeedsDisplay()
        layoutIfNeeded()
    }

    private func setOn(_ on: Bool, animated: Bool) {
        self.on = on
        drawEntireCheckBox()
        if on {
            if animated {
                addOnAnimation()
            }
        } else {
            if animated {
                addOffAnimation()
            } else {
                onBoxLayer?.removeFromSuperlayer()
                checkMarkLayer?.removeFromSuperlayer()
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var found = super.point(inside: point, with: event)
        if found {
            return found
        }
        let minimumSize = minuimumTouchSize
        let width = bounds.width
        let height = bounds.height
        if width < minimumSize.width || height < minimumSize.height {
            let increaseWidth = minimumSize.width - width
            let increaseHeight = minimumSize.height - height
            let rect = bounds.insetBy(dx: -increaseWidth * 0.5, dy: -increaseHeight * 0.5)
            found = rect.contains(point)
        }
        return found
    }
    
    @objc private func tapCheckBox(_ tgr: UITapGestureRecognizer) {
        setOn(!on, animated: true)
        delegate?.checkBoxDidTap?(self)
        sendActions(for: .valueChanged)
    }
    
    override func draw(_ rect: CGRect) {
        setOn(on, animated: false)
    }

    private func drawEntireCheckBox() {
        if !hideBox {
            if offBoxLayer == nil || offBoxLayer?.path?.boundingBox.height == 0 {
                drawOffBox()
            }
            if on {
                drawOnBox()
            }
        }
        if on {
            drawCheckMark()
        }
    }
    
    private func drawOffBox() {
        offBoxLayer?.removeFromSuperlayer()
        offBoxLayer = CAShapeLayer()
        offBoxLayer?.frame = self.bounds
        offBoxLayer?.path = pathMgr.boxPath.cgPath
        offBoxLayer?.fillColor = offFillColor.cgColor
        offBoxLayer?.strokeColor = tintColor.cgColor
        offBoxLayer?.lineWidth = lineWidth
        offBoxLayer?.rasterizationScale = 2 * UIScreen.main.scale
        offBoxLayer?.shouldRasterize = true
        layer.addSublayer(offBoxLayer!)
    }
    
    private func drawOnBox() {
        onBoxLayer?.removeFromSuperlayer()
        onBoxLayer = CAShapeLayer()
        onBoxLayer?.frame = self.bounds
        onBoxLayer?.frame = self.bounds
        onBoxLayer?.path = pathMgr.boxPath.cgPath
        onBoxLayer?.lineWidth = lineWidth
        onBoxLayer?.fillColor = onFillColor.cgColor
        onBoxLayer?.strokeColor = onTintColor.cgColor
        onBoxLayer?.rasterizationScale = 2 * UIScreen.main.scale
        onBoxLayer?.shouldRasterize = true
        layer.addSublayer(onBoxLayer!)
    }
    
    private func drawCheckMark() {
        checkMarkLayer?.removeFromSuperlayer()
        checkMarkLayer = CAShapeLayer()
        checkMarkLayer?.frame = self.bounds
        checkMarkLayer?.path = pathMgr.checkMarkPath.cgPath
        checkMarkLayer?.strokeColor = onCheckColor.cgColor
        checkMarkLayer?.fillColor = UIColor.clear.cgColor
        checkMarkLayer?.lineWidth = lineWidth
        checkMarkLayer?.lineCap = .round
        checkMarkLayer?.lineJoin = .round
        checkMarkLayer?.rasterizationScale = 2 * UIScreen.main.scale
        checkMarkLayer?.shouldRasterize = true
        self.layer.addSublayer(checkMarkLayer!)
    }
    
    private func addOnAnimation() {
        if animationDuration == 0 { return }
        
        switch onAnimateType {
        case .stroke:
            let animation = animatorMgr.stroke()
            onBoxLayer?.add(animation, forKey: "strokeEnd")
            animation.delegate = self
            checkMarkLayer?.add(animation, forKey: "strokeEnd")
            break
        case .fill:
            let wiggle = animatorMgr.fill(bounces: 1, amplitude: 0.18)
            let opacityAnimation = animatorMgr.opacity()
            opacityAnimation.delegate = self
            onBoxLayer?.add(wiggle, forKey: "transform")
            checkMarkLayer?.add(opacityAnimation, forKey: "opacity")
            break
        case .bounce:
            let amplitude: CGFloat = type == .square ? 0.2 : 0.35
            let wiggle = animatorMgr.fill(bounces: 1, amplitude: amplitude)
            wiggle.delegate = self
            let opacity = animatorMgr.opacity()
            opacity.duration = CFTimeInterval(animationDuration / 1.4)
            onBoxLayer?.add(opacity, forKey: "opacity")
            checkMarkLayer?.add(wiggle, forKey: "transform")
            break
        case .flat:
            let morph = animatorMgr.morph(pathMgr.flatCheckMark, toPath: pathMgr.checkMarkPath)
            morph.delegate = self
            let opacity = animatorMgr.opacity()
            opacity.duration = CFTimeInterval(animationDuration / 5)
            onBoxLayer?.add(opacity, forKey: "opacity")
            checkMarkLayer?.add(morph, forKey: "path")
            checkMarkLayer?.add(opacity, forKey: "opacity")
            break
        case .oneStroke:
            checkMarkLayer?.path = pathMgr.longCheckMarPath.cgPath
            let boxStroke = animatorMgr.stroke()
            boxStroke.duration = boxStroke.duration * 0.5
            onBoxLayer?.add(boxStroke, forKey: "strokeEnd")
            
            let checkStroke = animatorMgr.stroke()
            checkStroke.duration = checkStroke.duration / 3
            checkStroke.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            checkStroke.fillMode = .backwards
            checkStroke.beginTime = CACurrentMediaTime() + boxStroke.duration
            checkMarkLayer?.add(checkStroke, forKey: "strokeEnd")
            
            let checkMorph = animatorMgr.morph(pathMgr.longCheckMarPath, toPath: pathMgr.checkMarkPath)
            checkMorph.duration = checkMorph.duration / 6
            checkMorph.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            checkMorph.beginTime = CACurrentMediaTime() + boxStroke.duration + checkStroke.duration
            checkMorph.isRemovedOnCompletion = false
            checkMorph.fillMode = .forwards
            checkMorph.delegate = self
            checkMarkLayer?.add(checkMorph, forKey: "path")
            break
        default:
            let animation = animatorMgr.opacity()
            onBoxLayer?.add(animation, forKey: "opacity")
            animation.delegate = self
            checkMarkLayer?.add(animation, forKey: "opacity")
            break
        }
    }
    
    private func addOffAnimation() {
        if animationDuration == 0 {
            onBoxLayer?.removeFromSuperlayer()
            checkMarkLayer?.removeFromSuperlayer()
            return
        }
        switch offAnimateType {
        case .stroke:
            let animation = animatorMgr.stroke(true)
            onBoxLayer?.add(animation, forKey: "strokeEnd")
            animation.delegate = self
            checkMarkLayer?.add(animation, forKey: "strokeEnd")
        case .fill:
            let wiggle = animatorMgr.fill(true, bounces: 1, amplitude: 0.18)
            wiggle.duration = CFTimeInterval(animationDuration)
            wiggle.delegate = self
            onBoxLayer?.add(wiggle, forKey: "transform")
            checkMarkLayer?.add(animatorMgr.opacity(true), forKey: "opacity")
        case .bounce:
            let amplitude: CGFloat = type == .square ? 0.2 : 0.35
            let wiggle = animatorMgr.fill(true, bounces: 1, amplitude: amplitude)
            wiggle.duration = CFTimeInterval(animationDuration / 1.1)
            let opacity = animatorMgr.opacity(true)
            opacity.delegate = self
            onBoxLayer?.add(opacity, forKey: "opacity")
            checkMarkLayer?.add(wiggle, forKey: "transform")
        case .flat:
            let animation = animatorMgr.morph(pathMgr.checkMarkPath, toPath: pathMgr.flatCheckMark)
            animation.delegate = self
            let opacity = animatorMgr.opacity(true)
            opacity.duration = CFTimeInterval(animationDuration)
            onBoxLayer?.add(opacity, forKey: "opacity")
            checkMarkLayer?.add(animation, forKey: "path")
            checkMarkLayer?.add(opacity, forKey: "opacity")
        case .oneStroke:
            checkMarkLayer?.path = pathMgr.checkMarkPath.reversing().cgPath
            let morphAnimation = animatorMgr.morph(pathMgr.checkMarkPath, toPath: pathMgr.checkMarkPath)
            morphAnimation.delegate = nil
            morphAnimation.duration = morphAnimation.duration / 6
            checkMarkLayer?.add(morphAnimation, forKey: "path")
            
            let stroke = animatorMgr.stroke(true)
            stroke.delegate = nil
            stroke.beginTime = CACurrentMediaTime() + morphAnimation.duration
            stroke.duration = stroke.duration / 3
            checkMarkLayer?.add(stroke, forKey: "strokeEnd")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + morphAnimation.duration + stroke.duration) {
                self.checkMarkLayer?.lineCap = .butt
            }
            let boxStroke = animatorMgr.stroke(true)
            boxStroke.beginTime = CACurrentMediaTime() + morphAnimation.duration + stroke.duration
            boxStroke.duration = boxStroke.duration * 0.5
            boxStroke.delegate = self
            onBoxLayer?.add(boxStroke, forKey: "strokeEnd")
        default:
            let animation = animatorMgr.opacity(true)
            onBoxLayer?.add(animation, forKey: "opacity")
            animation.delegate = self
            checkMarkLayer?.add(animation, forKey: "opacity")
        }
    }
   
    deinit {
        delegate = nil
    }
}

extension SSCheckBox: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if !on {
                onBoxLayer?.removeFromSuperlayer()
                checkMarkLayer?.removeFromSuperlayer()
            }
            delegate?.animationDidStop?(self)
        }
    }
}


private struct CheckBoxPath {
    
    var size: CGFloat
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    var type: SSCheckBoxType
    
    init(size: CGFloat, lineWidth: CGFloat, cornerRadius: CGFloat, type: SSCheckBoxType) {
        self.size = size
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.type = type
    }
    
    var boxPath: UIBezierPath {
        let path: UIBezierPath
        switch self.type {
        case .circle:
            path = UIBezierPath(roundedRect: CGRect(x: lineWidth * 0.5, y: lineWidth * 0.5, width: size - lineWidth, height: size - lineWidth), cornerRadius: cornerRadius)
            path.apply(CGAffineTransform.identity.rotated(by: CGFloat.pi * 2.5))
            path.apply(CGAffineTransform(translationX: size, y: 0))
            break
        case .square:
            let radius = size * 0.5 - lineWidth * 0.5
            path = UIBezierPath(arcCenter: CGPoint(x: size * 0.5, y: size * 0.5), radius: radius, startAngle: -CGFloat.pi * 0.25, endAngle: 2 * CGFloat.pi - CGFloat.pi * 0.25, clockwise: true)
            break
        }
        return path
    }
    
    var checkMarkPath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size / 3.1578, y: size * 0.5))
        path.addLine(to: CGPoint(x: size / 2.0618, y: size / 1.57894))
        path.addLine(to: CGPoint(x: size / 1.3953, y: size / 2.7272))
        if type == .square {
            path.apply(CGAffineTransform(scaleX: 1.5, y: 1.5))
            path.apply(CGAffineTransform(translationX: -size * 0.25, y: -size * 0.25))
        }
        return path
    }
    
    var longCheckMarPath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size / 3.1578, y: size * 0.5))
        path.addLine(to: CGPoint(x: size / 2.0618, y: size / 1.57894))
        if type == .square {
            path.addLine(to: CGPoint(x: size / 1.2053, y: size / 4.5272))
            path.apply(CGAffineTransform(scaleX: 1.5, y: 1.5))
            path.apply(CGAffineTransform(translationX: -size * 0.25, y: -size * 0.25))
        } else {
            path.addLine(to: CGPoint(x: size / 1.1553, y: size / 5.9272))
        }
        return path
    }
    
    var flatCheckMark: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size * 0.25, y: size * 0.5))
        path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.5))
        path.addLine(to: CGPoint(x: size / 1.2, y: size * 0.5))
        return path
    }
}


private struct CheckBoxAnimation {
    var duration: Double
    
    init(duration: Double = 2.5) {
        self.duration = duration
    }
    
    func stroke(_ isReverse: Bool = false) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        if isReverse {
            animation.fromValue = 1
            animation.toValue = 0
        } else {
            animation.fromValue = 0
            animation.toValue = 1
        }
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        return animation
    }
    
    func opacity(_ isReverse: Bool = false) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        if isReverse {
            animation.fromValue = 1
            animation.toValue = 0
        } else {
            animation.fromValue = 0
            animation.toValue = 1
        }
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
    
    func morph(_ fromPath: UIBezierPath, toPath: UIBezierPath) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fromValue = fromPath.cgPath
        animation.toValue = toPath.cgPath
        return animation
    }
    
    func fill(_ isReverse: Bool = false, bounces: Int, amplitude: CGFloat) -> CAKeyframeAnimation {
        var values = [NSValue]()
        var keyTimes = [NSNumber]()
        if isReverse {
            values.append(NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)))
        } else {
            values.append(NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 0)))
        }
        keyTimes.append(NSNumber(value: 0))
        for i in 1 ..< bounces {
            let scale: CGFloat = i % 2 == 0 ? 1.0 + amplitude / CGFloat(i) : 1.0 - amplitude / CGFloat(i)
            let time: CGFloat = CGFloat(i) * 1.0 / CGFloat((bounces + 1))
            values.append(NSValue(caTransform3D: CATransform3DMakeScale(scale, scale, scale)))
            keyTimes.append(NSNumber(value: Float(time)))
        }
        
        if isReverse {
            values.append(NSValue(caTransform3D: CATransform3DMakeScale(0.0001, 0.0001, 0.0001)))
        } else {
            values.append(NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)))
        }
        
        keyTimes.append(NSNumber(value: 1))
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.values = values
        animation.keyTimes = keyTimes
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }
}
