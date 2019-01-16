//
//  SSBubbleSlider.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/10.
//  Copyright © 2018年 y2ss. All rights reserved.
//

class SSBubbleSlider: UIControl {

    private var _value: CGFloat = 0
    var value: CGFloat {
        set {
            if _value != newValue {
                if newValue < minimumValue {
                    _value = minimumValue
                } else if newValue > maximumValue {
                    _value = maximumValue
                } else {
                    _value = newValue
                }
                sendActions(for: .valueChanged)
                self.rawValue = newValue
                thumbView.bubble.value = newValue
                thumbView.changeThumbShape(rawValue, animated: true)
            }
        }
        get {
            return _value
        }
    }
    var maximumValue: CGFloat = 100 {
        didSet {
            if minimumValue > maximumValue {
                let min = minimumValue
                minimumValue = maximumValue
                maximumValue = min
            }
            thumbView.bubble.maxValue = maximumValue
            if value > maximumValue {
                value = maximumValue
            } else {
                updateIntentsity(true)
            }
            tickMarksView.maximunValue = maximumValue
        }
    }
    var minimumValue: CGFloat = 0 {
        didSet {
            if minimumValue > maximumValue {
                let min = minimumValue
                minimumValue = maximumValue
                maximumValue = min
                thumbView.bubble.maxValue = maximumValue
            }
            if value < minimumValue {
                value = minimumValue
            } else {
                updateIntentsity(true)
                thumbView.changeThumbShape(rawValue, animated: true)
            }
            tickMarksView.minimunValue = minimumValue
        }
    }
    var thumbOnColor: UIColor = UIColor.init(hex: 0x3F51B5) {
        didSet {
            updateColors()
        }
    }
    var trackOnColor: UIColor = UIColor.init(hex: 0x3F51B5) {
        didSet {
            updateColors()
        }
    }
    var thumbOffColor: UIColor = UIColor.gray {
        didSet {
            updateColors()
        }
    }
    var trackOffColor: UIColor = UIColor.gray {
        didSet {
            updateColors()
        }
    }
    var disabledColor: UIColor = UIColor.init(hex: 0xe7e7e7) {
        didSet {
            updateColors()
        }
    }
    var tickMarksColor: UIColor = UIColor.SSStyle {
        didSet {
            tickMarksView.tickColor = tickMarksColor
        }
    }
    var leftImage: UIImage? {
        set {
            leftIcon.image = newValue
            layoutContent()
        }
        get {
            return leftIcon.image
        }
    }
    var rightImage: UIImage? {
        set {
            rightIcon.image = newValue
            layoutContent()
        }
        get {
            return rightIcon.image
        }
    }
    var step: CGFloat = 0 {
        didSet {
            tickMarksView.step = step
        }
    }
    var isEnabledValueLabel: Bool = true {
        didSet {
            thumbView.isEnableBubble = isEnabledValueLabel
        }
    }
    var precisoin: Int = 0 {
        didSet {
            thumbView.bubble.precision = precisoin
        }
    }
    override var isEnabled: Bool {
        set {
            if isEnabled != newValue {
                super.isEnabled = newValue
                if newValue {
                    trackView.backgroundColor = trackOffColor
                    thumbView.enable { flag in
                        if flag {
                            self.updateTrackOverlayLayer()
                        }
                    }
                    UIView.animate(withDuration: SSBubbleSliderThumbView.AnimationDuration) {
                        self.intensityView.alpha = 1
                        self.tickMarksView.alpha = 1
                    }
                } else {
                    UIView.animate(withDuration: SSBubbleSliderThumbView.AnimationDuration) {
                        self.intensityView.alpha = 0
                        self.tickMarksView.alpha = 0
                    }
                    trackView.backgroundColor = disabledColor
                    thumbView.diabled(nil)
                    updateTrackOverlayLayer()
                }
                thumbView.changeThumbShape(rawValue, animated: true)
            }
        }
        get {
            return super.isEnabled
        }
    }
    
    private let TrackPadding: CGFloat = 16
    private let TrackPaddingWithLabel: CGFloat = 24
    private let TrackWidth: CGFloat = 2
    private let TrackBackground = UIColor.gray
    private let DisabledColor = UIColor.gray
    
