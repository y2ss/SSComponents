//
//  SSCalendarView.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

protocol SSCalendarViewDelegate: class {
    func calendarViewDidChoosenDate(_ date: Date)
}

class SSCalendarView: UIView {
    
    private var topYearMonthView: UIView! = nil//顶部条 年-月 && 今
    private var calendarHeaaderButton: UIButton! = nil//顶部条 “2016年 12月” button
    private var weekHeaderView: UIView! = nil//星期条
    private var calendarScrollView: SSCalendarScrollView! = nil//日历主体
    private var calendarHeight: CGFloat = 0//整个 calender 控件的高度
    
    weak var delegate: SSCalendarViewDelegate?
    
    init(_ origin: CGPoint, width: CGFloat) {
        
        let weekLineHeight = 0.85 * (width / 6.0)//一行的高度
        let monthHeight = 6 * weekLineHeight//主体部分整体高度
        let weekHearderHeight = weekLineHeight * 0.7//星期头部栏高度
        let calendarHeaderHeight = weekLineHeight * 0.7//calendar 头部栏高度
        calendarHeight = calendarHeaderHeight + weekHearderHeight + monthHeight
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: width, height: calendarHeight))
        
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor(hex: 0xffe7e7e7).cgColor
        self.layer.borderWidth = 2.0 / UIScreen.main.scale
        
        
        // 顶部
        topYearMonthView = setupCalendarHeaderWithFrame(frame: CGRect(x: 0, y: 0, width: width, height: calendarHeaderHeight))
        // 顶部星期条
        weekHeaderView = setupWeekHeadViewWithFrame(frame: CGRect(x: 0,
                                                                  y: calendarHeaderHeight,
                                                                  width: width,
                                                                  height: weekHearderHeight))
        // 底部月历滚动scroll
        calendarScrollView = SSCalendarScrollView(frame: CGRect(x: 0,
                                                                y: calendarHeaderHeight + weekHearderHeight,
                                                                width: width,
                                                                height: monthHeight))
        calendarScrollView.cDelegate = self
        self.addSubview(topYearMonthView)
        self.addSubview(weekHeaderView)
        self.addSubview(calendarScrollView)
        refreshToCurrentMonthAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置顶部条，显示 年-月 的
    private func setupCalendarHeaderWithFrame(frame: CGRect) -> UIView {
        let backView = UIView(frame: frame)
        backView.backgroundColor = UIColor.white
        
        let yearMonthButton = UIButton(type: .custom)
        yearMonthButton.frame = CGRect(x: 0, y: 0, width: 120, height: frame.size.height)
        yearMonthButton.setTitleColor(UIColor(hex: 0xff343434), for: .normal)
        yearMonthButton.backgroundColor = UIColor.clear
        yearMonthButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        yearMonthButton.center = backView.center
        backView.addSubview(yearMonthButton)
        calendarHeaaderButton = yearMonthButton
        return backView
    }
    
    //设置星期条，显示 日 一 二 ... 五 六
    private func setupWeekHeadViewWithFrame(frame: CGRect) -> UIView {
        let height = frame.size.height
        let width = frame.size.width / 7.0
        
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.white
        
        let weekArray = ["日", "一", "二", "三", "四", "五", "六"]
        for i in 0 ..< 7 {
            let label = UILabel(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height - 10))
            label.backgroundColor = UIColor.clear
            label.text = weekArray[i]
            if label.text == "日" || label.text == "六" {
                label.textColor = UIColor(hex: 0xff3CB0FF)
            } else {
                label.textColor = UIColor(hex: 0xff343434)
            }
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = .center
            view.addSubview(label)
        }
        
        let cutoff = UILabel()
        cutoff.frame = CGRect(x: 0, y: frame.height - 2, width: frame.width, height: 0.5)
        cutoff.backgroundColor = UIColor(hex: 0xffe7e7e7)
        view.addSubview(cutoff)
        return view
    }
    
    //改变 顶部年月栏 的日期显示 && 滚动到当前月份
    private func refreshToCurrentMonthAction(sender: UIButton? = nil) {
        // 设置显示日期
        let year = Date().year ?? 0
        let month = Date().month ?? 0
        let title = String("\(year)年 \(month)月")
        calendarHeaaderButton.setTitle(title, for: .normal)
        
        //进行滑动
        calendarScrollView.refreshToCurrentMonth()
    }
}

extension SSCalendarView: SSCalendarScrollViewDelegate {
    func calendarViewDidChangedDate(_ year: Int, month: Int) {
        let title = String("\(year)年 \(month)月")
        calendarHeaaderButton.setTitle(title, for: .normal)
    }
    
    func calendarViewDidChoosenDate(day: Int, month: Int, year: Int) {
        let dateString = String(format: "%4d-%2d-%2d 00:00:00", year, month, day)
        guard let date = DateFormatter.default.date(from: dateString) else { return }
        delegate?.calendarViewDidChoosenDate(date)
    }
    
}
