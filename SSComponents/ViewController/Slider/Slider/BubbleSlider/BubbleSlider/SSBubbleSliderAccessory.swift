//
//  SSBubbleSliderAccessory.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/10.
//  Copyright © 2018年 y2ss. All rights reserved.
//

class SSBubbleSliderThumbView: UIView {
    
    typealias this = SSBubbleSliderThumbView
    
    static let ThumbRadius: CGFloat = 8
    static let ThumbDisabledRadius: CGFloat = 6
    static let ThumbForcusedRadius: CGFloat = 12
    static let AnimationDuration = 0.2
    
    private let ThumbBorderWidth: CGFloat = 2
    private let HideThumbAnimationKey = "hideThumbAnim"
    private let ShowThumbAnimationKey = "showThumbAnim"
    private let HideBubbleAnimationKey = "hideBubbleAnim"
    private let ShowBubbleAnimationKey = "showBubbleAnim"
    
    enum ThumbState: Int {
        case normal
        case focused
        case disabled
    }

    var bubble = SSBubbleSliderLabel()
    var node = UIView()
    var state: ThumbState = .normal
    weak var slider: SSBubbleSlider?
    var isEnableBubble: Bool = true {
        didSet {
            if isEnableBubble {
                if bubble.superview == nil {
                    self.addSubview(bubble)
                    self.bringSubviewToFront(node)
                    self.do {
                        $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[bubble]-(bubblePaddingBottom)-|", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts))
                        $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[bubble]-(>=0)-|", options: .init(rawValue: 0), metrics: metricsDicts, views: viewDicts))
                        
                        $0.addConstraint(NSLayoutConstraint.init(item: bubble, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
                    }
                    bubble.isHidden = true
                }
            } else {
                bubble.removeFromSuperview()
            }
        }
    }
    
    private var nodeWidthConstraint: NSLayoutConstraint!
    private lazy var viewDicts: [String: Any] = {
        return ["bubble": bubble, "node": node]
    }()
    
    private lazy var metricsDicts: [String: Any] = {
        return ["bubblePaddingBottom": this.ThumbRadius + this.ThumbForcusedRadius]
    }()
    
    init(slider: SSBubbleSlider) {
        super.init(frame: CGRect.zero)
        self.slider = slider
        setup()
    }
    
    init(frame: CGRect, slider: SSBubbleSlider) {
        super.init(frame: frame)
        self.slider = slider
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        node.layer.cornerRadius = this.ThumbRadius
        self.addSubview(node)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        node.translatesAutoresizingMaskIntoConstraints = false
        
        self.do {
            $0.addConstraint(NSLayoutConstraint.init(item: node, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -this.ThumbForcusedRadius))
            $0.addConstraint(NSLayoutConstraint.init(item: node, attribute: .centerY, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1, constant: this.ThumbForcusedRadius))
            $0.addConstraint(NSLayoutConstraint.init(item: node, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
             let c4 = NSLayoutConstraint.init(item: node, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: this.ThumbRadius * 2)
            $0.addConstraint(c4)
            nodeWidthConstraint = c4
            $0.addConstraint(NSLayoutConstraint.init(item: node, attribute: .height, relatedBy: .equal, toItem: node, attribute: .width, multiplier: 1, constant: 0))
        }
    }
    
    func focused(_ completion: ((Bool) -> Void)?) {
        state = .focused
        self.nodeWidthConstraint.constant = this.ThumbForcusedRadius * 2
        UIView.animate(withDuration: this.AnimationDuration, animations: {
            
            self.layoutIfNeeded()
        }, completion: completion)
        
        let anim = CABasicAnimation.init(keyPath: "cornerRadius")
        anim.timingFunction = CAMediaTimingFunction.init(name: .linear)
        anim.fromValue = node.layer.cornerRadius
        anim.toValue = this.ThumbForcusedRadius
        anim.duration = this.AnimationDuration
        node.layer.cornerRadius = CGFloat(this.ThumbForcusedRadius)
        node.layer.add(anim, forKey: "cornerRadius")
        
        if isEnableBubble {
            showBubble()
            hideNode()
        }
    }
    
    func lostFocused(_ completion: ((Bool) -> Void)?) {
        state = .normal
        self.nodeWidthConstraint.constant = this.ThumbRadius * 2
        UIView.animate(withDuration: this.AnimationDuration, animations: {
            self.layoutIfNeeded()
        }, completion: completion)
        
        let anim = CABasicAnimation.init(keyPath: "cornerRadius")
        anim.timingFunction = CAMediaTimingFunction.init(name: .linear)
        anim.fromValue = node.layer.cornerRadius
        anim.toValue = this.ThumbRadius
        anim.duration = this.AnimationDuration
        node.layer.cornerRadius = CGFloat(this.ThumbRadius)
        node.layer.add(anim, forKey: "cornerRadius")
        if isEnableBubble {
            hideBubble()
            showNode()
        }
    }
    
    func enable(_ completion: ((Bool) -> Void)?) {
        state = .normal
        UIView.animate(withDuration: this.AnimationDuration, animations: {
            self.nodeWidthConstraint.constant = this.ThumbRadius * 2
        }, completion: completion)
        
        let anim = CABasicAnimation(keyPath: "cornerRadius")
        anim.timingFunction = CAMediaTimingFunction.init(name: .linear)
        anim.fromValue = node.layer.cornerRadius
        anim.toValue = this.ThumbRadius
        anim.duration = this.AnimationDuration
        node.layer.cornerRadius = this.ThumbRadius
        node.layer.add(anim, forKey: "cornerRadius")
    }
    
    func diabled(_ completion: ((Bool) -> Void)?) {
        state = .disabled
        UIView.animate(withDuration: this.AnimationDuration, animations: {
            self.nodeWidthConstraint.constant = this.ThumbDisabledRadius * 2
            self.layoutIfNeeded()
        }, completion: completion)
        let anim = CABasicAnimation.init(keyPath: "cornerRadius")
        anim.timingFunction = CAMediaTimingFunction.init(name: .linear)
        anim.fromValue = node.layer.cornerRadius
        anim.toValue = this.ThumbDisabledRadius
        anim.duration = this.AnimationDuration
        node.layer.cornerRadius = this.ThumbDisabledRadius
        node.layer.add(anim, forKey: "cornerRadius")
    }
    
    func changeThumbShape(_ value: CGFloat, animated: Bool) {
        guard let slider = slider else { return }
        let changeShape = CAAnimationGroup()
 
        let thumbOnColor = slider.isEnabled ? slider.thumbOnColor : slider.disabledColor
        let thumbOffColor = slider.isEnabled ? slider.thumbOffColor : slider.disabledColor
        
        if value == slider.minimumValue {
            if animated {
                let background = CABasicAnimation.init(keyPath: "backgroundColor")
                background.fromValue = node.layer.backgroundColor
                background.toValue = UIColor.white.cgColor
                
                let width = CABasicAnimation.init(keyPath: "borderWidth")
                width.fromValue = node.layer.borderWidth
                width.toValue = ThumbBorderWidth
                
                let borderColor = CABasicAnimation.init(keyPath: "borderColor")
                borderColor.fromValue = node.layer.borderColor
                borderColor.toValue = slider.thumbOffColor.cgColor
                
                changeShape.animations = [background, width, borderColor]
            }
            node.layer.backgroundColor = UIColor.white.cgColor
            node.layer.borderWidth = ThumbBorderWidth
            node.layer.borderColor = thumbOffColor.cgColor
            changeBubbleColor(thumbOffColor, animated: animated)
        } else {
            if animated {
                let background = CABasicAnimation(keyPath: "backgroundColor")
                background.fromValue = node.layer.backgroundColor
                background.toValue = thumbOnColor.cgColor
                
                let width = CABasicAnimation.init(keyPath: "borderWidth")
                width.fromValue = node.layer.borderWidth
                width.toValue = 0
                
                let borderColor = CABasicAnimation.init(keyPath: "borderColor")
                borderColor.fromValue = node.layer.borderColor
                borderColor.toValue = UIColor.clear.cgColor
                changeShape.animations = [background, width, borderColor]
            }
            node.layer.backgroundColor = thumbOnColor.cgColor
            node.layer.borderWidth = 0
            node.layer.borderColor = UIColor.clear.cgColor
            changeBubbleColor(thumbOnColor, animated: animated)
        }
        if animated {
            changeShape.delegate = self
            changeShape.duration = this.AnimationDuration
            node.layer.add(changeShape, forKey: "changeShape")
        }
    }
    
    private func changeBubbleColor(_ color: UIColor, animated: Bool) {
        if animated {
            UIView.animate(withDuration: this.AnimationDuration) {
                self.bubble.backgroundColor = color
            }
        } else {
            bubble.backgroundColor = color
        }
    }
    
    private func showBubble() {
        bubble.layer.removeAnimation(forKey: HideBubbleAnimationKey)
        if bubble.isHidden {
            bubble.isHidden = false
            var r = bubble.layer.frame
            r.y = r.height * 0.5 + 8
            let scale = CABasicAnimation.init(keyPath: "transform.scale")
            scale.fromValue = 0
            scale.toValue = 1
            
            let move = CABasicAnimation.init(keyPath: "position")
            move.fromValue = CGPoint(x: r.midX, y: r.midY)
            move.toValue = CGPoint(x: bubble.layer.frame.midX, y: bubble.layer.frame.midY)
            
            let group = CAAnimationGroup()
            group.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            group.duration = this.AnimationDuration
            group.animations = [scale, move]
            
            bubble.layer.add(group, forKey: ShowBubbleAnimationKey)
        }
    }
    
    private func hideBubble() {
        bubble.layer.removeAnimation(forKey: ShowBubbleAnimationKey)
        var r = bubble.layer.frame
        r.y = r.height * 0.5 + 8
        let scale = CABasicAnimation.init(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 0
        
        let move = CABasicAnimation.init(keyPath: "position")
        move.fromValue = CGPoint(x: bubble.layer.frame.midX, y: bubble.layer.frame.midY)
        move.toValue = CGPoint.init(x: r.midX, y: r.midY)
        
        let group = CAAnimationGroup()
        group.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
        group.duration = this.AnimationDuration
        group.delegate = self
        group.animations = [scale, move]
        group.setValue(HideBubbleAnimationKey, forKey: "id")
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        bubble.layer.add(group, forKey: HideBubbleAnimationKey)
    }
    
    private func showNode() {
        node.layer.removeAnimation(forKey: HideThumbAnimationKey)
        node.isHidden = false
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0
        scale.toValue = 1
        scale.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
        scale.duration = this.AnimationDuration
        node.layer.add(scale, forKey: ShowThumbAnimationKey)
    }
    
    private func hideNode() {
        node.layer.removeAnimation(forKey: ShowThumbAnimationKey)
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 0
        scale.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
        scale.duration = this.AnimationDuration
        scale.delegate = self
        scale.setValue(HideThumbAnimationKey, forKey: "id")
        scale.isRemovedOnCompletion = false
        scale.fillMode = .forwards
        node.layer.add(scale, forKey: HideThumbAnimationKey)
    }
}

extension SSBubbleSliderThumbView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animKey = anim.value(forKey: "id") as? String {
            if flag {
                if animKey == HideBubbleAnimationKey {
                    bubble.isHidden = true
                } else if animKey == HideThumbAnimationKey {
                    node.isHidden = true
                }
            }
        }
    }
}

class SSBubbleSliderLabel: UIView {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    var precision: Int = 0 {
        didSet {
            calculateLabelWidth()
        }
    }
    var maxValue: CGFloat = 10 {
        didSet {
            calculateLabelWidth()
        }
    }
    
    var value: CGFloat {
        set {
            label.text = String(format: valueFormatString, newValue)
        }
        get {
            return CGFloat(Float(label.text ?? "0") ?? 0)
        }
    }
    
    var textColor: UIColor {
        set {
            label.textColor = newValue
        }
        get {
            return label.textColor
        }
    }
    
    var font: UIFont {
        set {
            label.font = newValue
            calculateLabelWidth()
        }
        get {
            return label.font
        }
    }
    
    private var labelConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    private func setup() {
        self.addSubview(label)
        setupConstraints()
        self.backgroundColor = UIColor(hex: 0x3F51B5)
        self.layer.masksToBounds = true
        updateMark()
        self.addObserver(self, forKeyPath: "bounds", options: .init(rawValue: 0), context: nil)
    }
    
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDict = ["label": label]
        self.do {
            $0.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.2, constant: 0))
            $0.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[label]-8-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict))
            $0.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.45, constant: 0))
        }

        labelConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 0)
        label.addConstraint(labelConstraint)
    }

    private func updateMark() {
        let bounds = self.bounds
        let arcCenter = CGPoint(x: bounds.width * 0.5, y: bounds.width * 0.5)
        let bottom = CGPoint(x: bounds.width * 0.5, y: bounds.height)
        let path = UIBezierPath()
        let d = distance(between: arcCenter, p2: bottom)
        let angle = acosf(Float(bounds.width * 0.5 / d))
        path.move(to: bottom)
        path.addArc(withCenter: arcCenter, radius: bounds.width * 0.5, startAngle: CGFloat(.pi * 0.5 - angle), endAngle: CGFloat(.pi * 0.5 + angle), clockwise: false)
        path.close()
        
        let mark = CAShapeLayer()
        mark.path = path.cgPath
        self.layer.mask = mark
    }
    
    private var valueFormatString: String {
        return String(format: "%%.%df", precision)
    }
    
    private func calculateLabelWidth() {
        let maxValue = String.init(format: valueFormatString, self.maxValue)
        let attrs = [
            NSAttributedString.Key.font : label.font
        ] as [NSAttributedString.Key: Any]
        labelConstraint.constant = (maxValue as NSString).size(withAttributes: attrs).width + 1
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? SSBubbleSliderLabel, let kp = keyPath {
            if obj == self && kp == "bounds" {
                updateMark()
            }
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "bounds")
    }
}

