//
//  Data+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension Data {
    
    var bytes: Array<UInt8> {
        return Array(self)
    }
    
    var utf8: String? {
        if self.count > 0 {
            guard let _utf8 = String(data: self, encoding: .utf8) else { return nil }
            return _utf8
        }
        return nil
    }
    
    var hex: String {
        return String(format: "%@", self as CVarArg)
    }
    

    
}
