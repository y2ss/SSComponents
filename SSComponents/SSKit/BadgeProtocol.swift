//
//  Badge.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/10.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

protocol BadgeProtocol {
    var badgeValue: String? { set get }
    var badgeLabel: UILabel? { set get }
    var badgeBackgroundColor: UIColor? { set get }
    var badgeTextColor: UIColor? { set get }
    var badgeFont: UIFont? { set get }
    var badgePadding: CGFloat? { set get }
    var badgeMinSize: CGFloat? { set get }
    var badgeOriginX: CGFloat? { set get }
    var badgeOriginY: CGFloat? { set get }
    var shouldHideBadgeAtZero: Bool? { set get }
    var shouldAnimateBadge: Bool? { set get }
}

extension UIButton: BadgeProtocol {
    
    private struct AssociateObject {
        fileprivate static var badgeValue: UInt8 = 0
        fileprivate static var badgeLabelKey: UInt8 = 1
        fileprivate static var badgeBackgroundColorKey: UInt8 = 2
        fileprivate static var badgeOriginXKey: UInt8 = 3
        fileprivate static var badgeOriginYKey: UInt8 = 4
        fileprivate static var badgeFontKey: UInt8 = 5
        fileprivate static var badgeMinSizeKey: UInt8 = 6
        fileprivate static var badgeTextColorKey: UInt8 = 7
        fileprivate static var shouldAnimateBadgeKey: UInt8 = 8
        fileprivate static var shouldHideBadgeAtZeroKey: UInt8 = 9
        fileprivate static var badgePaddingKey: UInt8 = 10
    }
    
    var badgeValue: String? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeValue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if badgeValue == nil || (badgeValue == "0" && shouldHideBadgeAtZero ?? false) {
                removeBadge()
            } else if badgeLabel == nil {
                createBadge()
                updateBadgeValueAnimate(false)
            } else {
                updateBadgeValueAnimate(true)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeValue) as? String
        }
    }
    
    var badgeLabel: UILabel? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeLabelKey) as? UILabel
        }
    }

    var badgeBackgroundColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeBackgroundColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badgeLabel {
                refreshBadge()
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeBackgroundColorKey) as? UIColor ?? UIColor.red
        }
    }
    
    var badgeOriginX: CGFloat? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeOriginXKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if let _ = badgeLabel {
                updateBadgeFrame()
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeOriginXKey) as? CGFloat
        }
    }
    
    var badgeOriginY: CGFloat? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeOriginYKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if let _ = badgeLabel {
                updateBadgeFrame()
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeOriginYKey) as? CGFloat
        }
    }
    
    var badgeFont: UIFont? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeFontKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badgeLabel {
                refreshBadge()
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeFontKey) as? UIFont
        }
    }
    
    var badgeMinSize: CGFloat? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeMinSizeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if let _ = badgeLabel {
                updateBadgeFrame()
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeMinSizeKey) as? CGFloat
        }
    }
    
    var badgeTextColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgeTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let _ = badgeLabel {
                refreshBadge()
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgeTextColorKey) as? UIColor
        }
    }
    
    var shouldAnimateBadge: Bool? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.shouldAnimateBadgeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.shouldAnimateBadgeKey) as? Bool
        }
    }
    
    var shouldHideBadgeAtZero: Bool? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.shouldHideBadgeAtZeroKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.shouldHideBadgeAtZeroKey) as? Bool
        }
    }
    
    var badgePadding: CGFloat? {
        set {
            objc_setAssociatedObject(self, &AssociateObject.badgePaddingKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if let _ = badgeLabel {
                updateBadgeFrame()
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociateObject.badgePaddingKey) as? CGFloat
        }
    }

    private func removeBadge() {
        if let _ = badgeLabel {
            UIView.animate(withDuration: 0.2, animations: {
                self.badgeLabel?.transform = CGAffineTransform(scaleX: 0, y: 0)
            }) { flag in
                self.badgeLabel?.removeFromSuperview()
                self.badgeLabel = nil
            }
        }
    }
    
    private func createBadge() {
        setupBadge()
        badgeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        badgeLabel?.textColor = badgeTextColor
        badgeLabel?.backgroundColor = badgeBackgroundColor
        badgeLabel?.font = badgeFont
        badgeLabel?.textAlignment = .center
        badgeOriginX = self.width - badgeLabel!.width * 0.5
        badgeLabel?.origin = CGPoint(x: badgeOriginX!, y: badgeOriginY!)
        self.clipsToBounds = false
        self.addSubview(badgeLabel!)
    }
    
    private func setupBadge() {
        badgeBackgroundColor = UIColor.red
        badgeTextColor = UIColor.white
        badgeFont = UIFont.systemFont(ofSize: 12)
        badgePadding = 6
        badgeMinSize = 8
        badgeOriginY = -4
        shouldHideBadgeAtZero = true
        shouldAnimateBadge = true
    }
    
    private func updateBadgeValueAnimate(_ animated: Bool) {
        if animated && shouldAnimateBadge! && badgeLabel?.text == badgeValue {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = NSNumber(value: 1.5)
            animation.toValue = NSNumber(value: 1)
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1, 1)
            badgeLabel?.layer.add(animation, forKey: "bounceAnimation")
        }
        badgeLabel?.text = badgeValue
        let duration = animated ? 0.2 : 0
        UIView.animate(withDuration: duration) {
            self.updateBadgeFrame()
        }
    }
    
    private func badgeExpectedSize() -> CGSize {
        let framelabel = duplicateLabel(badgeLabel!)
        framelabel.sizeToFit()
        let expectedLabelSize = framelabel.frame.size
        return expectedLabelSize
    }
    
    private func updateBadgeFrame() {
        let expectedLabelSize = badgeExpectedSize()
        var minHeight = expectedLabelSize.height
        minHeight = minHeight < badgeMinSize! ? badgeMinSize! : expectedLabelSize.height
        var minWidth = expectedLabelSize.width
        let padding = badgePadding
        minWidth = minWidth < minHeight ? minHeight : expectedLabelSize.width
        badgeLabel?.frame = CGRect(x: badgeOriginX!, y: badgeOriginY!, width: minWidth + padding!, height: minHeight + padding!)
        badgeLabel?.layer.cornerRadius = (minHeight + padding!) * 0.5
        badgeLabel?.layer.masksToBounds = true
    }
    
    private func duplicateLabel(_ copy: UILabel) -> UILabel {
        let label = UILabel(frame: copy.frame)
        label.text = copy.text
        label.font = copy.font
        return label
    }
    
    private func refreshBadge() {
        badgeLabel?.textColor = badgeTextColor
        badgeLabel?.backgroundColor = badgeBackgroundColor
        badgeLabel?.font = badgeFont
    }
}
