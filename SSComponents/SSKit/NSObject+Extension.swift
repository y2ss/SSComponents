//
//  NSObject+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/8.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension NSObject {
    
    @discardableResult
    func swizzle(with _class: AnyClass, oriSel: Selector, altSel: Selector) -> Bool {
        let _oriSel = oriSel
        let _altSel = altSel
        if
            let _oriMet = class_getInstanceMethod(_class, _oriSel),
            let _altMet = class_getInstanceMethod(_class, _altSel) {
            let didAddMethod = class_addMethod(_class, _oriSel, method_getImplementation(_altMet), method_getTypeEncoding(_altMet))
            if didAddMethod {
                class_replaceMethod(_class, _altSel, method_getImplementation(_oriMet), method_getTypeEncoding(_oriMet))
            } else {
                method_exchangeImplementations(_oriMet, _altMet)
            }
            return true
        }
        return false
    }
    
    
}
