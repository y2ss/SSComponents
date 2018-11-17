//
//  UIResponder+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/9.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UIResponder {
    
    var responderChainDescription: String {
        var chains = [Any]()
        chains.append(type(of: self))
        let nextResponder = self
        
        var next = nextResponder.next
        while next != nil {
            guard let _next = next else { break }
            chains.append(_next)
            next = _next.next
        }
        var res = "Responder Chain:\n"
        for obj in chains {
            res += "-->\(obj)\n"
        }
        return res
    }
    
}
