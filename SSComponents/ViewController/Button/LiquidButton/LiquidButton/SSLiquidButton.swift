//
//  SSLiquidButton.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/1.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation
import QuartzCore

@objc protocol SSLiquidButtonDataSource {
    func numberOfCells(_ button: SSLiquidButton) -> Int
    func cellForIndex(_ index: Int) -> LiquidFloatingCell
}

@objc protocol SSLiquidButtonDelegate {
    // selected method
    @objc optional func liquidFloatingActionButton(_ button: SSLiquidButton, didSelectItemAtIndex index: Int)
    @objc optional func liquidFloatingActionButtonWillOpenDrawer(_ button: SSLiquidButton)
    @objc optional func liquidFloatingActionButtonWillCloseDrawer(_ button: SSLiquidButton)
}


@IBDesignable
class SSLiquidButton : UIView {
    
    enum AnimateStyle : Int {
        case up
        case right
        case left
        case down
    }
    
    fileprivate let internalRadiusRatio: CGFloat = 20.0 / 56.0
    var cellRadiusRatio: CGFloat      = 0.38
    var animateStyle: AnimateStyle = .up {
        didSet {
            baseView.animateStyle = animateStyle
        }
    }
    
    weak var delegate:   SSLiquidButtonDelegate?
    weak var dataSource: SSLiquidButtonDataSource?
    
    var responsible = true
    var isOpening: Bool  {
        get {
            return !baseView.openingCells.isEmpty
        }
    }
    fileprivate(set) var isClosed: Bool = true
    
    @IBInspectable var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0) {
        didSet {
            baseView.color = color
        }
    }
    
    @IBInspectable var image: UIImage? {
        didSet {
            if image != nil {
                plusLayer.contents = image!.cgImage
                plusLayer.path = nil
            }
        }
    }
    
    @IBInspectable var rotationDegrees: CGFloat = 45.0
    
    fileprivate var plusLayer   = CAShapeLayer()
    fileprivate let circleLayer = CAShapeLayer()
    
    fileprivate var touching = false
    
    fileprivate var baseView = CircleLiquidBaseView()
    fileprivate let liquidView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func insertCell(_ cell: LiquidFloatingCell) {
        cell.color  = self.color
        cell.radius = self.frame.width * cellRadiusRatio
        cell.center = self.center.minus(self.frame.origin)
        cell.actionButton = self
        insertSubview(cell, aboveSubview: baseView)
    }
    
    private func cellArray() -> [LiquidFloatingCell] {
        var result: [LiquidFloatingCell] = []
        if let source = dataSource {
            for i in 0..<source.numberOfCells(self) {
                result.append(source.cellForIndex(i))
            }
        }
        return result
    }
    
    // open all cells
    func open() {
        delegate?.liquidFloatingActionButtonWillOpenDrawer?(self)
        
        // rotate plus icon
        CATransaction.setAnimationDuration(0.8)
        self.plusLayer.transform = CATransform3DMakeRotation((.pi * rotationDegrees) / 180, 0, 0, 1)
        
        let cells = cellArray()
        cells.each { cell in
            self.insertCell(cell)
        }
        self.baseView.open(cells)
        
        self.isClosed = false
    }
    
    // close all cells
    func close() {
        delegate?.liquidFloatingActionButtonWillCloseDrawer?(self)
        
        // rotate plus icon
        CATransaction.setAnimationDuration(0.8)
        self.plusLayer.transform = CATransform3DMakeRotation(0, 0, 0, 1)
        
        self.baseView.close(cellArray())
        
        self.isClosed = true
    }
    
    // MARK: draw icon
    override func draw(_ rect: CGRect) {
        drawCircle()
    }
    
    /// create, configure & draw the plus layer (override and create your own shape in subclass!)
    func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
        
        // draw plus shape
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = .round
        plusLayer.strokeColor = UIColor.white.cgColor
        plusLayer.lineWidth = 3.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width * internalRadiusRatio, y: frame.height * 0.5))
        path.addLine(to: CGPoint(x: frame.width * (1 - internalRadiusRatio), y: frame.height * 0.5))
        path.move(to: CGPoint(x: frame.width * 0.5, y: frame.height * internalRadiusRatio))
        path.addLine(to: CGPoint(x: frame.width * 0.5, y: frame.height * (1 - internalRadiusRatio)))
        
        plusLayer.path = path.cgPath
        return plusLayer
    }
    
    private func drawCircle() {
        self.circleLayer.cornerRadius = self.frame.width * 0.5
        self.circleLayer.masksToBounds = true
        if touching && responsible {
            self.circleLayer.backgroundColor = self.color.white(0.5).cgColor
        } else {
            self.circleLayer.backgroundColor = self.color.cgColor
        }
    }
    
    // MARK: Events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touching = true
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touching = false
        setNeedsDisplay()
        didTapped()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.touching = false
        setNeedsDisplay()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for cell in cellArray() {
            let pointForTargetView = cell.convert(point, from: self)
            
            if (cell.bounds.contains(pointForTargetView)) {
                if cell.isUserInteractionEnabled {
                    return cell.hitTest(pointForTargetView, with: event)
                }
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    // MARK: private methods
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        
        baseView.setup(self)
        addSubview(baseView)
        
        liquidView.frame = baseView.frame
        liquidView.isUserInteractionEnabled = false
        addSubview(liquidView)
        
        liquidView.layer.addSublayer(circleLayer)
        circleLayer.frame = liquidView.layer.bounds
        
        plusLayer = createPlusLayer(circleLayer.bounds)
        circleLayer.addSublayer(plusLayer)
        plusLayer.frame = circleLayer.bounds
    }
    
    fileprivate func didTapped() {
        if isClosed {
            open()
        } else {
            close()
        }
    }
    
    func didTappedCell(_ target: LiquidFloatingCell) {
        if let _ = dataSource {
            let cells = cellArray()
            for i in 0 ..< cells.count {
                let cell = cells[i]
                if target === cell {
                    delegate?.liquidFloatingActionButton?(self, didSelectItemAtIndex: i)
                }
            }
        }
    }
}

