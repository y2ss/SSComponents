//
//  Array+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/16.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func reverseArr() {
        let count = self.count
        let mid = Int(floor(Double(count) / 2))
        for i in 0 ..< mid {
            let temp = self[i]
            self[i] = self[count - i - 1]
            self[count - i - 1] = temp
        }
    }
    
}
