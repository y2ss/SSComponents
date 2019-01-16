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
    
    func dictForViews(_ views: [UIView], anyClass: AnyClass = NSObject.self) -> [String: UIView] {
        var count: UInt32 = 0
        var dicts: [String: UIView] = [:]
        if let ivars = class_copyIvarList(self.classForCoder, &count) {
            for i in 0 ..< Int(count) {
                if let c = ivar_getTypeEncoding(ivars[i]) {
                    let type = String.init(cString: c)
                    print(type)
                    //crash: 传ivars[i]是struct、元组、等
                    if let obj = object_getIvar(self, ivars[i]) as? UIView {
                        if views.contains(obj) {
                            if let cString = ivar_getName(ivars[i]) {
                                let name = String(cString: cString)
                                dicts[name] = obj
                                if dicts.count == views.count { break }
                            }
                        }
                    }
                }
            }
            free(ivars)
        }
        return dicts
    }
    
}