class ActionBarBaseView : UIView {
    var opening = false
    func setup(_ actionButton: SSLiquidButton) {
    }
    
    func translateY(_ layer: CALayer, duration: CFTimeInterval, f: (CABasicAnimation) -> ()) {
        let translate = CABasicAnimation(keyPath: "transform.translation.y")
        f(translate)
        translate.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        translate.isRemovedOnCompletion = false
        translate.fillMode = .forwards
        translate.duration = duration
        layer.add(translate, forKey: "transYAnim")
    }
}

class CircleLiquidBaseView: ActionBarBaseView {
    
    let openDuration: CGFloat  = 0.6
    let closeDuration: CGFloat = 0.2
    let viscosity: CGFloat     = 0.65
    var animateStyle: SSLiquidButton.AnimateStyle = .up
    var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0) {
        didSet {
            engine?.color = color
            bigEngine?.color = color
        }
    }
    
    var baseLiquid: LiquittableCircle?
    var engine:     SimpleCircleLiquidEngine?
    var bigEngine:  SimpleCircleLiquidEngine?
    var enableShadow = true
    
    fileprivate var openingCells: [LiquidFloatingCell] = []
    fileprivate var keyDuration: CGFloat = 0
    fileprivate var displayLink: CADisplayLink?
    
    override func setup(_ actionButton: SSLiquidButton) {
        self.frame = actionButton.frame
        self.center = actionButton.center.minus(actionButton.frame.origin)
        self.animateStyle = actionButton.animateStyle
        let radius = min(self.frame.width, self.frame.height) * 0.5
        self.engine = SimpleCircleLiquidEngine(radiusThresh: radius * 0.73, angleThresh: 0.45)
        engine?.viscosity = viscosity
        self.bigEngine = SimpleCircleLiquidEngine(radiusThresh: radius, angleThresh: 0.55)
        bigEngine?.viscosity = viscosity
        self.engine?.color = actionButton.color
        self.bigEngine?.color = actionButton.color
        
        baseLiquid = LiquittableCircle(center: self.center.minus(self.frame.origin), radius: radius, color: actionButton.color)
        baseLiquid?.clipsToBounds = false
        baseLiquid?.layer.masksToBounds = false
        
        clipsToBounds = false
        layer.masksToBounds = false
        addSubview(baseLiquid!)
    }
    
    func open(_ cells: [LiquidFloatingCell]) {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(didDisplayRefresh(_:)))
        displayLink?.add(to: RunLoop.current, forMode: .common)
        opening = true
        for cell in cells {
            cell.layer.removeAllAnimations()
            openingCells.append(cell)
        }
    }
    
    func close(_ cells: [LiquidFloatingCell]) {
        stop()
        opening = false
        displayLink = CADisplayLink(target: self, selector: #selector(didDisplayRefresh(_:)))
        displayLink?.add(to: RunLoop.current, forMode: .common)
        for cell in cells {
            cell.layer.removeAllAnimations()
            openingCells.append(cell)
            cell.isUserInteractionEnabled = false
        }
    }
    
    func didFinishUpdate() {
        if opening {
            for cell in openingCells {
                cell.isUserInteractionEnabled = true
            }
        } else {
            for cell in openingCells {
                cell.removeFromSuperview()
            }
        }
    }
    
    func update(_ delay: CGFloat, duration: CGFloat, f: (LiquidFloatingCell, Int, CGFloat) -> ()) {
        if openingCells.isEmpty {
            return
        }
        
        let maxDuration = duration + CGFloat(openingCells.count) * CGFloat(delay)
        let t = keyDuration
        let allRatio = easeInEaseOut(t / maxDuration)
        
        if allRatio >= 1.0 {
            didFinishUpdate()
            stop()
            return
        }
        
        engine?.clear()
        bigEngine?.clear()
        for i in 0..<openingCells.count {
            let liquidCell = openingCells[i]
            let cellDelay = CGFloat(delay) * CGFloat(i)
            let ratio = easeInEaseOut((t - cellDelay) / duration)
            f(liquidCell, i, ratio)
        }
        
        if let firstCell = openingCells.first {
            bigEngine?.push(circle: baseLiquid!, other: firstCell)
        }
        for i in 1..<openingCells.count {
            let prev = openingCells[i - 1]
            let cell = openingCells[i]
            engine?.push(circle: prev, other: cell)
        }
        engine?.draw(parent: baseLiquid!)
        bigEngine?.draw(parent: baseLiquid!)
    }
    
    func updateOpen() {
        update(0.1, duration: openDuration) { cell, i, ratio in
            let posRatio = ratio > CGFloat(i) / CGFloat(self.openingCells.count) ? ratio : 0
            let distance = (cell.frame.height * 0.5 + CGFloat(i + 1) * cell.frame.height * 1.5) * posRatio
            cell.center = self.center.plus(self.differencePoint(distance))
            cell.update(ratio, open: true)
        }
    }
    
    func updateClose() {
        update(0, duration: closeDuration) { cell, i, ratio in
            let distance = (cell.frame.height * 0.5 + CGFloat(i + 1) * cell.frame.height * 1.5) * (1 - ratio)
            cell.center = self.center.plus(self.differencePoint(distance))
            cell.update(ratio, open: false)
        }
    }
    
    func differencePoint(_ distance: CGFloat) -> CGPoint {
        switch animateStyle {
        case .up:
            return CGPoint(x: 0, y: -distance)
        case .right:
            return CGPoint(x: distance, y: 0)
        case .left:
            return CGPoint(x: -distance, y: 0)
        case .down:
            return CGPoint(x: 0, y: distance)
        }
    }
    
    func stop() {
        openingCells = []
        keyDuration = 0
        displayLink?.invalidate()
    }
    
    func easeInEaseOut(_ t: CGFloat) -> CGFloat {
        if t >= 1.0 {
            return 1.0
        }
        if t < 0 {
            return 0
        }
        return -1 * t * (t - 2)
    }
    
    @objc func didDisplayRefresh(_ displayLink: CADisplayLink) {
        if opening {
            keyDuration += CGFloat(displayLink.duration)
            updateOpen()
        } else {
            keyDuration += CGFloat(displayLink.duration)
            updateClose()
        }
    }
}

