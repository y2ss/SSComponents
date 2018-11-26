//
//  SSDragBadgeView.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/19.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

@objc protocol SSDragBadgeViewDelegate: NSObjectProtocol {
    @objc optional func dragBadgeViewDidDraggedCompletion()
}

class SSDragBadgeView: UIView {
    
    weak var delegate: SSDragBadgeViewDelegate?
    var fillColor: UIColor = UIColor.red {
        willSet {
            shapeLayer.fillColor = newValue.cgColor;
        }
    }
 
    var elasticDuration: CGFloat = 0.5
    var fromRadiusScale: CGFloat = 0.09
    var toRadiusScale: CGFloat = 0.05
    var maxDistanceScale: CGFloat = 8
    var bombDuration: TimeInterval = 0.5
    var validRadius: CGFloat = 20
    var fontSize: CGFloat = 16 {
        willSet {
            textLabel.font = textLabel.font.withSize(newValue)
        }
    }
    
    //增大的点击区域
    var paddingSize: CGFloat = 10
    var hiddenWhenZero: Bool = true
    var fontSizeAutoFit: Bool = false
    var textColor: UIColor = UIColor.white {
        willSet {
            textLabel.textColor = newValue
        }
    }
    var text: String {
        set {
            textLabel.text = newValue
            textLabel.isHidden = false
            isHidden = false
            if hiddenWhenZero && (text == "0" || text == "")  {
                isHidden = true
            }
            reset()
        }
        get {
            return textLabel.text ?? ""
        }
    }
 
    private lazy var overlayView: UIControl = {
        let _view = UIControl(frame: UIScreen.main.bounds)
        _view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _view.backgroundColor = UIColor.clear
        return _view
    }()
    private weak var originSuperView: UIView!
    private var viscosity: CGFloat!
    private var circleSize: CGSize!
    private var originPoint: CGPoint!
    private var radius: CGFloat!
    private var fromPoint: CGPoint!
    private var toPoint: CGPoint!
    private var fromRadius: CGFloat!
    private var toRadius: CGFloat!
    private var elasticBeginPoint: CGPoint!
    private var missed: Bool!
    private var beEnableDragDrop: Bool!
    private var maxDistance: CGFloat!
    private var distance: CGFloat!
    private var activeTweenOperation: PRTweenOperation!
    private var textLabel: UILabel!
    private var bombImageView: UIImageView!
    private var shapeLayer: CAShapeLayer!
    private var panGestureRecognizer: UIPanGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShapeLayer() {
        shapeLayer = CAShapeLayer()
        self.layer.addSublayer(shapeLayer)
        shapeLayer.frame = CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height)
        shapeLayer.fillColor = fillColor.cgColor
    }
    
    private func setupAnimateImage() {
        bombImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        bombImageView.animationImages = [
            UIImage(named: "bomb1"),
            UIImage(named: "bomb2"),
            UIImage(named: "bomb3"),
            UIImage(named: "bomb4"),
            ] as? [UIImage]
        bombImageView.animationRepeatCount = 1
        bombImageView.animationDuration = bombDuration
        self.addSubview(bombImageView)
    }
    
    private func setupTextLabel() {
        textLabel = UILabel(frame: CGRect(x: paddingSize, y: paddingSize, width: circleSize.width, height: circleSize.width))
        textLabel.textColor = textColor
        textLabel.textAlignment = .center
        textLabel.text = ""
        self.addSubview(textLabel)
    }
    
    private func setupGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPanAction(_:)))
        panGestureRecognizer.delaysTouchesBegan = true
        panGestureRecognizer.delaysTouchesEnded = true
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setup() {
        circleSize = self.frame.size;
        var wrapperframe = self.frame
        
        wrapperframe.x -= paddingSize
        wrapperframe.y -= paddingSize
        wrapperframe.width += paddingSize * 2
        wrapperframe.height += paddingSize * 2
        self.frame = wrapperframe
        
        radius = circleSize.width * 0.5;
        originPoint = CGPoint(x: paddingSize + radius, y: paddingSize + radius)
        backgroundColor = UIColor.clear
        
        setupShapeLayer()
        setupAnimateImage()
        setupTextLabel()
        setupGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reset()
    }
    
    private func becomeUpper() {
        if let _superView = self.overlayView.superview {
            _superView.bringSubviewToFront(overlayView)
        } else {
            let reversedWindows = UIApplication.shared.windows.reversed()
            for window in reversedWindows {
                let windowOnMainScreen = window.screen == UIScreen.main
                let windowIsVisible = !window.isHidden && window.alpha > 0
                let windowLevelNormal = window.windowLevel == .normal
                if windowOnMainScreen && windowIsVisible && windowLevelNormal {
                    window.addSubview(overlayView)
                    break
                }
            }
        }
        
        guard let _superView = self.superview else {
            print("please add this view in some view")
            return
        }
        originSuperView = _superView
        center = originSuperView.convert(center, to: overlayView)
        
        if originSuperView.isKind(of: UITableViewCell.self) {
            if
                let cell = originSuperView as? UITableViewCell,
                let accessoryView = cell.accessoryView {
                if accessoryView == self {
                    cell.accessoryView = nil
                }
            }
        }
        overlayView.addSubview(self)
    }
    
    @objc private func update(_ period: PRTweenPeriod) {
        let c = period.tweenedValue
        
        if c.isNaN || c > 10000000 || c < -10000000 { return }
        if missed {
            let x = distance != 0 ? (toPoint.x - elasticBeginPoint.x) * c / distance : 0
            let y = distance != 0 ? (toPoint.y - elasticBeginPoint.y) * c / distance : 0
            fromPoint = CGPoint(x: elasticBeginPoint.x + x, y: elasticBeginPoint.y + y)
        } else {
            let x = distance != 0 ? (fromPoint.x - elasticBeginPoint.x) * c / distance : 0
            let y = distance != 0 ? (fromPoint.y - elasticBeginPoint.y) * c / distance : 0
            toPoint = CGPoint(x: elasticBeginPoint.x + x, y: elasticBeginPoint.y + y)
        }
        updateRadius()
    }
    
    private func resignUpper() {
        center = overlayView.convert(center, to: originSuperView)
        var shouldAdd = true
        if originSuperView.isKind(of: UITableViewCell.self)  {
            if
                let cell = originSuperView as? UITableViewCell,
                let accessoryView = cell.accessoryView {
                if accessoryView == self {
                    cell.accessoryView = self
                    shouldAdd = false
                }
            }
        }
        if shouldAdd {
            originSuperView.addSubview(self)
        }
        overlayView.removeFromSuperview()
    }
    
    private func updateRadius() {
        let r = _distance(between: fromPoint, p2: toPoint)
        fromRadius = radius - fromRadiusScale * r
        toRadius = radius - toRadiusScale * r
        viscosity = maxDistance != 0 ? 1 - r / maxDistance : 1
        if fontSizeAutoFit {
            if let text = textLabel.text {
                if text != "" {
                    textLabel.font = textLabel.font.withSize((2 * toRadius) / (1.2 * CGFloat(text.count)))
                }
            } else {
                textLabel.font = textLabel.font.withSize(fontSize)
            }
        }
        textLabel.center = toPoint
        setNeedsDisplay()
    }
    
    private func reset() {
        fromPoint = originPoint
        toPoint = fromPoint
        maxDistance = maxDistanceScale * radius
        beEnableDragDrop = true
        updateRadius()
    }
    
    deinit {
        print("--")
    }
}

