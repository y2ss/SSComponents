//
//  SSPopButton.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/23.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit


enum PopButtonType: Int {
    case `default` = 0
    case add
    case minus
    case close
    case back
    case forward
    case menu
    case download
    case share
    case downBasic
    case upBasic
    case downArrow
    case paused
    case rightTriangle
    case leftTriangle
    case upTriangle
    case downTriangle
    case ok
    case rewind
    case fastForward
    case square
}

class SSPopButton: UIButton {
    
    enum Style {
        case plain
        case round
    }
    
    var type: PopButtonType {
        set {
            if _type != newValue {
                animate(to: newValue)
            }
        }
        get {
            return _type
        }
    }
    private var _type: PopButtonType = .default
    
    var style: Style = .round
    
    var lineThickness: CGFloat = 2 {
        didSet {
            firstSegment.lineThickness = oldValue
            secondSegment.lineThickness = oldValue
            thirdSegment.lineThickness = oldValue
        }
    }
    var lineRadius: CGFloat = 0 {
        didSet {
            firstSegment.lineRadius = oldValue
            secondSegment.lineRadius = oldValue
            thirdSegment.lineRadius = oldValue
        }
    }
 
    private var tintColors: [UInt: UIColor]?
    private var firstSegment: PopSegment!
    private var secondSegment: PopSegment!
    private var thirdSegment: PopSegment!
    private var bckgLayer: CALayer?
    private var animateToStartPosition: Bool = true
    var roundBackgroundColor: UIColor = UIColor.white {
        didSet {
            if style == .round {
                if bckgLayer == nil {
                    setupBackgroundLayer()
                }
                bckgLayer?.backgroundColor = oldValue.cgColor
            }
        }
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, type: .default, style: .plain, animate: true)
    }
    
    init(frame: CGRect, type: PopButtonType, style: Style, animate: Bool) {
        super.init(frame: frame)
        commonSetup()
        self.type = type
        self.style = style
        self.animateToStartPosition = animate
        self.tintColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBackgroundLayer() {
        bckgLayer = CALayer()
        let amount = frame.width / 3
        bckgLayer?.frame = bounds.insetBy(dx: -amount, dy: -amount)
        bckgLayer?.cornerRadius = bckgLayer!.bounds.width * 0.5
        bckgLayer?.backgroundColor = roundBackgroundColor.cgColor
        self.layer.insertSublayer(bckgLayer!, below: firstSegment)
    }
    
    private func commonSetup() {
        firstSegment = PopSegment(frame.width, lineThickness: lineThickness, lineRadius: lineRadius, lineColor: tintColor, initialState: .default)
        layer.addSublayer(firstSegment)
        
        secondSegment = PopSegment(frame.width, lineThickness: lineThickness, lineRadius: lineRadius, lineColor: tintColor, initialState: .default)
        layer.addSublayer(secondSegment)
        
        thirdSegment = PopSegment(frame.width, lineThickness: lineThickness, lineRadius: lineRadius, lineColor: tintColor, initialState: .minu)
        thirdSegment.opacity = 0
        layer.addSublayer(thirdSegment)
        
        if style == .round {
            setupBackgroundLayer()
        }
        animate(to: type)
    }
    
    override var tintColor: UIColor! {
        didSet {
            firstSegment.lineColor = oldValue
            secondSegment.lineColor = oldValue
            thirdSegment.lineColor = oldValue
        }
    }
    
    func setTintColor(for state: UIControl.State, tintColor: UIColor?) {
        if tintColors == nil {
            tintColors = [UInt: UIColor]()
        }
        if let _tintColor = tintColor {
            tintColors?[state.rawValue] = _tintColor
        } else {
            tintColors?.removeValue(forKey: state.rawValue)
        }
        updateState()
    }
    
    override var isSelected: Bool {
        didSet {
            updateState()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateState()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateState()
        }
    }
    
    private func updateState() {
        self.tintColor = self.tintColor(forState: self.state)
    }
    
    private func tintColor(forState: UIControl.State) -> UIColor {
        if let tint = tintColors?[self.state.rawValue] {
            return tint
        } else {
            if let tint = tintColors?[UIControl.State.normal.rawValue] {
                return tint
            }
            if let tint = self.tintColor {
                return tint
            }
            if let tint = self.window?.tintColor {
                return tint
            }
            return UIColor.white
        }
    }
    
    func animate(to type: PopButtonType) {
        firstSegment.opacity = 1
        secondSegment.opacity = 1
        thirdSegment.opacity = 0
        var firstOriginPoint = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        var secondOriginPoint = firstOriginPoint
        var thirdOriginPoint = firstOriginPoint
        
        switch type {
        case .add:
            firstSegment.move(to: .firstQuadrant, animated: animateToStartPosition)
            secondSegment.move(to: .thridQuadrant, animated: animateToStartPosition)
            break
        case .back:
            firstSegment.move(to: .lessThan, animated: animateToStartPosition)
            secondSegment.move(to: .lessThan, animated: animateToStartPosition)
            secondSegment.opacity = 0
            let hAmount = frame.width * 0.2
            firstOriginPoint.x -= hAmount
            secondOriginPoint.x -= hAmount
            break
        case .close:
            firstSegment.move(to: .lessThan, animated: animateToStartPosition)
            secondSegment.move(to: .moreThan, animated: animateToStartPosition)
            break
        case .default:
            firstSegment.move(to: .default, animated: animateToStartPosition)
            secondSegment.move(to: .default, animated: animateToStartPosition)
            break
        case .forward:
            firstSegment.move(to: .moreThan, animated: animateToStartPosition)
            secondSegment.move(to: .moreThan, animated: animateToStartPosition)
            secondSegment.opacity = 0
            let hAmount = frame.width * 0.2
            firstOriginPoint.x += hAmount
            secondOriginPoint.x += hAmount
            break
        case .menu:
            thirdSegment.opacity = 1
            firstSegment.move(to: .minu, animated: animateToStartPosition)
            secondSegment.move(to: .minu, animated: animateToStartPosition)
            thirdSegment.move(to: .minu, animated: animateToStartPosition)
            let verticalAmount = frame.height / 3
            thirdOriginPoint.y -= verticalAmount
            secondOriginPoint.y += verticalAmount
            break
        case .minus:
            firstSegment.move(to: .minu, animated: animateToStartPosition)
            secondSegment.move(to: .minu, animated: animateToStartPosition)
            break
        case .download:
            thirdSegment.opacity = 1
            firstSegment.move(to: .default, animated: animateToStartPosition)
            secondSegment.move(to: .downArrow, animated: animateToStartPosition)
            thirdSegment.move(to: .minu, animated: animateToStartPosition)
            secondOriginPoint.y += bounds.width * 0.5
            thirdOriginPoint.y += bounds.width * 0.5
            break
        case .share:
            firstSegment.move(to: .default, animated: animateToStartPosition)
            secondSegment.move(to: .upArrow, animated: animateToStartPosition)
            secondOriginPoint.y -= bounds.width * 0.5
            break
        case .downBasic:
            firstSegment.move(to: .downArrow, animated: animateToStartPosition)
            secondSegment.move(to: .downArrow, animated: animateToStartPosition)
            secondSegment.opacity = 0
            firstOriginPoint.y += firstSegment.frame.height * 0.2
            break
        case .downArrow:
            firstSegment.move(to: .default, animated: animateToStartPosition)
            secondSegment.move(to: .downArrow, animated: animateToStartPosition)
            secondOriginPoint.y += bounds.width * 0.5
            break
        case .upBasic:
            firstSegment.move(to: .upArrow, animated: animateToStartPosition)
            secondSegment.move(to: .upArrow, animated: animateToStartPosition)
            secondSegment.opacity = 0
            firstOriginPoint.y -= firstSegment.frame.height * 0.2
            break
        case .paused:
            firstSegment.move(to: .default, animated: animateToStartPosition)
            secondSegment.move(to: .default, animated: animateToStartPosition)
            let horizontalAmount = frame.height * 0.2
            firstOriginPoint.x -= horizontalAmount
            secondOriginPoint.x += horizontalAmount
            break
        case .rightTriangle:
            thirdSegment.opacity = 1
            firstSegment.move(to: .slash60, animated: animateToStartPosition)
            secondSegment.move(to: .backSlash60, animated: animateToStartPosition)
            thirdSegment.move(to: .default, animated: animateToStartPosition)
            firstOriginPoint.y -= bounds.width * 0.24
            secondOriginPoint.y += bounds.width * 0.24
            firstOriginPoint.x += bounds.width / 8
            secondOriginPoint.x += bounds.width / 8
            thirdOriginPoint.x -= bounds.width * 0.3
            break
        case .leftTriangle:
            thirdSegment.opacity = 1
            firstSegment.move(to: .slash60, animated: animateToStartPosition)
            secondSegment.move(to: .backSlash60, animated: animateToStartPosition)
            thirdSegment.move(to: .default, animated: animateToStartPosition)
            firstOriginPoint.y += bounds.width * 0.24;
            secondOriginPoint.y -= bounds.width * 0.24;
            firstOriginPoint.x -= bounds.width / 8;
            secondOriginPoint.x -= bounds.width / 8;
            thirdOriginPoint.x += bounds.width * 0.3;
            break
        case .upTriangle:
            thirdSegment.opacity = 1
            firstSegment.move(to: .slash30, animated: animateToStartPosition)
            secondSegment.move(to: .backSlash30, animated: animateToStartPosition)
            thirdSegment.move(to: .minu, animated: animateToStartPosition)
            firstOriginPoint.x += bounds.width * 0.24
            secondOriginPoint.x -= bounds.width * 0.24
            firstOriginPoint.y -= bounds.width / 8
            secondOriginPoint.y -= bounds.width / 8
            thirdOriginPoint.y += bounds.width * 0.3
            break
        case .downTriangle:
            thirdSegment.opacity = 1
            firstSegment.move(to: .slash30, animated: animateToStartPosition)
            secondSegment.move(to: .backSlash30, animated: animateToStartPosition)
            thirdSegment.move(to: .minu, animated: animateToStartPosition)
            firstOriginPoint.x -= bounds.width * 0.24
            secondOriginPoint.x += bounds.width * 0.24
            firstOriginPoint.y += bounds.width / 8
            secondOriginPoint.y += bounds.width / 8
            thirdOriginPoint.y -= bounds.width * 0.3
            break
        case .ok:
            thirdSegment.opacity = 0
            firstSegment.move(to: .backSlash45, animated: animateToStartPosition)
            secondSegment.move(to: .downArrow, animated: animateToStartPosition)
            firstOriginPoint.y += bounds.width / 6
            secondOriginPoint.y += bounds.width * 0.5
            firstOriginPoint.x += bounds.width * 0.19
            secondOriginPoint.x -= bounds.width * 0.14
            break
        case .rewind:
            firstSegment.move(to: .lessThan, animated: animateToStartPosition)
            secondSegment.move(to: .lessThan, animated: animateToStartPosition)
            firstOriginPoint.x -= bounds.width * 0.4
            break
        case .fastForward:
            firstSegment.move(to: .moreThan, animated: animateToStartPosition)
            secondSegment.move(to: .moreThan, animated: animateToStartPosition)
            firstOriginPoint.x += bounds.width * 0.4
            break
        case .square:
            firstSegment.move(to: .fourthQuadrant, animated: animateToStartPosition)
            secondSegment.move(to: .secondQuadrant, animated: animateToStartPosition)
            let offsetAmount = bounds.height * 0.25 - lineThickness * 0.25
            firstOriginPoint.y -= offsetAmount
            secondOriginPoint.y += offsetAmount
            firstOriginPoint.x -= offsetAmount
            secondOriginPoint.x += offsetAmount
            
            break
        }
        firstSegment.movePosition(to: firstOriginPoint, animated: animateToStartPosition)
        secondSegment.movePosition(to: secondOriginPoint, animated: animateToStartPosition)
        thirdSegment.movePosition(to: thirdOriginPoint, animated: animateToStartPosition)
        if !animateToStartPosition {
            animateToStartPosition = true
        }
        _type = type
    }
}