class LiquidFloatingCell: LiquittableCircle {
    
    let internalRatio: CGFloat = 0.75
    
    var responsible = true
    var imageView = UIImageView()
    weak var actionButton:SSLiquidButton?
    
    // for implement responsible color
    fileprivate var originalColor: UIColor
    
    override var frame: CGRect {
        didSet {
            resizeSubviews()
        }
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor, icon: UIImage) {
        self.originalColor = color
        super.init(center: center, radius: radius, color: color)
        setup(icon)
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor, view: UIView) {
        self.originalColor = color
        super.init(center: center, radius: radius, color: color)
        setupView(view)
    }
    
    init(icon: UIImage) {
        self.originalColor = UIColor.clear
        super.init()
        setup(icon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ image: UIImage, tintColor: UIColor = UIColor.white) {
        imageView.image = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageView.tintColor = tintColor
        setupView(imageView)
    }
    
    func setupView(_ view: UIView) {
        isUserInteractionEnabled = false
        addSubview(view)
        resizeSubviews()
    }
    
    fileprivate func resizeSubviews() {
        let size = CGSize(width: frame.width * 0.5, height: frame.height * 0.5)
        imageView.frame = CGRect(x: frame.width - frame.width * internalRatio, y: frame.height - frame.height * internalRatio, width: size.width, height: size.height)
    }
    
    func update(_ key: CGFloat, open: Bool) {
        for subview in self.subviews {
            let ratio = max(2 * (key * key - 0.5), 0)
            subview.alpha = open ? ratio : -ratio
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if responsible {
            originalColor = color
            color = originalColor.white(0.5)
            setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if responsible {
            color = originalColor
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        color = originalColor
        actionButton?.didTappedCell(self)
    }
    
}


class LiquittableCircle: UIView {
    
    var points: [CGPoint] = []
    var radius: CGFloat {
        didSet {
            self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
            setup()
        }
    }
    var color: UIColor = UIColor.red {
        didSet {
            setup()
        }
    }
    
    override var center: CGPoint {
        didSet {
            self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
            setup()
        }
    }
    
    let circleLayer = CAShapeLayer()
    init(center: CGPoint, radius: CGFloat, color: UIColor) {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        self.radius = radius
        self.color = color
        super.init(frame: frame)
        setup()
        self.layer.addSublayer(circleLayer)
        self.isOpaque = false
    }
    
    init() {
        self.radius = 0
        super.init(frame: CGRect.zero)
        setup()
        self.layer.addSublayer(circleLayer)
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        drawCircle()
    }
    
    func drawCircle() {
        let bezierPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2)))
        draw(bezierPath)
    }
    
    @discardableResult
    func draw(_ path: UIBezierPath) -> CAShapeLayer {
        circleLayer.lineWidth = 3.0
        circleLayer.fillColor = self.color.cgColor
        circleLayer.path = path.cgPath
        return circleLayer
    }
    
    func circlePoint(_ rad: CGFloat) -> CGPoint {
        return CGMath.circlePoint(center, radius: radius, rad: rad)
    }
    
    override func draw(_ rect: CGRect) {
        drawCircle()
    }
}


class SimpleCircleLiquidEngine {
    
