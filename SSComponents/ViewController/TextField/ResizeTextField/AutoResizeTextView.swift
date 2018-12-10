//
//  AutoResizeTextView.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/4.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class AutoResizeTextView: UITextView {
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    var placeholderColor: UIColor = UIColor.gray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    var minVisibleLines: Int = 0 {
        didSet {
            calculateTextViewHeight()
        }
    }
    var maxVisibleLines: Int = 0 {
        didSet {
            calculateTextViewHeight()
        }
    }
    var maxHeight: Float = 0 {
        didSet {
            if oldValue != maxHeight {
                calculateTextViewHeight()
            }
        }
    }
    weak var holder: SSAutoResizeTextField?
    
    override var frame: CGRect {
        didSet {
            print("set")
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
            calculateTextViewHeight()
            placeholderLabel.frame = CGRect(x: 0, y: textContainerInset.top, width: frame.width, height: placeholderLabel.font.lineHeight)
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            if isFirstResponder {
                resignFirstResponder()
                becomeFirstResponder()
            }
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        return label
    }()
    private var numLines: Int = 1
    private var isSettingText: Bool = false
    
    override var text: String! {
        willSet {
            isSettingText = true
        }
        didSet {
            isSettingText = false
            if text.count >= 1 {
                placeholderLabel.isHidden = true
            } else {
                placeholderLabel.isHidden = false
            }
            calculateTextViewHeight()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame = CGRect.init(x: 0, y: textContainerInset.top, width: frame.width, height: placeholderLabel.font.lineHeight)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.width = 1
        return rect
    }
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        setup()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    private func setup() {
        self.addSubview(placeholderLabel)
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        isScrollEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeWithNotification(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func textViewDidChangeWithNotification(_ noti: Notification) {
        if let obj = noti.object as? AutoResizeTextView {
            if obj == self && !isSettingText {
                if text.count >= 1 {
                    placeholderLabel.isHidden = true
                } else {
                    placeholderLabel.isHidden = false
                }
                calculateTextViewHeight()
            }
        }
    }
    
    private func calculateTextViewHeight() {
        let font = self.font ?? UIFont.systemFont(ofSize: 15)
        let contentHeight = intrinsicContentHeight()
        let lastNumline = numLines
        numLines = Int(CGFloat(contentHeight) / CGFloat(font.lineHeight))
        var minHeight: CGFloat = CGFloat(minVisibleLines) * font.lineHeight
        var visibleHeight = minHeight > contentHeight ? minHeight : contentHeight
        contentSize = CGSize.init(width: contentSize.width, height: contentHeight)
        
        if maxVisibleLines <= 0 && maxHeight <= 0 {
            if visibleHeight != frame.height {
                holder?.textViewHeightConstraint?.constant = visibleHeight
            }
        } else if maxHeight <= 0 {
            if lastNumline <= maxVisibleLines && numLines > maxVisibleLines {
                isScrollEnabled = true
                scrollToCaret()
            } else if lastNumline > maxVisibleLines && numLines <= maxVisibleLines {
                isScrollEnabled = false
                holder?.textViewHeightConstraint?.constant = visibleHeight
            } else if numLines > maxVisibleLines {
                scrollToCaret()
            } else if visibleHeight != frame.height {
                holder?.textViewHeightConstraint?.constant = visibleHeight
            }
        } else {
            var _maxHeight = CGFloat(maxHeight)
            if maxVisibleLines > 0 {
                let maxVisibleHeight = CGFloat(maxVisibleLines) * font.lineHeight
                if maxVisibleHeight < _maxHeight {
                    _maxHeight = maxVisibleHeight
                }
            }
            if _maxHeight < font.lineHeight {
                _maxHeight = font.lineHeight
            }
            if minHeight > _maxHeight {
                minHeight = _maxHeight
            }
            visibleHeight = minHeight > contentHeight ? minHeight : contentHeight
            if _maxHeight < visibleHeight {
                isScrollEnabled = true
                holder?.textViewHeightConstraint?.constant = _maxHeight
                scrollToCaret()
            } else {
                isScrollEnabled = false
                holder?.textViewHeightConstraint?.constant = visibleHeight
            }
        }
    }
    
    private func intrinsicContentHeight() -> CGFloat {
        var frame = bounds
        let leftRightPadding = textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2 + contentInset.left + contentInset.right
        let topBottomPadding = textContainerInset.top + textContainerInset.bottom + contentInset.top + contentInset.bottom
        frame.width -= leftRightPadding
        frame.height -= topBottomPadding
        
        if var textToMeasure = text {
            if textToMeasure.hasSuffix("\n") {
                textToMeasure = self.text + "-"
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            let attributes = [
                NSAttributedString.Key.font : self.font ?? UIFont.systemFont(ofSize: 15),
                NSAttributedString.Key.paragraphStyle : paragraphStyle
            ]
            let size = (textToMeasure as NSString)
                .boundingRect(with: CGSize(width: frame.width, height: CGFloat(MAXFLOAT)),
                              options: .usesLineFragmentOrigin,
                              attributes: attributes,
                              context: nil)
            let measureHeight = ceilf(Float(size.height + topBottomPadding))
            return CGFloat(measureHeight)
        }
        return contentSize.height
    }
    
    private func scrollToCaret() {
        let bottomOffset = CGPoint.init(x: 0, y: contentSize.height - bounds.height)
        setContentOffset(bottomOffset, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
