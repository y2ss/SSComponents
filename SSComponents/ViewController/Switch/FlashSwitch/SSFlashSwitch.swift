//
//  SSFlashSwitch.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/10.
//  Copyright © 2018年 y2ss. All rights reserved.
//

private let ControlWidth: CGFloat = 40
private let ControlHeight: CGFloat = 20
private let TrackWidth: CGFloat = 34
private let TrackHeight: CGFloat = 12
private let TrackCornerRadius: CGFloat = 6
private let ThumbRadius: CGFloat = 10
private let RippleAlpha: Float = 0.1
private let AnimationKey = "moveAnimation"
private let AnimationDuration = 1

class SSFlashSwitch: UIControl {

    var isOn: Bool {
        set {
            switchLayer.isOn = newValue
        }
        get {
            return switchLayer.isOn
        }
    }
    override var isEnabled: Bool {
        set {
            super.isEnabled = newValue
            switchLayer.isEnabled = newValue
        }
        get {
            return switchLayer.isEnabled
        }
    }
    var thumbOnColor: UIColor = UIColor(hex: 0x3F51B5) {
        didSet {
            switchLayer.thumbOnColor = thumbOnColor
        }
    }
    var trackOnColor: UIColor = UIColor(hex: 0x3F51B5).alpha(0.6) {
        didSet {
            switchLayer.trackOnColor = trackOnColor
        }
    }
    var thumbOffColor: UIColor = UIColor(hex: 0xFAFAFA) {
        didSet {
            switchLayer.thumbOffColor = thumbOffColor
        }
    }
    var trackOffColor: UIColor = UIColor(hex: 0x3F51B5).alpha(0.2) {
        didSet {
            switchLayer.trackOffColor = trackOffColor
        }
    }
    var thumbDisabledColor: UIColor = UIColor(hex: 0xBDBDBD) {
        didSet {
            switchLayer.thumbDisableColor = thumbDisabledColor
        }
    }
    var trackDisabledColor: UIColor = UIColor(hex: 0x00001E) {
        didSet {
            switchLayer.trackDisableColor = trackDisabledColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    private lazy var switchLayer: SwitchLayer = {
        let layer = SwitchLayer.init(holder: self)
        layer.onColorPalette = ColorPalette.init(thumbColor: UIColor(hex: 0x3F51B5), trackColor: UIColor(hex: 0x3F51B5).alpha(0.6))
        layer.offColorPalette = ColorPalette.init(thumbColor: UIColor(hex: 0xFAFAFA), trackColor: UIColor(hex: 0x3F51B5).alpha(0.2))
        layer.disableColorPalette = ColorPalette.init(thumbColor: UIColor(hex: 0xBDBDBD), trackColor: UIColor(hex: 0x00001E))
        return layer
    }()
    
    private func setup() {
        self.layer.addSublayer(switchLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        switchLayer.updateSuperBounds(self.bounds)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let point = touches.first?.location(in: self) {
            switchLayer.onTouchDown(self.layer.convert(point, to: switchLayer))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let point  = touches.first?.location(in: self) {
            switchLayer.onTouchUp(self.layer.convert(point, to: switchLayer))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if let point = touches.first?.location(in: self) {
            switchLayer.onTouchUp(self.layer.convert(point, to: switchLayer))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let point = touches.first?.location(in: self) {
            switchLayer.onTouchMoved(self.layer.convert(point, to: switchLayer))
        }
    }
}

private class SwitchLayer: CALayer {
    
    var isOn: Bool = false {
        didSet {
            switchState(isOn)
            holder?.sendActions(for: .valueChanged)
        }
    }
    var isEnabled: Bool = true {
        didSet {
            updateColor()
        }
    }
    weak var holder: UIControl?
    
    private var trackLayer = CAShapeLayer()
    private var thumbHolder = CALayer()
    private var thumbLayer = CAShapeLayer()
    private var thumbBackground = CALayer()
    private lazy var rippleLayer: SSRippleLayer = {
       let layer = SSRippleLayer.init(superLayer: thumbBackground)
        layer.rippleScaleRatio = 1.7
        layer.isEnableMask = false
        layer.isEnableElevation = false
        return layer
    }()
    private lazy var shadowLayer: SSRippleLayer = {
        let layer = SSRippleLayer.init(superLayer: thumbLayer)
        layer.rippleScaleRatio = 0
        return layer
    }()
    private var isTouchInside: Bool = false
    private var touchDownLocation: CGPoint = .zero
    private var thumbFrame: CGRect = .zero
    
    var onColorPalette = ColorPalette() {
        didSet {
            updateColor()
        }
    }
    var offColorPalette = ColorPalette() {
        didSet {
            updateColor()
        }
    }
    var disableColorPalette = ColorPalette() {
        didSet {
            updateColor()
        }
    }
    var thumbOnColor: UIColor {
        set {
            onColorPalette.thumbColor = newValue
            updateColor()
        }
        get {
            return onColorPalette.thumbColor
        }
    }
    var trackOnColor: UIColor {
        set {
            onColorPalette.trackColor = newValue
            updateColor()
        }
        get {
            return onColorPalette.trackColor
        }
    }
    var thumbOffColor: UIColor  {
        set {
            offColorPalette.thumbColor = newValue
            updateColor()
        }
        get {
            return offColorPalette.thumbColor
        }
    }
    var trackOffColor: UIColor {
        set {
            offColorPalette.trackColor = newValue
            updateColor()
        }
        get {
            return offColorPalette.trackColor
        }
    }
    var thumbDisableColor: UIColor {
        set {
            disableColorPalette.thumbColor = newValue
            updateColor()
        }
        get {
            return disableColorPalette.thumbColor
        }
    }
    var trackDisableColor: UIColor {
        set {
            disableColorPalette.trackColor = newValue
            updateColor()
        }
        get {
            return disableColorPalette.trackColor
        }
    }
    
    init(holder: UIControl) {
        super.init()
        self.holder = holder
        initlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        initlayer()
    }
    
    private func initlayer() {
        thumbHolder.addSublayer(thumbBackground)
        thumbHolder.addSublayer(thumbLayer)
        self.addSublayer(trackLayer)
        self.addSublayer(thumbHolder)
    }

    private func updateTrackLayer() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let subX = center.x - TrackWidth * 0.5
        let subY = center.y - TrackHeight * 0.5
        trackLayer.frame = CGRect(x: subX, y: subY, width: TrackWidth, height: TrackHeight)
        let path = UIBezierPath(roundedRect: trackLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize.init(width: TrackCornerRadius, height: TrackCornerRadius))
        trackLayer.path = path.cgPath
    }
    
    func updateSuperBounds(_ bounds: CGRect) {
        let center = CGPoint.init(x: bounds.midX, y: bounds.midY)
        let subX = center.x - ControlWidth * 0.5
        let subY = center.y - ControlHeight * 0.5
        self.frame = CGRect.init(x: subX, y: subY, width: ControlWidth, height: ControlHeight)
        updateTrackLayer()
        updateThumbLayer()
    }
    
    private func updateColor() {
        if !isEnabled {
            trackLayer.fillColor = disableColorPalette.trackColor.cgColor
            thumbLayer.fillColor = disableColorPalette.thumbColor.cgColor
        } else if isOn {
            trackLayer.fillColor = onColorPalette.trackColor.cgColor
            thumbLayer.fillColor = onColorPalette.thumbColor.cgColor
            rippleLayer.setEffectColor(with: onColorPalette.thumbColor, rippleAlpha: RippleAlpha, backgroundAlpha: RippleAlpha)
        } else {
            trackLayer.fillColor = offColorPalette.trackColor.cgColor
            thumbLayer.fillColor = offColorPalette.thumbColor.cgColor
            rippleLayer.setEffectColor(with: offColorPalette.thumbColor, rippleAlpha: RippleAlpha, backgroundAlpha: RippleAlpha)
        }
    }
    
    private func updateThumbLayer() {
        var subX: CGFloat = 0
        if isOn {
            subX = CGFloat(ControlWidth - ThumbRadius * 2)
        }
        thumbFrame = CGRect.init(x: subX, y: 0, width: ThumbRadius * 2, height: ThumbRadius * 2)
        thumbHolder.frame = thumbFrame
        thumbBackground.frame = thumbHolder.bounds
        thumbLayer.frame = thumbHolder.bounds
        let path = UIBezierPath(ovalIn: thumbLayer.bounds)
        thumbLayer.path = path.cgPath
    }

    private func switchState(_ on: Bool) {
        if on {
            thumbFrame = CGRect.init(x: ControlWidth - ThumbRadius * 2, y: 0, width: ThumbRadius * 2, height: ThumbRadius * 2)
        } else {
            thumbFrame = CGRect.init(x: 0, y: 0, width: ThumbRadius * 2, height: ThumbRadius * 2)
        }
        thumbHolder.frame = thumbFrame
        updateColor()
    }
    
    func onTouchUp(_ touchLocation: CGPoint) {
        if isEnabled {
            rippleLayer.stopEffects()
            shadowLayer.stopEffects()
            if !isTouchInside || checkPoint(touchDownLocation, touchLocation) {
                isOn = !isOn
            } else {
                if isOn && touchLocation.x < touchDownLocation.x {
                    isOn = false
                } else if !isOn && touchLocation.x > touchDownLocation.x {
                    isOn = true
                }
            }
            isTouchInside = false
        }
    }
    
    private var checkPoint: (CGPoint, CGPoint) -> Bool {
        return {
            fabs(Double($0.x - $1.x)) <= 5 && fabs(Double($0.y - $1.y)) <= 5
        }
    }
    
    func onTouchDown(_ touchLocation: CGPoint) {
        if isEnabled {
            rippleLayer.startEffectsAtLocation(self.convert(touchLocation, to: thumbBackground))
            shadowLayer.startEffectsAtLocation(self.convert(touchLocation, to: thumbLayer))
            isTouchInside = contains(touchLocation)
            touchDownLocation = touchLocation
        }
    }
    
    func onTouchMoved(_ moveLocation: CGPoint) {
        if isEnabled {
            if isTouchInside {
                var x = thumbFrame.x + (moveLocation.x - touchDownLocation.x)
                if x < 0 {
                    x = 0
                } else if x > bounds.width - thumbFrame.width {
                    x = bounds.width - thumbFrame.width
                }
                let frame = CGRect.init(x: x, y: thumbFrame.y, width: thumbFrame.width, height: thumbFrame.height)
                thumbHolder.frame = frame
            }
        }
    }
}


private struct ColorPalette {
    var thumbColor: UIColor
    var trackColor: UIColor
    
    init() {
        self.thumbColor = UIColor.clear
        self.trackColor = UIColor.clear
    }
    
    init(thumbColor: UIColor, trackColor: UIColor) {
        self.thumbColor = thumbColor
        self.trackColor = trackColor
    }
}
