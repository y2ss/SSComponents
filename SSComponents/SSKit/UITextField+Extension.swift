//
//  UITextField+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/15.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UITextField {
    
    //当前选中的字符串范围
    var selectedRange: NSRange? {
        if let selectedRange = self.selectedTextRange {
            let selectedStart = selectedRange.start
            let selectedEnd = selectedRange.end
            let location = self.offset(from: beginningOfDocument, to: selectedStart)
            let length = self.offset(from: selectedStart, to: selectedEnd)
            return NSRange.init(location: location, length: length)
        }
        return nil
    }
    
    //选中所有文字
    func selectAllText() {
        let range = self.textRange(from: beginningOfDocument, to: endOfDocument)
        self.selectedTextRange = range
    }
    
    //选中指定范围的文字
    func selectedRange(_ range: NSRange) {
        if
            let start = self.position(from: beginningOfDocument, offset: range.location),
            let end = self.position(from: beginningOfDocument, offset: NSMaxRange(range)) {
            let selectedRange = self.textRange(from: start, to: end)
            self.selectedTextRange = selectedRange
        }
    }
}