    let radiusThresh: CGFloat
    private var layer: CALayer = CAShapeLayer()
    
    var viscosity: CGFloat = 0.65
    var color = UIColor.blue
    var angleOpen: CGFloat = 1.0
    
    let ConnectThresh: CGFloat = 0.3
    var angleThresh: CGFloat   = 0.5
    
    init(radiusThresh: CGFloat, angleThresh: CGFloat) {
        self.radiusThresh = radiusThresh
        self.angleThresh = angleThresh
    }
    
    @discardableResult
    func push(circle: LiquittableCircle, other: LiquittableCircle) -> [LiquittableCircle] {
        if let paths = generateConnectedPath(circle: circle, other: other) {
            let layers = paths.map(self.constructLayer)
            layers.each(layer.addSublayer)
            return [circle, other]
        }
        return []
    }
    
    func draw(parent: UIView) {
        parent.layer.addSublayer(layer)
    }
    
    func clear() {
        layer.removeFromSuperlayer()
        layer.sublayers?.each{ $0.removeFromSuperlayer() }
        layer = CAShapeLayer()
    }
    
    func constructLayer(path: UIBezierPath) -> CALayer {
        let pathBounds = path.cgPath.boundingBox;
        
        let shape = CAShapeLayer()
        shape.fillColor = self.color.cgColor
        shape.path = path.cgPath
        shape.frame = CGRect(x: 0, y: 0, width: pathBounds.width, height: pathBounds.height)
        
        return shape
    }
    