class SSBubbleSliderTickMarksView: UIView {
    private let TickSize: CGFloat = 2
    var maximunValue: CGFloat = 1 {
        didSet {
            arrangeTickMarks()
        }
    }
    var minimunValue: CGFloat = 0 {
        didSet {
            arrangeTickMarks()
        }
    }
    var step: CGFloat = 0 {
        didSet {
            arrangeTickMarks()
        }
    }
    var tickColor: UIColor = UIColor.black {
        didSet {
            for layer in tickLayers {
                layer.backgroundColor = tickColor.cgColor
            }
        }
    }
    
    private var tickLayers = [CALayer]()
    private var tickValues = [CGFloat]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.addObserver(self, forKeyPath: "bounds", options: .init(rawValue: 0), context: nil)
    }
    
    func nearestTickValue(from value: CGFloat) -> CGFloat {
        for i in 0 ..< tickLayers.count {
            let tickValue = tickValues[i]
            if minimunValue < maximunValue {
                if tickValue >= value {
                    if i == 0 {
                        return tickValue
                    }
                    let previousTickValue = tickValues[i - 1]
                    if fabs(Double(value - previousTickValue)) > fabs(Double(tickValue - value)) {
                        return tickValue
                    } else {
                        return previousTickValue
                    }
                }
            } else {
                if tickValue <= value {
                    if i == 0 {
                        return tickValue
                    }
                    let previousTickValue = tickValues[i - 1]
                    if fabs(Double(value - previousTickValue)) > fabs(Double(tickValue - value)) {
                        return tickValue
                    } else {
                        return previousTickValue
                    }
                }
            }
        }
        return minimunValue
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? SSBubbleSliderTickMarksView, let kp = keyPath {
            if obj == self && kp == "bounds" {
                arrangeTickMarks()
            }
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "bounds")
    }
    
    private func arrangeTickMarks() {
        for layer in tickLayers {
            layer.removeFromSuperlayer()
        }
        tickLayers.removeAll()
        tickValues.removeAll()
        
        var _step = step
        if maximunValue < minimunValue {
            _step = CGFloat(-fabs(Double(_step)))
        }
        if _step != 0 {
            let space = self.frame.width * CGFloat(fabs(Double(_step))) / CGFloat(fabs(Double(maximunValue - minimunValue)))
            if space > 0 {
                var x: CGFloat = 0
                var value = minimunValue
                while x < self.frame.width {
                    let tick = createTick(x)
                    self.layer.addSublayer(tick)
                    tickLayers.append(tick)
                    tickValues.append(value)
                    x += space
                    value += _step
                }
                x = self.frame.width
                value = maximunValue
                let tick = createTick(x)
                self.layer.addSublayer(tick)
                tickLayers.append(tick)
                tickValues.append(value)
            }
        }
    }
    
    private func createTick(_ x: CGFloat) -> CALayer {
        let tick = CALayer()
        tick.frame = CGRect(x: x - TickSize * 0.5, y: (self.bounds.height - TickSize) * 0.5, width: TickSize, height: TickSize)
        tick.backgroundColor = tickColor.cgColor
        return tick
    }
}

class SSBubbleSliderIcno: UIView {
    private var imageView = UIImageView()
    private lazy var viewsDicts: [String: UIView] = {
        return ["imageView": imageView]
    }()
    
    var isHasContent: Bool {
        return imageView.image != nil
    }
    
    var image: UIImage? {
        set {
            imageView.image = image
        }
        get {
            return imageView.image
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
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageView]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewsDicts)
        self.addConstraints(v)
        let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageView]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewsDicts)
        self.addConstraints(h)
    }
}

@inline(__always) func distance(between p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return CGFloat(sqrtf(Float(dx * dx + dy * dy)))
}

