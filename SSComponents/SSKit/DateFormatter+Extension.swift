//
//  DateFormatter.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/8.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static private var _cacheFormatter: DateFormatter! = nil
    class var `default`: DateFormatter {
        DispatchQueue.once("com.create.dateformatter") {
            _cacheFormatter = DateFormatter()
            _cacheFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        return _cacheFormatter
    }
    
    
}
