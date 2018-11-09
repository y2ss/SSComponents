//
//  Timer.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/8.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension Timer {
    
    func pause() {
        if self.isValid {
            self.fireDate = .distantFuture
        }
    }
    
    func resume() {
        if self.isValid {
            self.fireDate = .distantPast
        }
    }
    
    func resume(after timeinterval: TimeInterval) {
        if self.isValid {
            self.fireDate = Date(timeIntervalSinceNow: timeinterval)
        }
    }
    
}