    private lazy var intensityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var trackView: UIView = {
        let view = UIView()
        view.addSubview(intensityView)
        view.addSubview(tickMarksView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var tickMarksView: SSBubbleSliderTickMarksView = {
        let view = SSBubbleSliderTickMarksView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tickColor = tickMarksColor
        return view
    }()
    private lazy var thumbView: SSBubbleSliderThumbView = {
        let view = SSBubbleSliderThumbView.init(slider: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var trackOverlayLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let path = createTrackLayerPath()
        layer.path = path.cgPath
        layer.fillRule = .evenOdd
        return layer
    }()
    private lazy var leftIcon: SSBubbleSliderIcno = {
        let view = SSBubbleSliderIcno()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var rightIcon: SSBubbleSliderIcno = {
        let view = SSBubbleSliderIcno()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var placeHolder: UIView = {
        let view = UIView()
        view.addSubview(trackView)
        view.addSubview(leftIcon)
        view.addSubview(rightIcon)
        view.addSubview(thumbView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var viewDicts: [String: Any] = {
        return ["trackView": trackView,
                "intensityView": intensityView,
                "tickMarksView": tickMarksView,
                "thumbView": thumbView,
                "leftIcon": leftIcon,
                "rightIcon": rightIcon,
                "placeHolder": placeHolder]
    }()
    private lazy var metricsDicts: [String: CGFloat] = {
       return [
        "trackPadding": TrackPadding,
        "labeledPadding": TrackPaddingWithLabel,
        "trackWidth": TrackWidth
        ]
    }()
    
    private var intensityWidthConstraint: NSLayoutConstraint!
    private var thumbCenterXConstraint: NSLayoutConstraint!
    private var constaintsArr = [NSLayoutConstraint]()
    
    private var rawValue: CGFloat = 0 {
        didSet {
            updateIntentsity(true)
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addSubview(placeHolder)
        trackView.layer.mask = trackOverlayLayer
        setupConstraints()
        thumbView.bubble.value = value
        trackView.addObserver(self, forKeyPath: "bounds", options: .init(rawValue: 0), context: nil)
        layoutContent()
        updateColors()
    }
    
    private func setupConstraints() {
        placeHolder.do {
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=trackPadding)-[trackView(trackWidth)]-(>=trackPadding)-|", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts))
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[leftIcon]-(>=0)-|", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts))
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[rightIcon]-(>=0)-|", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts))
            $0.addConstraint(NSLayoutConstraint.init(item: leftIcon, attribute: .centerY, relatedBy: .equal, toItem: trackView, attribute: .centerY, multiplier: 1, constant: 0))
            $0.addConstraint(NSLayoutConstraint.init(item: rightIcon, attribute: .centerY, relatedBy: .equal, toItem: trackView, attribute: .centerY, multiplier: 1, constant: 0))
            $0.addConstraint(NSLayoutConstraint.init(item: thumbView, attribute: .top, relatedBy: .equal, toItem: placeHolder, attribute: .top, multiplier: 1, constant: 0))
            $0.addConstraint(NSLayoutConstraint.init(item: trackView, attribute: .centerY, relatedBy: .equal, toItem: thumbView.node, attribute: .centerY, multiplier: 1, constant: 0))
            let c = NSLayoutConstraint.init(item: thumbView, attribute: .centerX, relatedBy: .equal, toItem: trackView, attribute: .left, multiplier: 1, constant: 0)
            $0.addConstraint(c)
            self.thumbCenterXConstraint = c
        }

        trackView.do {
            $0.addConstraint(NSLayoutConstraint.init(item: intensityView, attribute: .leading, relatedBy: .equal, toItem: trackView, attribute: .leading, multiplier: 1, constant: 0))
            $0.addConstraint(NSLayoutConstraint.init(item: intensityView, attribute: .top, relatedBy: .equal, toItem: trackView, attribute: .top, multiplier: 1, constant: 0))
            $0.addConstraint(NSLayoutConstraint.init(item: intensityView, attribute: .bottom, relatedBy: .equal, toItem: trackView, attribute: .bottom, multiplier: 1, constant: 0))
            let w = NSLayoutConstraint.init(item: intensityView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 0)
            $0.addConstraint(w)
            self.intensityWidthConstraint = w
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tickMarksView]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewDicts))
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tickMarksView]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewDicts))
        }
        
        self.do {
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[placeHolder]-0@250-|", options: .init(rawValue: 0), metrics: nil, views: viewDicts))
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[placeHolder]-(0)-|", options: .init(rawValue: 0), metrics: nil, views: viewDicts))
        }
        layoutIfNeeded()
    }
    
    private func layoutContent() {
        if constaintsArr.count != 0 {
            self.removeConstraints(constaintsArr)
        }
        var new = [NSLayoutConstraint]()
        if leftIcon.isHasContent {
            leftIcon.isHidden = false
            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[leftIcon]-trackPadding-[trackView]", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts)
            placeHolder.addConstraints(h)
            
            new += h
        } else {
            leftIcon.isHidden = true
            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-trackPadding-[trackView]", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts)
            placeHolder.addConstraints(h)
            
            new += h
        }
        
        if rightIcon.isHasContent {
            rightIcon.isHidden = false
            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:[trackView]-trackPadding-[rightIcon]-0-|", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts)
            placeHolder.addConstraints(h)
            
            new += h
        } else {
            rightIcon.isHidden = true
            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:[trackView]-trackPadding-|", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts)
            placeHolder.addConstraints(h)
            
            new += h
        }
        constaintsArr = new
    }
    
    private func snapsThumbToTicks() {
        let value = tickMarksView.nearestTickValue(from: rawValue)
        self.rawValue = value
        if value != self.value {
            self.value = value
        }
    }
    
    private func updateTrackOverlayLayer() {
        let path = createTrackLayerPath()
        trackOverlayLayer.path = path.cgPath
    }
    
    private func updateColors() {
        if isEnabled {
            trackView.backgroundColor = trackOffColor
            intensityView.backgroundColor = trackOnColor
        } else {
            trackView.backgroundColor = disabledColor
            intensityView.backgroundColor = disabledColor
        }
        thumbView.changeThumbShape(rawValue, animated: false)
    }
    
    private func createTrackLayerPath() -> UIBezierPath {
        let path = UIBezierPath.init(rect: CGRect.init(x: -5, y: 0, width: trackView.width + 10, height: trackView.height))
        if !isEnabled {
            var thumbRadius: CGFloat = 0
            switch state {
            case .normal:
                thumbRadius = SSBubbleSliderThumbView.ThumbRadius
                break
            case .focused:
                thumbRadius = SSBubbleSliderThumbView.ThumbForcusedRadius
                break
            case .disabled:
                thumbRadius = SSBubbleSliderThumbView.ThumbDisabledRadius
                break
            default:break
            }
            thumbRadius += TrackWidth
            let circlePath = UIBezierPath.init(rect: CGRect.init(x: thumbCenterXConstraint.constant - thumbRadius, y: 0, width: thumbRadius * 2, height: trackView.height))
            path.append(circlePath)
            path.usesEvenOddFillRule = true
        }
        return path
    }
    
    private func updateIntentsity(_ animated: Bool) {
        var intentsity: CGFloat
        if value == minimumValue {
            intentsity = 0
        } else {
            intentsity = (value - minimumValue) / (maximumValue - minimumValue)
        }
        
        intensityWidthConstraint.constant = intentsity * trackView.width
        thumbCenterXConstraint.constant = intensityWidthConstraint.constant
        if animated && step > 0 {
            UIView.animate(withDuration: SSBubbleSliderThumbView.AnimationDuration) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: trackView) {
            calculateValue(from: point)
            thumbView.focused(nil)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: trackView) {
            calculateValue(from: point)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        thumbView.lostFocused(nil)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        thumbView.lostFocused(nil)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let location = placeHolder.convert(point, from: self)
        return placeHolder.bounds.contains(location)
    }
    
    private func calculateValue(from touchedPoint: CGPoint) {
        var intentsity = touchedPoint.x / trackView.width
        if intentsity < 0 {
            intentsity = 0
        } else if intentsity > 1 {
            intentsity = 1
        }
        self.rawValue = (maximumValue - minimumValue) * intentsity + minimumValue
        if step <= 0 {
            self.value = rawValue
        } else {
            snapsThumbToTicks()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UIView, let kp = keyPath {
            if obj == trackView && kp == "bounds" {
                updateIntentsity(false)
                updateTrackOverlayLayer()
            }
        }
    }
    
    deinit {
        trackView.removeObserver(self, forKeyPath: "bounds")
    }
}

