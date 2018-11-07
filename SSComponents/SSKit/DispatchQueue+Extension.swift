//
//  DispatchQueue+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension DispatchQueue {
    private static var onceToken = [String]()
    
    class func once(_ token: String, block:() -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if onceToken.contains(token) { return }
        onceToken.append(token)
        
        block()
    }
}
