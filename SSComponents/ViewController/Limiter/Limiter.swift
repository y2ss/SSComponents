//
//  TimedLimiter.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/26.
//  Copyright © 2018年 y2ss. All rights reserved.
//

protocol SyncLimiter {
    @discardableResult func execute(_ block: () -> Void) -> Bool
    func reset()
}

extension SyncLimiter {
    func execute<T>(_ block: () -> T) -> T? {
        var value: T? = nil
        execute {
            value = block()
        }
        return value
    }
}

class TimedLimiter: SyncLimiter {

    let limit: TimeInterval
    
    public private(set) var lastExecutedAt: Date?
    
    private let syncQueue = DispatchQueue(label: "com.timedlimit.queue", attributes: [])
    
    init(limit: TimeInterval) {
        self.limit = limit
    }
    
    @discardableResult func execute(_ block: () -> Void) -> Bool {
        let executed = syncQueue.sync { () -> Bool in
            let now = Date()
            let timeinterval = now.timeIntervalSince(lastExecutedAt ?? .distantPast)
            if timeinterval > limit {
                lastExecutedAt = now
                return true
            }
            return false
        }
        if executed {
            block()
        }
        return executed
    }
    
    func reset() {
        syncQueue.sync {
            lastExecutedAt = nil
        }
    }
}

class CountedLimiter: SyncLimiter {
    let limit: UInt
    public private(set) var count: UInt = 0
    
    private let syncQueue = DispatchQueue(label: "com.countedlimit.queue", attributes: [])
    
    init(limit: UInt) {
        self.limit = limit
    }
    
    @discardableResult func execute(_ block: () -> Void) -> Bool {
        let executed = syncQueue.sync { () -> Bool in
            if count < limit {
                count += 1
                return true
            }
            return false
        }
        if executed {
            block()
        }
        return executed
    }
    
    func reset() {
        syncQueue.sync {
            count = 0
        }
    }
}
