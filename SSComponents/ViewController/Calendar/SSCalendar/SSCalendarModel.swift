//
//  SSCalendarModel.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/16.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

class SSCalendarModel {
    private var innerDate: Date

    var totalDays: Int//当前月的天数
    var firstWeekday: Int//第一天是星期几（0代表周日，1代表周一，以此类推）
    var month: Int
    var year: Int
    
    init(_ date: Date) {
        innerDate = date
        totalDays = innerDate.daysInMonth ?? 0
        firstWeekday = innerDate.firstWeekDayInMonth ?? 0
        month = innerDate.month ?? 0
        year = innerDate.year ?? 0
    }
}