    private func circleConnectedPoint(circle: LiquittableCircle, other: LiquittableCircle, angle: CGFloat) -> (CGPoint, CGPoint) {
        let vec = other.center.minus(circle.center)
        let radian = atan2(vec.y, vec.x)
        let p1 = circle.circlePoint(radian + angle)
        let p2 = circle.circlePoint(radian - angle)
        return (p1, p2)
    }
    
    private func circleConnectedPoint(circle: LiquittableCircle, other: LiquittableCircle) -> (CGPoint, CGPoint) {
        var ratio = circleRatio(circle: circle, other: other)
        ratio = (ratio + ConnectThresh) / (1.0 + ConnectThresh)
        let angle = .pi * 0.5 * angleOpen * ratio
        return circleConnectedPoint(circle: circle, other: other, angle: angle)
    }
    
    func generateConnectedPath(circle: LiquittableCircle, other: LiquittableCircle) -> [UIBezierPath]? {
        if isConnected(circle: circle, other: other) {
            let ratio = circleRatio(circle: circle, other: other)
            switch ratio {
            case angleThresh...1.0:
                if let path = normalPath(circle: circle, other: other) {
                    return [path]
                }
                return nil
            case 0.0..<angleThresh:
                return splitPath(circle: circle, other: other, ratio: ratio)
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func normalPath(circle: LiquittableCircle, other: LiquittableCircle) -> UIBezierPath? {
        let (p1, p2) = circleConnectedPoint(circle: circle, other: other)
        let (p3, p4) = circleConnectedPoint(circle: other, other: circle)
        if let crossed = CGPoint.intersection(p1, to: p3, from2: p2, to2: p4) {
            return withBezier { path in
                let r = self.circleRatio(circle: circle, other: other)
                path.move(to: p1)
                let r1 = p2.mid(p3)
                let r2 = p1.mid(p4)
                let rate = (1 - r) / (1 - self.angleThresh) * self.viscosity
                let mul = r1.mid(crossed).split(r2, ratio: rate)
                let mul2 = r2.mid(crossed).split(r1, ratio: rate)
                path.addQuadCurve(to: p4, controlPoint: mul)
                path.addLine(to: p3)
                path.addQuadCurve(to: p2, controlPoint: mul2)
            }
        }
        return nil
    }
    
    private func splitPath(circle: LiquittableCircle, other: LiquittableCircle, ratio: CGFloat) -> [UIBezierPath] {
        let (p1, p2) = circleConnectedPoint(circle: circle, other: other, angle: CGMath.degToRad(60))
        let (p3, p4) = circleConnectedPoint(circle: other, other: circle, angle: CGMath.degToRad(60))
        
        if let crossed = CGPoint.intersection(p1, to: p3, from2: p2, to2: p4) {
            let (d1, _) = self.circleConnectedPoint(circle: circle, other: other, angle: 0)
            let (d2, _) = self.circleConnectedPoint(circle: other, other: circle, angle: 0)
            let r = (ratio - ConnectThresh) / (angleThresh - ConnectThresh)
            
            let a1 = d2.split(crossed, ratio: (r * r))
            let part = withBezier { path in
                path.move(to: p1)
                path.addQuadCurve(to: p2, controlPoint: a1)
            }
            let a2 = d1.split(crossed, ratio: (r * r))
            let part2 = withBezier { path in
                path.move(to: p3)
                path.addQuadCurve(to: p4, controlPoint: a2)
            }
            return [part, part2]
        }
        return []
    }
    
    private func circleRatio(circle: LiquittableCircle, other: LiquittableCircle) -> CGFloat {
        let distance = other.center.minus(circle.center).length()
        let ratio = 1.0 - (distance - radiusThresh) / (circle.radius + other.radius + radiusThresh)
        return min(max(ratio, 0.0), 1.0)
    }
    
    func isConnected(circle: LiquittableCircle, other: LiquittableCircle) -> Bool {
        let distance = circle.center.minus(other.center).length()
        return distance - circle.radius - other.radius < radiusThresh
    }
    
    
}


func withBezier(_ f: (UIBezierPath) -> ()) -> UIBezierPath {
    let bezierPath = UIBezierPath()
    f(bezierPath)
    bezierPath.close()
    return bezierPath
}

private struct CGMath {
    
    static func radToDeg(_ rad: CGFloat) -> CGFloat {
        return rad * 180 / .pi
    }
    
    static func degToRad(_ deg: CGFloat) -> CGFloat {
        return deg * .pi / 180
    }
    
    static func circlePoint(_ center: CGPoint, radius: CGFloat, rad: CGFloat) -> CGPoint {
        let x = center.x + radius * cos(rad)
        let y = center.y + radius * sin(rad)
        return CGPoint(x: x, y: y)
    }
    
    static func linSpace(_ from: CGFloat, to: CGFloat, n: Int) -> [CGFloat] {
        var values: [CGFloat] = []
        for i in 0 ..< n {
            values.append((to - from) * CGFloat(i) / CGFloat(n - 1) + from)
        }
        return values
    }
}


private extension CGPoint {

    func plus(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    
    func minus(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - point.x, y: self.y - point.y)
    }
    
    func minusX(_ dx: CGFloat) -> CGPoint {
        return CGPoint(x: self.x - dx, y: self.y)
    }
    
    func minusY(_ dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y - dy)
    }
    
    func mul(_ rhs: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * rhs, y: self.y * rhs)
    }
    
    func div(_ rhs: CGFloat) -> CGPoint {
        return CGPoint(x: self.x / rhs, y: self.y / rhs)
    }
    
    func length() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    func normalize() -> CGPoint {
        return self.div(self.length())
    }
    
    func dot(_ point: CGPoint) -> CGFloat {
        return self.x * point.x + self.y * point.y
    }
    
    func cross(_ point: CGPoint) -> CGFloat {
        return self.x * point.y - self.y * point.x
    }
    
    func split(_ point: CGPoint, ratio: CGFloat) -> CGPoint {
        return self.mul(ratio).plus(point.mul(1.0 - ratio))
    }
    
    func mid(_ point: CGPoint) -> CGPoint {
        return split(point, ratio: 0.5)
    }
    
    static func intersection(_ from: CGPoint, to: CGPoint, from2: CGPoint, to2: CGPoint) -> CGPoint? {
        let ac = CGPoint(x: to.x - from.x, y: to.y - from.y)
        let bd = CGPoint(x: to2.x - from2.x, y: to2.y - from2.y)
        let ab = CGPoint(x: from2.x - from.x, y: from2.y - from.y)
        let bc = CGPoint(x: to.x - from2.x, y: to.y - from2.y)
        
        let area = bd.cross(ab)
        let area2 = bd.cross(bc)
        
        if abs(area + area2) >= 0.1 {
            let ratio = area / (area + area2)
            return CGPoint(x: from.x + ratio * ac.x, y: from.y + ratio * ac.y)
        }
        return nil
    }
}

private extension CGRect {
    var rightBottom: CGPoint {
        get {
            return CGPoint(x: origin.x + width, y: origin.y + height)
        }
    }
    var center: CGPoint {
        get {
            return origin.plus(rightBottom).mul(0.5)
        }
    }
}