private class PopSegment: CALayer {
    enum state {
        case `default`      // |
        case firstQuadrant  // |_
        case secondQuadrant // _|
        case thridQuadrant  // -|
        case fourthQuadrant // |-
        case lessThan       // <
        case moreThan       // >
        case upArrow        // ^
        case downArrow      //
        case minu           // --
        case slash45        // \
        case backSlash45    // /
        case slash30        // \
        case backSlash30    // /
        case slash60        // \
        case backSlash60    // /
    }
    
    var segmentState: state = .default
    
    var lineThickness: CGFloat = 0 {
        didSet {
            topAnchorPoint = (totalLength * 0.5) / ((totalLength + oldValue) * 0.5)
            if bottomLine != nil {
                bottomLine.bounds = CGRect(x: 0, y: 0, width: oldValue, height: (totalLength + oldValue) * 0.5)
                bottomLine.path = UIBezierPath(roundedRect: bottomLine.bounds, cornerRadius: lineRadius).cgPath
                bottomLine.anchorPoint = CGPoint(x: 0.5, y: 1 - topAnchorPoint)
            }
            if topLine != nil {
                topLine.bounds = CGRect(x: 0, y: 0, width: oldValue, height: (totalLength + oldValue) * 0.5)
                topLine.path = UIBezierPath(roundedRect: topLine.bounds, cornerRadius: lineRadius).cgPath
                topLine.anchorPoint = CGPoint(x: 0.5, y: topAnchorPoint)
            }
        }
    }
    
