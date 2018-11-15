//
//  UIScrollView+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/9.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    enum ScrollViewDirection: Int {
        case up = 0
        case down
        case left
        case right
        case unkown
    }
    
    var direction: ScrollViewDirection {
        if self.panGestureRecognizer.translation(in: self.superview).y > 0 {
            return .up
        } else if self.panGestureRecognizer.translation(in: self.superview).y < 0 {
            return .down
        } else if self.panGestureRecognizer.translation(in: self).x < 0 {
            return .left
        } else if self.panGestureRecognizer.translation(in: self).x < 0 {
            return .right
        } else {
            return .unkown
        }
    }
    
    var topContentOffset: CGPoint {
        return CGPoint(x: 0, y: -contentInset.top)
    }
    
    var bottomContentOffset: CGPoint {
        return CGPoint(x: 0, y: contentSize.height + contentInset.bottom - height)
    }
    
    var leftContentOffset: CGPoint {
        return CGPoint(x: contentInset.left, y: 0)
    }
    
    var rightContentOffset: CGPoint {
        return CGPoint(x: contentSize.width + contentInset.right - width, y: 0)
    }
    
    var isScrolledToTop: Bool {
        return contentOffset.y <= topContentOffset.y
    }
    
    var isScrolledToBottom: Bool {
        return contentOffset.y >= bottomContentOffset.y
    }
    
    var isScrolledToLeft: Bool {
        return contentOffset.x <= leftContentOffset.x
    }
    
    var isScrolledToRight: Bool {
        return contentOffset.x >= rightContentOffset.x
    }
    
    func scrollToTopAnimated(_ animated: Bool) {
        setContentOffset(topContentOffset, animated: animated)
    }
    
    func scrollToBottomAnimated(_ animated: Bool) {
        setContentOffset(bottomContentOffset, animated: animated)
    }
    
    func scrollToLeftAnimated(_ animated: Bool) {
        setContentOffset(leftContentOffset, animated: animated)
    }
    
    func scrollToRightAnimated(_ animated: Bool) {
        setContentOffset(rightContentOffset, animated: animated)
    }
}
