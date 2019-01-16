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
        let totalDays = Calendar.current.range(of: .day, in: .month, for: self)?.count
        return totalDays
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
    
    
    var previousMonthDate: Date? {
        let calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = 15// 定位到当月中间日子
        if let _ = components.month, let _ = components.month {
            if components.month == 1 {
                components.month = 12
                components.year = components.year! - 1
            } else {
                components.month = components.month! - 1
            }
            let previousDate = calendar.date(from: components)
            return previousDate
        }
        return nil
    }
    
    var nextMonthDate: Date? {
        let calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = 15
        if let _ = components.month, let _ = components.year {
            if components.month == 12 {
                components.month = 1
                components.year = 1 + components.year!
            } else {
                components.month = 1 + components.month!
            }
            let nextDate = calendar.date(from: components)
            return nextDate
        }
        return nil
    }
    
    //本月第一周有几天
    var firstWeekDayInMonth: Int? {
        let calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = 1// 定位到当月第一天
        if
            let firstDay = calendar.date(from: components),
            let weekday = calendar.ordinality(of: .day, in: .weekOfMonth, for: firstDay) {
            // 默认一周第一天序号为 1 ，而日历中约定为 0 ，故需要减一
            //获取该时间of在in中的位置
            let firstWeekDay = weekday - 1
            return firstWeekDay
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
    
    init?(_ dateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.locale = Locale.current
        if let d = formatter.date(from: dateString) {
            self.init(timeInterval: 0, since: d)
        } else {
            self.init(timeInterval: 0, since: Date())
            return nil
        }
    }
    
    @available(iOS 10.0, *)
    var isoFormatter: ISO8601DateFormatter {
        if let formatter = objc_getAssociatedObject(self, "formatter") as? ISO8601DateFormatter {
            return formatter
        } else {
            let formatter = ISO8601DateFormatter()
            objc_setAssociatedObject(self, "formatter", formatter, .OBJC_ASSOCIATION_RETAIN)
            return formatter
        }
    }

    @available(iOS 10.0, *)
    func toISOString() -> String {
        return self.isoFormatter.string(from: self)
    }
}
