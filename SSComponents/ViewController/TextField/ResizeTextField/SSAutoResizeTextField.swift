//
//  SSAutoResizeTextField.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/4.
//  Copyright © 2018年 y2ss. All rights reserved.
//

@objc protocol SSAutoResizeTextFieldDelegate: class, NSObjectProtocol {
    
    @objc optional func textFieldDidChange(_ textField: SSAutoResizeTextField)
    @objc optional func textFieldShouldBeginEditing(_ textField: SSAutoResizeTextField) -> Bool
    @objc optional func textFieldDidBeginEditing(_ textField: SSAutoResizeTextField)
    @objc optional func textFieldShouldEndEditing(_ textField: SSAutoResizeTextField) -> Bool
    @objc optional func textFieldDidEndEditing(_ textField: SSAutoResizeTextField)
    @objc optional func textField(_ textField: SSAutoResizeTextField, shoudlChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    @objc optional func textFieldShouldClear(_ textField: SSAutoResizeTextField)
    @objc optional func textFieldShouldReturn(_ textField: SSAutoResizeTextField) -> Bool
}

class SSAutoResizeTextField: UIControl {
    
    enum ViewState {
        case normal
        case highlighted
        case error
        case disabled
    }
    
    var hint: String? {
        didSet {
            if !isFloatingLabel || label == nil || label!.count == 0 {
                placeholder = hint
            }
        }
    }
    var label: String? {
        didSet {
            relayout()
            labelView.text = label
        }
    }
    var isFloatingLabel: Bool = false {
        didSet {
            if isFloatingLabel != oldValue {
                if isFloatingLabel && !isFullWidth {
                    placeholder = nil
                } else {
                    placeholder = hint
                }
                calculateLabelFrame()
            }
        }
    }
    var isHighlightLabel: Bool = true {
        didSet {
            updateState()
        }
    }
    var errorMessage: String? {
        didSet {
            errorView.text = errorMessage
            relayout()
        }
    }
    var maxCharacterCount: Int = 0 {
        didSet {
            if maxCharacterCount > 0 {
                characterCountView.isHidden = false
                updateTextLength(textLength)
            } else {
                characterCountView.isHidden = true
            }
            relayout()
        }
    }
    var normalColor: UIColor = UIColor(hex: 0x343434) {
        didSet {
            dividerHolder.normalColor = normalColor
            updateState()
        }
    }
    var highlightColor: UIColor = UIColor(hex: 0x3F51B5) {
        didSet {
            dividerHolder.highlightColor = highlightColor
            updateState()
        }
    }
    var errorColor: UIColor = UIColor(hex: 0xFF4081) {
        didSet {
            errorView.textColor = errorColor
            dividerHolder.errorColor = errorColor
            updateState()
        }
    }
    var disableColor: UIColor = UIColor(hex: 0x343434)
    var textColor: UIColor = UIColor(hex: 0x343434) {
        didSet {
            textField.textColor = textColor
            textView.textColor = textColor
        }
    }
    var hintColor: UIColor = UIColor.gray {
        didSet {
            textField.hintColor = hintColor
            textView.placeholderColor = hintColor
        }
    }
    var isAutoComplete: Bool = false
    var isSingleLine: Bool = false {
        didSet {
            if oldValue != isSingleLine {
                textView.isHidden = isSingleLine
                textField.isHidden = !isSingleLine
                relayout()
                if !isSingleLine && isSizeLimited {
                    updateMaxTextViewSize()
                }
            }
        }
    }
    var isFullWidth: Bool = false {
        didSet {
            relayout()
        }
    }
    var minVisibleLines: Int = 1 {
        didSet {
            textView.minVisibleLines = minVisibleLines
        }
    }
    var maxVisibleLines: Int = 2 {
        didSet {
            textView.maxVisibleLines = maxVisibleLines
        }
    }
    var text: String? {
        get {
            return isSingleLine ? textField.text : textView.text
        }
        set {
            if let _newValue = newValue {
                if isSingleLine {
                    if _newValue != textField.text {
                        inputTextDidBeginEditing(textField.text?.count ?? 0)
                        textField.text = _newValue
                    }
                } else {
                    if _newValue != textView.text {
                        inputTextDidBeginEditing(textView.text.count)
                        textView.text = _newValue
                    }
                }
            }
            updateTextLength((newValue ?? "").count)
            delegate?.textFieldDidChange?(self)
            sendActions(for: .editingChanged)
        }
    }
    var placeholder: String? {
        set {
            textField.placeholder = newValue
            textView.placeholder = newValue
        }
        get {
            return isSingleLine ? textField.placeholder : textView.placeholder
        }
    }
    var isSecureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = isSecureTextEntry
            textView.isSecureTextEntry = isSecureTextEntry
        }
    }
    var isDividerAnimation: Bool = true {
        didSet {
            dividerHolder.isUseAnimation = isDividerAnimation
        }
    }
    var isRestrictInBounds: Bool = false
    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = returnKeyType
            textView.returnKeyType = returnKeyType
        }
    }
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
            textView.keyboardType = keyboardType
        }
    }
    var autocapitalizationType: UITextAutocapitalizationType = .none {
        didSet {
            textField.autocapitalizationType = autocapitalizationType
            textView.autocapitalizationType = autocapitalizationType
        }
    }
    var autocorrectionType: UITextAutocorrectionType = .default {
        didSet {
            textField.autocorrectionType = autocorrectionType
            textView.autocorrectionType = autocorrectionType
        }
    }
    var spellCheckingType: UITextSpellCheckingType = .default {
        didSet {
            textField.spellCheckingType = spellCheckingType
            textView.spellCheckingType = spellCheckingType
        }
    }
    var isHasError: Bool = false {
        didSet {
            updateState()
        }
    }
    var labelsFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            labelView.font = labelsFont
            errorView.font = labelsFont
            characterCountView.font = labelsFont
            calculateLabelFrame()
        }
    }
    var inputTextFont: UIFont =  UIFont.systemFont(ofSize: 16) {
        didSet {
            textField.font = inputTextFont
            textView.font = inputTextFont
            calculateLabelFrame()
        }
    }
    var textViewHeightConstraint: NSLayoutConstraint?
    var suggestionDictionary: [String]? {
        didSet {
            suggestView?.suggestionDict = suggestionDictionary ?? [String]()
            isAutoComplete = true
            isSingleLine = true
        }
    }
    
    override var isFirstResponder: Bool {
        return inputText.isFirstResponder
    }
    
    override var isEnabled: Bool {
        didSet {
            textField.isEnabled = isEnabled
            textView.isEditable = isEnabled
            textView.isSelectable = isEnabled
            dividerHolder.isEnable = isEnabled
            updateState()
        }
    }
    
    override var frame: CGRect {
        didSet {
            if frame.size != .zero {
                isSizeLimited = true
                if !isSingleLine {
                    updateMaxTextViewSize()
                }
            }
        }
    }
    
    weak var delegate: SSAutoResizeTextFieldDelegate?
    
    private let moveUpAnimationKey = "upAnimation"
    private let moveDowmAnimationKey = "downAnimation"
    private let animationDuration = 0.2
    private let dividerHeight: CGFloat = 1
    private let focusedDividerHeight = 2
    private let zeroPadding = 0
    private let normalPadding: CGFloat = 8
    private let largePadding: CGFloat = 16
    private let extraLargePadding: CGFloat = 20
    
    private lazy var textView: AutoResizeTextView = {
        let view = AutoResizeTextView.init(frame: self.bounds)
        view.tintColor = highlightColor
        view.font = inputTextFont
        view.delegate = self
        view.textColor = textColor
        view.placeholderColor = hintColor
        view.holder = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var textField: TextField!
//    private lazy var textField: TextField = {
//        let view = TextField.init(frame: self.bounds)
//        view.tintColor = highlightColor
//        view.font = inputTextFont
//        view.delegate = self
//        view.textColor = textColor
//        view.hintColor = hintColor
//        view.isHidden = true
//        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        view.addTarget(self, action: #selector(textChaned(_:)), for: .editingChanged)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    private var viewState: ViewState = .normal {
        didSet {
            switch viewState {
            case .normal:
                if !isFullWidth {
                    dividerHolder.state = .normal
                }
                labelView.textColor = normalColor
                updateTextColor(textColor)
                break
            case .highlighted:
                if !isFullWidth {
                    dividerHolder.state = .highlighted
                }
                if isHighlightLabel {
                    labelView.textColor = highlightColor
                }
                updateTextColor(textColor)
                break
            case .error:
                if !isFullWidth {
                    dividerHolder.state = .error
                }
                if isHighlightLabel {
                    labelView.textColor = errorColor
                }
                updateTextColor(textColor)
                break
            case .disabled:
                dividerHolder.state = .disabled
                updateTextColor(disableColor)
                break
            }
        }
    }
    
    private lazy var labelView: UILabel = {
       let label = UILabel.init(frame: CGRect.init(x: 0, y: 16, width: bounds.width, height: labelsFont.lineHeight))
        label.font = labelsFont
        label.textColor = normalColor
        label.numberOfLines = 1
        label.layer.anchorPoint = CGPoint.init(x: 0, y: 0)
        return label
    }()
    private lazy var labelPlaceHolder: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 16, width: bounds.width, height: labelsFont.lineHeight))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var errorView: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 77, width: bounds.width, height: 15))
        label.font = labelsFont
        label.textColor = errorColor
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var characterCountView: UILabel = {
       let label = UILabel.init(frame: CGRect.init(x: bounds.width - 50, y: 77, width: 50, height: 15))
        label.font = labelsFont
        label.textColor = normalColor
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isEnabled = true
        return label
    }()
    private lazy var dividerHolder: DividerView = {
        let view = DividerView.init(frame: CGRect.init(x: 0, y: 67, width: bounds.width, height: 2))
        view.layoutMargins = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        view.highlightColor = highlightColor
        view.errorColor = errorColor
        view.normalHeight = dividerHeight
        view.highlightHeight = CGFloat(focusedDividerHeight)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var placeHolder: UIView = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var suggestView: TextSuggestView?
    private lazy var viewsDict: [String: Any] = {
        return [
            "labelView": labelView,
            "labelHolder": labelPlaceHolder,
            "errorView": errorView,
            "characterCountView": characterCountView,
            "dividerHolder": dividerHolder,
            "inputView": inputText,
            "textField": textField,
            "textView": textView,
            "placeHolder": placeHolder
        ]
    }()
    private var constraintsArrs: [NSLayoutConstraint]?
    private var isExceedsCharacterLimits: Bool = false
    private var isSizeLimited: Bool = false

    private var textLength: Int {
        if isSingleLine {
            return textField.text?.count ?? 0
        } else {
            return textView.text.count
        }
    }
    
    private var inputText: UIView {
        return isSingleLine ? textField : textView
    }
    
    deinit {
        suggestView?.removeFromSuperview()
        suggestView = nil
    }
    
    override var canBecomeFirstResponder: Bool {
        return inputText.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return inputText.becomeFirstResponder()
    }
    
    override var canResignFirstResponder: Bool {
        return inputText.canResignFirstResponder
    }
    
    override func resignFirstResponder() -> Bool {
        let input = inputText
        return input.isFirstResponder ? input.resignFirstResponder() : true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeHolder.layoutSubviews()
        calculateLabelFrame()
        updateMaxTextViewSize()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let location = placeHolder.convert(point, from: self)
        return placeHolder.bounds.contains(location)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        textField = TextField.init(frame: self.bounds)
        textField.tintColor = highlightColor
        textField.font = inputTextFont
        textField.delegate = self
        textField.textColor = textColor
        textField.hintColor = hintColor
        textField.isHidden = true
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.addTarget(self, action: #selector(textChaned(_:)), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false

        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.isDividerAnimation = true
        placeHolder.addSubview(labelPlaceHolder)
        placeHolder.addSubview(dividerHolder)
        placeHolder.addSubview(textField)
        placeHolder.addSubview(textView)
        placeHolder.addSubview(errorView)
        placeHolder.addSubview(characterCountView)
        placeHolder.addSubview(labelView)
        self.addSubview(placeHolder)

        if let vt = NSLayoutConstraint.constraints(withVisualFormat: "V:[textView(\(Int(ceil(inputTextFont.lineHeight))))]", options: .init(rawValue: 0), metrics: nil, views: viewsDict).first {
            textViewHeightConstraint = vt
            textView.addConstraint(textViewHeightConstraint!)
        }
        
        let vl = NSLayoutConstraint.constraints(withVisualFormat: "V:[labelHolder(\(Int(ceilf(Float(labelView.font.lineHeight)))))]", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
        labelPlaceHolder.addConstraints(vl)
        
        let vd = NSLayoutConstraint.constraints(withVisualFormat: "V:[dividerHolder(\(Int(dividerHeight)))]", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
        dividerHolder.addConstraints(vd)
        
        let vp = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[placeHolder]-0@250-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
        self.addConstraints(vp)
        
        let hl = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[labelHolder]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
        placeHolder.addConstraints(hl)
        
        let hd = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[dividerHolder]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
        placeHolder.addConstraints(hd)
        
        let hp = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[placeHolder]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
        super.addConstraints(hp)
        relayout()
        
        suggestView = TextSuggestView(textField: self)
        maxCharacterCount = 0
        minVisibleLines = 1
        if !isSingleLine && isSizeLimited {
            updateMaxTextViewSize()
        }
    }
    
    @objc private func textChaned(_ sender: AnyObject) {
        if sender.isKind(of: TextField.self) {
            text = textField.text
        }
    }
    
    private func relayout() {
        if constraintsArrs != nil {
            placeHolder.removeConstraints(constraintsArrs!)
        }
        viewsDict["inputView"] = inputText
        
        var constraintsArr = [NSLayoutConstraint]()
        
        if isFullWidth {
            labelView.isHidden = true
            var constraintsString = "V:|-\(Int(extraLargePadding))-[inputView]"
            if maxCharacterCount > 0 {
                if isSingleLine {
                    constraintsString += "-\(Int(extraLargePadding))-[dividerHolder]-\(zeroPadding)-|"
                    
                    let v = NSLayoutConstraint.constraints(withVisualFormat: "V:[characterCountView]-\(Int(extraLargePadding))-[dividerHolder]", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                    constraintsArr += v
                    
                    let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(Int(largePadding))-[inputView]-\(Int(normalPadding))-[characterCountView(45)]-\(Int(largePadding))-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                    constraintsArr += h
                } else {
                    constraintsString += "-\(Int(normalPadding))-[characterCountView(\(Int(ceilf(Float(labelsFont.lineHeight)))))]-\(Int(extraLargePadding))-[dividerHolder]-\(zeroPadding)-|"
                    
                    let v = NSLayoutConstraint.constraints(withVisualFormat: "H:[characterCountView]-\(Int(largePadding))-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                    constraintsArr += v
                    
                    let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(Int(largePadding))-[inputView]-\(Int(largePadding))-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                    constraintsArr += h
                }
            } else {
                constraintsString += "-\(extraLargePadding)-[dividerHolder]-\(zeroPadding)-|"
                
                let v = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(Int(largePadding))-[inputView]-\(Int(largePadding))-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                constraintsArr += v
            }
            
            let n = NSLayoutConstraint.constraints(withVisualFormat: constraintsString, options: .init(rawValue: 0), metrics: nil, views: viewsDict)
            constraintsArr += n
        } else {
            labelView.isHidden = false
            var constraintsString = "V:|-\(Int(largePadding))-"
            if (label != nil && label?.count != 0) || (label != nil && label!.count > 0) {
                constraintsString += "[labelHolder]-\(Int(normalPadding))-"
            }
            constraintsString += "[inputView]-\(Int(normalPadding))-[dividerHolder]"
            
            if maxCharacterCount <= 0 && (errorMessage == nil || errorMessage!.count == 0) {
                constraintsString += "-\(Int(normalPadding))-|"
            } else {
                if errorMessage != nil && errorMessage!.count > 0 {
                    constraintsString += "-\(Int(normalPadding))-[errorView]-\(Int(normalPadding))-|"
                    
                    let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(zeroPadding)-[errorView]", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                    constraintsArr += h
                }
                
                if maxCharacterCount > 0 {
                    let v = NSLayoutConstraint.constraints(withVisualFormat: "V:[dividerHolder]-\(Int(normalPadding))-[characterCountView]-\(Int(normalPadding))-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                    constraintsArr += v
                    
                    let h = NSLayoutConstraint.constraints(withVisualFormat: "H:[errorView]-5-[characterCountView]-\(zeroPadding)-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
                    constraintsArr += h
                }
            }
            
            constraintsArr += NSLayoutConstraint.constraints(withVisualFormat: constraintsString, options: .init(rawValue: 0), metrics: nil, views: viewsDict)
            
            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(zeroPadding)-[inputView]-\(zeroPadding)-|", options: .init(rawValue: 0), metrics: nil, views: viewsDict)
            constraintsArr += h
        }
        
        constraintsArrs = constraintsArr
        placeHolder.addConstraints(constraintsArrs!)
        calculateLabelFrame()
        if !isSingleLine && isSizeLimited {
            updateMaxTextViewSize()
        }
    }
    
    private func updateState() {
        if isEnabled {
            if isHasError || isExceedsCharacterLimits {
                viewState = .error
                if !isFullWidth {
                    inputText.tintColor = errorColor
                }
                if isHasError {
                    errorView.isHidden = false
                }
            } else {
                inputText.tintColor = highlightColor
                if inputText.isFirstResponder {
                    viewState = .highlighted
                } else {
                    viewState = .normal
                }
                errorView.isHidden = true
            }
        } else {
            viewState = .disabled
        }
    }
    
    private func calculateLabelFrame() {
        if labelView.isHidden { return }
        if !isFloatingLabel || textLength > 0 || inputText.isFirstResponder {
            let frame = labelPlaceHolder.frame
            labelView.frame = CGRect(x: frame.x, y: frame.y, width: placeHolder.width, height: labelsFont.lineHeight)
            labelView.font = labelsFont
        } else {
            let frame = inputText.frame
            labelView.frame = CGRect(x: frame.x, y: frame.y, width: placeHolder.width, height: inputTextFont.lineHeight)
            labelView.font = inputTextFont
        }
    }
    
    private func updateTextLength(_ textLength: Int) {
        if isEnabled {
            if !characterCountView.isHidden {
                characterCountView.text = "\(textLength) / \(maxCharacterCount)"
            }
            if maxCharacterCount > 0 && textLength > maxCharacterCount {
                isExceedsCharacterLimits = true
                viewState = .error
                characterCountView.textColor = errorColor
            } else {
                isExceedsCharacterLimits = false
                if !isHasError {
                    if inputText.isFirstResponder {
                        viewState = .highlighted
                    } else {
                        viewState = .normal
                    }
                }
                characterCountView.textColor = normalColor
            }
        }
    }
    
    private func updateTextColor(_ color: UIColor) {
        textField.textColor = color
        textView.textColor = color
    }
    
    private func inputTextDidEndEditing(_ textLength: Int) {
        viewState = isHasError ? .error : .normal
        if isFloatingLabel && textLength == 0 && !isFullWidth {
            let scale = CABasicAnimation.init(keyPath: "transform.scale")
            scale.fromValue = NSNumber.init(value: 1)
            scale.toValue = NSNumber.init(value: Float(inputTextFont.lineHeight / labelsFont.lineHeight))
            
            let move = CABasicAnimation.init(keyPath: "position")
            move.fromValue = NSValue.init(cgPoint: labelPlaceHolder.origin)
            move.toValue = NSValue.init(cgPoint: inputText.origin)
            
            let group = CAAnimationGroup()
            group.duration = animationDuration
            group.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            group.setValue(moveDowmAnimationKey, forKey: "id")
            group.isRemovedOnCompletion = false
            group.fillMode = .forwards
            group.animations = [scale, move]
            group.delegate = self
            labelView.layer.add(group, forKey: nil)
        }
    }
    
    private func inputTextDidBeginEditing(_ textLength: Int) {
        if isHasError {
            viewState = .error
        } else if maxCharacterCount > 0 && textLength > maxCharacterCount {
            viewState = .error
            characterCountView.textColor = errorColor
        } else {
            viewState = .highlighted
        }
        
        if isFloatingLabel && textLength == 0 && !isFullWidth {
            let scale = CABasicAnimation.init(keyPath: "transform.scale")
            scale.fromValue = NSNumber.init(value: 1)
            scale.toValue = NSNumber.init(value: Float(labelsFont.lineHeight / inputTextFont.lineHeight))
            
            let move = CABasicAnimation.init(keyPath: "position")
            move.fromValue = NSValue.init(cgPoint: inputText.origin)
            move.toValue = NSValue.init(cgPoint: labelPlaceHolder.origin)
            
            let group = CAAnimationGroup()
            group.duration = animationDuration
            group.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            group.setValue(moveUpAnimationKey, forKey: "id")
            group.isRemovedOnCompletion = false
            group.fillMode = .forwards
            group.animations = [scale, move]
            group.delegate = self
            labelView.layer.add(group, forKey: nil)
        }
    }
    
    private var inputTextFrameOnWindow: CGRect {
        return convert(inputText.frame, to: nil)
    }
    
    private func updateMaxTextViewSize() {
        if isRestrictInBounds {
            textView.maxHeight = Float(frame.height - requiredHeightWithNumberOfTextLines(0))
        }
    }
    
    private func requiredHeightWithNumberOfTextLines(_ numberOfLines: Int) -> CGFloat {
        var requiredHeight: CGFloat = 0
        if !isFullWidth {
            requiredHeight += CGFloat(numberOfLines) * inputTextFont.lineHeight + normalPadding * 2 + largePadding + dividerHeight
            if let label = label {
                if label.count > 0 {
                    requiredHeight += normalPadding + labelsFont.lineHeight
                }
                if let errorMessage = errorMessage {
                    if maxCharacterCount > 0 || errorMessage.count > 0 {
                        requiredHeight += normalPadding + labelsFont.lineHeight
                    }
                }
            }
        } else {
            requiredHeight += CGFloat(numberOfLines) * inputTextFont.lineHeight + extraLargePadding * 2 + dividerHeight
            if !isSingleLine {
                requiredHeight += labelsFont.lineHeight + normalPadding
            }
        }
        return requiredHeight
    }
}

extension SSAutoResizeTextField: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let id = anim.value(forKey: "id") as? String {
            if id == moveUpAnimationKey {
                labelView.font = labelsFont
                labelView.frame = labelPlaceHolder.frame
            } else if id == moveDowmAnimationKey {
                labelView.font = inputTextFont
                let frame = inputText.frame
                labelView.frame = CGRect(x: frame.x, y: frame.y, width: placeHolder.width, height: inputTextFont.lineHeight)
            }
        }
        labelView.layer.removeAllAnimations()
    }
}

extension SSAutoResizeTextField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(self) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputTextDidBeginEditing(textField.text?.count ?? 0)
        delegate?.textFieldDidBeginEditing?(self)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing?(self) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputTextDidEndEditing(textField.text?.count ?? 0)
        delegate?.textFieldDidEndEditing?(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var res = true
        res = delegate?.textField?(self, shoudlChangeCharactersInRange: range, replacementString: string) ?? true
        if res {
            if let text = textField.text {
                let newText = (text as NSString).replacingCharacters(in: range, with: string)
                suggestView?.textView(self, didChangeText: newText)
            }
        }
        return res
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn?(self) ?? true
    }
}

extension SSAutoResizeTextField: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(self) ?? true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputTextDidBeginEditing(textView.text.count)
        delegate?.textFieldDidBeginEditing?(self)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.textFieldShouldEndEditing?(self) ?? true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        inputTextDidEndEditing(textView.text.count)
        delegate?.textFieldDidEndEditing?(self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate?.textField?(self, shoudlChangeCharactersInRange: range, replacementString: text) ?? true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.text = textView.text
    }
}


private class TextField: UITextField {
    var hintColor: UIColor = UIColor.gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.width = 1
        return rect
    }
    
    override func drawPlaceholder(in rect: CGRect) {
        if let placeholder = self.placeholder {
            let attributes = [
                NSAttributedString.Key.foregroundColor : hintColor,
                NSAttributedString.Key.font : self.font ?? UIFont.systemFont(ofSize: 15)
            ]
            let boundingRect = (placeholder as NSString).boundingRect(with: rect.size, options: .init(rawValue: 0), attributes: attributes, context: nil)
            (placeholder as NSString).draw(at: CGPoint(x: 0, y: rect.height * 0.5 - boundingRect.height * 0.5), withAttributes: attributes)
        }
    }
}

private class DividerView: UIView {
    var isEnable: Bool = true {
        didSet {
            if oldValue != isEnable {
                updateDividerLine()
            }
        }
    }
    var errorColor: UIColor = UIColor(hex: 0xFF4081) {
        didSet {
            if state == .error {
                highlightLayer.strokeColor = errorColor.cgColor
            }
        }
    }
    var highlightColor: UIColor = UIColor(hex: 0x3F51B5) {
        didSet {
            if state != .error {
                highlightLayer.strokeColor = highlightColor.cgColor
            }
        }
    }
    var normalColor: UIColor = UIColor(hex: 0x343434) {
        didSet {
            backgroundLayer.strokeColor = normalColor.cgColor
        }
    }
    var normalHeight: CGFloat = 1 {
        didSet {
            if oldValue != normalHeight {
                backgroundLayer.lineWidth = normalHeight
            }
        }
    }
    var highlightHeight: CGFloat = 2 {
        didSet {
            if oldValue != highlightHeight {
                highlightLayer.lineWidth = highlightHeight
            }
        }
    }
    var state: SSAutoResizeTextField.ViewState = .normal {
        willSet {
            if newValue != state {
                switch newValue {
                case .normal, .disabled:
                    if state == .highlighted || state == .error {
                        if isUseAnimation {
                            CATransaction.begin()
                            let anim = CABasicAnimation.init(keyPath: "strokeEnd")
                            anim.duration = 0.1
                            anim.fromValue = 1
                            anim.toValue = 0
                            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
                            anim.isRemovedOnCompletion = false
                            anim.fillMode = .forwards
                            CATransaction.setCompletionBlock {
                                self.highlightLayer.removeFromSuperlayer()
                            }
                            highlightLayer.add(anim, forKey: "strokeEnd")
                            CATransaction.commit()
                        } else {
                            highlightLayer.removeFromSuperlayer()
                        }
                    }
                    break
                case .highlighted, .error:
                    if state == .normal {
                        self.layer.addSublayer(highlightLayer)
                        if isUseAnimation {
                            CATransaction.begin()
                            let anim = CABasicAnimation.init(keyPath: "strokeEnd")
                            anim.duration = 0.1
                            anim.fromValue = 0
                            anim.toValue = 1
                            anim.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
                            anim.isRemovedOnCompletion = false
                            anim.fillMode = .forwards
                            highlightLayer.add(anim, forKey: "strokeEnd")
                            CATransaction.commit()
                        }
                    }
                    break
                }
            }
        }
        didSet {
            switch state {
            case .highlighted:
                highlightLayer.strokeColor = highlightColor.cgColor
                break
            case .error:
                highlightLayer.strokeColor = errorColor.cgColor
                break
            default:
                break
            }
        }
    }
    var isUseAnimation: Bool = true
    
    private var backgroundLayer = CAShapeLayer()
    private var highlightLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(backgroundLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDividerLine()
    }
    
    private func updateDividerLine() {
        if isEnable {
            drawLineDivider()
        } else {
            drawDashedLineDivider()
        }
    }
    
    private func drawLineDivider() {
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: bounds.width, y: 0))
        backgroundLayer.path = linePath.cgPath
        backgroundLayer.lineWidth = normalHeight
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = normalColor.cgColor
        
        highlightLayer.path = linePath.cgPath
        highlightLayer.lineWidth = highlightHeight
        highlightLayer.fillColor = UIColor.clear.cgColor
        if state == .error {
            highlightLayer.strokeColor = errorColor.cgColor
        } else {
            highlightLayer.strokeColor =  highlightColor.cgColor
        }
    }
    
    private func drawDashedLineDivider() {
        highlightLayer.removeFromSuperlayer()
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = normalColor.cgColor
        backgroundLayer.lineWidth = normalHeight
        backgroundLayer.lineJoin = .round
        backgroundLayer.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 3)]
        
        let path = CGMutablePath()
        path.move(to: CGPoint.init(x: 0, y: 0))
        path.addLine(to: CGPoint.init(x: bounds.width, y: 0))
        backgroundLayer.path = path
    }
}
