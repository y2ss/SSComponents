//
//  SSCalendarCell.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/16.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SSCalendarCell: UICollectionViewCell {
    
    enum MonthType {
        case thisMonth
        case previousMonth
        case nextMonth
    }
    
    var todayDay: Int {
        return Int(todayLabel.text ?? "0") ?? 0
    }
    
    private var todayLabel: UILabel! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        if todayLabel == nil {
            todayLabel = UILabel.init(frame: self.bounds)
            todayLabel.textAlignment = .center
            todayLabel.font = UIFont.systemFont(ofSize: 15)
            todayLabel.backgroundColor = UIColor.clear
        }
        self.addSubview(todayLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setToday(_ enable: Bool, today: String) {
        todayLabel.text = today
        todayLabel.textColor = enable ? UIColor(white: 0, alpha: 0.87) : UIColor(hex: 0xffadadad)
        isUserInteractionEnabled = enable
    }
    
    private func refresh() {
        
    }
    
    func setupCell(_ model: [Any], type: MonthType, row: Int) {
        refresh()
        
        let monthInfo: SSCalendarModel
        let totalDaysOflastMonth: Int

        if type == .previousMonth {
            monthInfo = model[0] as! SSCalendarModel
            totalDaysOflastMonth = model[3] as! Int
        } else if type == .thisMonth {
            monthInfo = model[1] as! SSCalendarModel
            totalDaysOflastMonth = (model[0] as! SSCalendarModel).totalDays
        } else {
            monthInfo = model[2] as! SSCalendarModel
            totalDaysOflastMonth = (model[1] as! SSCalendarModel).totalDays
        }
        
        let firstWeekDay = monthInfo.firstWeekday// 该月第一天是星期几
        let totalDays = monthInfo.totalDays// 该月有几天
        
        if row >= firstWeekDay && row < firstWeekDay + totalDays {
            let today = String(format: "%02d", (row - firstWeekDay + 1))
            setToday(true, today: today)
            isUserInteractionEnabled = true
        } else if row < firstWeekDay {
            let today = String(format: "%02d", totalDaysOflastMonth - (firstWeekDay - row) + 1)
            setToday(false, today: today)
            isUserInteractionEnabled = false
        } else if row >= firstWeekDay + totalDays {
            let today = String(format: "%02d", row - firstWeekDay - totalDays + 1)
            setToday(false, today: today)
            isUserInteractionEnabled = false
        }
        
        if type != .thisMonth {
            isUserInteractionEnabled = false
        }
    }

}
