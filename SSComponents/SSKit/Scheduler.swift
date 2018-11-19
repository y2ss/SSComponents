//
//  Scheduler.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

class Scheduler: NSObject {
    
    typealias Action = () -> Void
    typealias EndCondition = () -> Bool
    
    var timer: Timer?
    var action: Action?
    var endCondition: EndCondition?
    
    func scheduleRepeatedly(_ action: @escaping Action, interval: TimeInterval, endCondition: @escaping EndCondition) {
        guard timer == nil && interval > 0 else { return }
        self.action = action
        self.endCondition = endCondition
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(doAction(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func doAction(_ timer: Timer) {
        guard let action = action, let endCondition = endCondition, !endCondition() else {
            timer.invalidate()
            self.timer = nil
            self.action = nil
            self.endCondition = nil
            return
        }
        action()
    }
    
}