//MARK: - pan action
extension SSDragBadgeView {
    
    @objc private func onPanAction(_ pgr: UIPanGestureRecognizer) {
        if !beEnableDragDrop { return }
        
        let point = pgr.location(in: self)
        switch pgr.state {
        case .began:
            onPanBeginAction(point)
            break
        case .changed:
            onPanMovedAction(point)
            break
        case .ended:
            onPanEndAction(point)
            break
        default:
            break
        }
    }
    
    private func onPanBeginAction(_ point: CGPoint) {
        missed = false
        becomeUpper()
    }
    
    private func onPanEndAction(_ point: CGPoint) {
        if !missed {
            elasticBeginPoint = toPoint
            distance = _distance(between: fromPoint, p2: toPoint)
            PRTween.sharedInstance()?.remove(activeTweenOperation)
            if let period = PRTweenPeriod.period(withStartValue: 0, endValue: distance, duration: elasticDuration) as? PRTweenPeriod {
                activeTweenOperation = PRTween.sharedInstance()?.add(period, target: self, selector: #selector(update(_:)), timing: PRTweenTimingFunctionElasticOut)
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(elasticDuration)) {
                    self.resignUpper()
                }
            }
        } else {
            if CGRect(x: originPoint.x - validRadius, y: originPoint.y - validRadius, width: 2 * validRadius, height: 2 * validRadius).contains(point) {
                resignUpper()
                reset()
            } else {
                bombImageView.center = toPoint
                toRadius = 0
                fromRadius = 0
                textLabel.isHidden = true
                bombImageView.startAnimating()
                beEnableDragDrop = false
                activeTweenOperation.updateSelector = nil
                PRTween.sharedInstance()?.remove(activeTweenOperation)
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(bombDuration)) {
                    self.resignUpper()
                }
                delegate?.dragBadgeViewDidDraggedCompletion?()
            }
        }
        setNeedsDisplay()
    }
    
    private func onPanMovedAction(_ point: CGPoint) {
        let r = _distance(between: fromPoint, p2: point)
        if missed {
            activeTweenOperation.updateSelector = nil
            if point != .zero {
                fromPoint = point
                toPoint = point
                updateRadius()
            }
        } else {
            toPoint = point
            if r > maxDistance {//超过范围 爆炸
                missed = true
                elasticBeginPoint = fromPoint
                distance = _distance(between: fromPoint, p2: toPoint)
                PRTween.sharedInstance()?.remove(activeTweenOperation)
                
                if let period = PRTweenPeriod.period(withStartValue: 0, endValue: distance, duration: elasticDuration) as? PRTweenPeriod {
                    activeTweenOperation = PRTween.sharedInstance()?.add(period, target: self, selector: #selector(update(_:)), timing: PRTweenTimingFunctionElasticOut)
                }
            } else {
                updateRadius()
            }
        }
    }
}

