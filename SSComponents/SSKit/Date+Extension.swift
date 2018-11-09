//
//  Date.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/7.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension Date {
    
    var day: Int? {
        return Calendar.current.dateComponents([.day], from: self).day
    }
    
    var month: Int? {
        return Calendar.current.dateComponents([.month], from: self).month
    }
    
    var year: Int? {
        return Calendar.current.dateComponents([.year], from: self).year
    }
    
    var second: Int? {
        return Calendar.current.dateComponents([.second], from: self).second
    }
    
    var minute: Int? {
        return Calendar.current.dateComponents([.minute], from: self).minute
    }
    
    var hour: Int? {
        return Calendar.current.dateComponents([.hour], from: self).hour
    }
    
    //星期几
    var weakDay: Int? {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.weekday], from: self).weekday
    }
    
    var isLeapYear: Bool {
        if let year = self.year {
            if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) {
                return true
            }
        }
        return false
    }
    
    var daysInYear: Int {
        return self.isLeapYear ? 366 : 365;
    }
    
    //该月有多少天
    var daysInMonth: Int? {
        if let month = self.month {
            switch month {
            case 1, 3, 5, 7, 8, 10, 12:
                return 31
            case 2:
                return self.isLeapYear ? 29 : 28
            default:
                return 30
            }
        }
        return nil
    }
    
    //day天后的date @param day 可为负数
    func dateAfter(day: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.setValue(day, for: Calendar.Component.day)
        return Calendar.current.date(byAdding: dateComponents, to: self)
    }
    
    //
    func dateAfter(month: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.setValue(day, for: Calendar.Component.month)
        return Calendar.current.date(byAdding: dateComponents, to: self)
    }
    
    //
    func dateAfter(second: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.setValue(second, for: Calendar.Component.second)
        return Calendar.current.date(byAdding: dateComponents, to: self)
    }
    
    //
    func dateAfter(hour: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.setValue(second, for: Calendar.Component.hour)
        return Calendar.current.date(byAdding: dateComponents, to: self)
    }

    //
    func dateAfter(minute: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.setValue(second, for: Calendar.Component.minute)
        return Calendar.current.date(byAdding: dateComponents, to: self)
    }
    
    
    //该月第一天的日期
    var firstDayInMonth: Date? {
        if let day = self.day {
            return self.dateAfter(day: -day + 1)
        }
        return nil
    }
    
    //该月最后一天的日期
    var lastDayInMonth: Date? {
        if let last = self.firstDayInMonth {
            return last.dateAfter(month: 1)?.dateAfter(day: -1)
        }
        return nil
    }
    
    
    func isSameDay(_ anotherDate: Date) -> Bool {
        let comps1 = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let comps2 = Calendar.current.dateComponents([.year, .month, .day], from: self)
        if
            let year1 = comps1.year,
            let year2 = comps2.year,
            let month1 = comps1.month,
            let month2 = comps2.month,
            let day1 = comps1.day,
            let day2 = comps2.day {
            return year1 == year2 && month1 == month2 && day1 == day2
        }
        return false
    }
    
    func toString(from format: String) -> String? {
        let datefomatter = DateFormatter()
        datefomatter.dateFormat = format
        return datefomatter.string(from: self)
    }
}