    var lineRadius: CGFloat = 0 {
        didSet {
            if bottomLine != nil {
                bottomLine.path = UIBezierPath(roundedRect: bottomLine.bounds, cornerRadius: oldValue).cgPath
            }
            if topLine.path != nil {
                topLine.path = UIBezierPath(roundedRect: topLine.bounds, cornerRadius: oldValue).cgPath
            }
        }
    }
    
    var lineColor: UIColor = UIColor.white {
        didSet {
            if bottomLine != nil {
                bottomLine.fillColor = oldValue.cgColor
            }
            if topLine.path != nil {
                topLine.fillColor = oldValue.cgColor
            }
        }
    }
    
    private var totalLength: CGFloat = 0
    private var topLine: CAShapeLayer! = nil
    private var bottomLine: CAShapeLayer! = nil
    private var topAnchorPoint: CGFloat = 0
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.totalLength = 20
        self.lineThickness = 2
        self.lineColor = UIColor.white
        self.lineRadius = 0
        self.backgroundColor = UIColor.clear.cgColor
        self.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        setup()
        move(to: .default, animated: false)
    }
    
    
    init(_ length: CGFloat, lineThickness: CGFloat, lineRadius: CGFloat, lineColor: UIColor, initialState: state) {
        super.init()
        self.totalLength = length
        self.lineThickness = lineThickness
        self.lineColor = lineColor
        self.lineRadius = lineRadius
        self.backgroundColor = UIColor.clear.cgColor
        self.frame = CGRect(x: 0, y: 0, width: length, height: length)
        setup()
        move(to: initialState, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        topAnchorPoint = (totalLength * 0.5) / ((totalLength + lineThickness) * 0.5)
        topLine = CAShapeLayer()
        topLine.bounds = CGRect(x: 0, y: 0, width: lineThickness, height: (totalLength + lineThickness) * 0.5)
        topLine.path = UIBezierPath(roundedRect: topLine.bounds, cornerRadius: lineRadius).cgPath
        topLine.fillColor = lineColor.cgColor
        topLine.anchorPoint = CGPoint(x: 0.5, y: topAnchorPoint)
        topLine.position = CGPoint(x: totalLength * 0.5, y: totalLength * 0.5)
        self.addSublayer(topLine)
        
        bottomLine = CAShapeLayer()
        bottomLine.bounds = CGRect(x: 0, y: 0, width: lineThickness, height: (totalLength + lineThickness) * 0.5)
        bottomLine.path = UIBezierPath(roundedRect: bottomLine.bounds, cornerRadius: lineRadius).cgPath
        bottomLine.fillColor = lineColor.cgColor
        bottomLine.anchorPoint = CGPoint(x: 0.5, y: 1 - topAnchorPoint)
        bottomLine.position = CGPoint(x: totalLength * 0.5, y: totalLength * 0.5)
        self.addSublayer(bottomLine)
    }
    
    func move(to finalState: state, animated: Bool) {
        var toValueTop: CGFloat = 0
        var toValueBottom: CGFloat = 0
        switch  finalState{
        case .default:
            toValueTop = 0
            toValueBottom = 0
            break
        case .firstQuadrant:
            toValueTop = 0
            toValueBottom = -CGFloat.pi * 0.5
            break
        case .secondQuadrant:
            toValueTop = 0
            toValueBottom = CGFloat.pi * 0.5
            break
        case .thridQuadrant:
            toValueTop = -CGFloat.pi * 0.5
            toValueBottom = 0
            break
        case .fourthQuadrant:
            toValueTop = CGFloat.pi * 0.5
            toValueBottom = 0
            break
        case .lessThan:
            toValueTop = CGFloat.pi * 0.25
            toValueBottom = -CGFloat.pi * 0.25
            break
        case .moreThan:
            toValueTop = -CGFloat.pi * 0.25
            toValueBottom = CGFloat.pi * 0.25
            break
        case .minu:
            toValueTop = -CGFloat.pi / 2
            toValueBottom = -CGFloat.pi / 2
            break
        case .downArrow:
            toValueTop = -CGFloat.pi * 0.25
            toValueBottom = -CGFloat.pi * 0.25 * 3
            break
        case .upArrow:
            toValueTop = -CGFloat.pi * 0.25 * 3
            toValueBottom = -CGFloat.pi * 0.25
            break
        case .slash45:
            toValueTop = -CGFloat.pi * 0.25
            toValueBottom = -CGFloat.pi * 0.25
            break
        case .backSlash45:
            toValueTop = CGFloat.pi * 0.25
            toValueBottom = CGFloat.pi * 0.25
            break
        case .slash30:
            toValueTop = -CGFloat.pi * 0.5 / 3
            toValueBottom = -CGFloat.pi * 0.5 / 3
            break
        case .backSlash30:
            toValueTop = CGFloat.pi * 0.5 / 3
            toValueBottom = CGFloat.pi * 0.5 / 3
            break
        case .slash60:
            toValueTop = -CGFloat.pi / 3
            toValueBottom = -CGFloat.pi / 3
            break
        case .backSlash60:
            toValueTop = CGFloat.pi / 3
            toValueBottom = CGFloat.pi / 3
            break
        }
        
        if animated {
            addSpringRotation(to: topLine, value: toValueTop)
            addSpringRotation(to: bottomLine, value: toValueBottom)
        } else {
            topLine.transform = CATransform3DMakeRotation(toValueTop, 0, 0, 1)
            bottomLine.transform = CATransform3DMakeRotation(toValueBottom, 0, 0, 1)
        }
    }
    
    func movePosition(to finalPosition: CGPoint, animated: Bool) {
        if animated {
            let toPoint = NSValue(cgPoint: finalPosition)
            self.addSpringTranslation(to: self.topLine, value: toPoint)
            self.addSpringTranslation(to: self.bottomLine, value: toPoint)
        } else {
            self.topLine.position = finalPosition
            self.bottomLine.position = finalPosition
        }
    }
    
    private func addSpringRotation(to layer: CAShapeLayer, value: CGFloat) {
        if let anim = layer.pop_animation(forKey: "springRotation") as? POPSpringAnimation {
            anim.toValue = value
        } else {
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
            anim?.delegate = self
            anim?.springSpeed = 20
            anim?.springBounciness = 12
            anim?.dynamicsTension = 500
            anim?.toValue = value
            anim?.name = "rotationToState"
            layer.pop_add(anim, forKey: "springRotation")
        }
    }
    
    private func addSpringTranslation(to layer: CAShapeLayer, value: NSValue) {
        if let anim = layer.pop_animation(forKey: "basicTranslation") as? POPSpringAnimation {
            anim.toValue = value
        } else {
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
            anim?.toValue = value
            layer.pop_add(anim, forKey: "basicTranslation")
        }
    }
}