//MARK: - draw
extension SSDragBadgeView {
    override func draw(_ rect: CGRect) {
        let path = bezierPath(with: fromPoint, toPoint: toPoint, fromRadius: fromRadius, toRadius: toRadius, scale: viscosity)
        shapeLayer.path = path?.cgPath
    }
    
    private func bezierPath(with fromPoint: CGPoint, toPoint: CGPoint, fromRadius: CGFloat,
                            toRadius: CGFloat, scale: CGFloat) -> UIBezierPath? {
        if fromRadius.isNaN || toRadius.isNaN { return nil }
        
        let path = UIBezierPath()
        let r = _distance(between: fromPoint, p2: toPoint)
        let offsetY = CGFloat(fabsf(Float(fromRadius - toRadius)))
        if r <= offsetY {
            var center: CGPoint
            var radius: CGFloat
            if fromRadius >= toRadius {
                center = fromPoint
                radius = fromRadius
            } else {
                center = toPoint
                radius = toRadius
            }
            path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        } else {
            
            let originX = toPoint.x - fromPoint.x
            let originY = toPoint.y - fromPoint.y
            
            let fromOriginAngel = originX >= 0 ? atan(originY / originX) : atan(originY / originX) + CGFloat.pi
            let fromOffsetAngel = fromRadius >= toRadius ? acos(offsetY / r) : CGFloat.pi - acos(offsetY / r)
            let fromStartAngel = fromOriginAngel + fromOffsetAngel
            let fromEndAngel = fromOriginAngel - fromOffsetAngel
            let fromStartPoint = CGPoint(x: fromPoint.x + cos(fromStartAngel) * fromRadius, y: fromPoint.y + sin(fromStartAngel) * fromRadius)
            
            let toOriginAngel = originX < 0 ? atan(originY / originX) : atan(originY / originX) + CGFloat.pi
            let toOffsetAngel = fromRadius < toRadius ? acos(offsetY / r) : CGFloat.pi - acos(offsetY / r)
            let toStartAngel = toOriginAngel + toOffsetAngel
            let toEndAngel = toOriginAngel - toOffsetAngel
            let toStartPoint = CGPoint(x: toPoint.x + cos(toStartAngel) * toRadius, y: toPoint.y + sin(toStartAngel) * toRadius)
            
            let middlePoint = CGPoint(x: fromPoint.x + (toPoint.x - fromPoint.x) * 0.5, y: fromPoint.y + (toPoint.y - fromPoint.y) * 0.5)
            let middleRadius = (fromRadius + toRadius) * 0.5
            let fromControlPoint = CGPoint(x: middlePoint.x + sin(fromOriginAngel) * middleRadius * scale, y: middlePoint.y - cos(fromOriginAngel) * middleRadius * scale)
            let toControlPoint = CGPoint(x: middlePoint.x + sin(toOriginAngel) * middleRadius * scale, y: middlePoint.y - cos(toOriginAngel) * middleRadius * scale)
            
            path.move(to: fromStartPoint)
            path.addArc(withCenter: fromPoint, radius: fromRadius, startAngle: fromStartAngel, endAngle: fromEndAngel, clockwise: true)
            if r > fromRadius + toRadius {
                path.addQuadCurve(to: toStartPoint, controlPoint: fromControlPoint)
            }
            path.addArc(withCenter: toPoint, radius: toRadius, startAngle: toStartAngel, endAngle: toEndAngel, clockwise: true)
            if r > fromRadius + toRadius {
                path.addQuadCurve(to: fromStartPoint, controlPoint: toControlPoint)
            }
        }
        path.close()
        return path
    }
}

private func _distance(between p1: CGPoint, p2: CGPoint) -> CGFloat {
    let x = Float(p2.x - p1.x)
    let y = Float(p2.y - p1.y)
    return CGFloat(sqrtf(x * x + y * y))
}


