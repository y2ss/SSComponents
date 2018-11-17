//
//  SSCalendarScrollView.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/16.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

protocol SSCalendarScrollViewDelegate: class {
    func calendarViewDidChangedDate(_ year: Int, month: Int)
    func calendarViewDidChoosenDate(day: Int, month: Int, year: Int)
}

class SSCalendarScrollView: UIScrollView {
     
    private var collectionViewL: UICollectionView!
    private var collectionViewM: UICollectionView!
    private var collectionViewR: UICollectionView!
    private let cellIdentifier = "calendarCell"
    
    private var currentMonthDate: Date!
    private var monthArray = [Any]()
    
    weak var cDelegate: SSCalendarScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        currentMonthDate = Date()
        setup()
        setupMonthArray()
        setupCollectionViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isPagingEnabled = true
        self.bounces = false
        self.delegate = self
        self.contentSize = CGSize(width: 3 * self.bounds.size.width, height: self.bounds.size.height)
        self.setContentOffset(CGPoint(x: self.bounds.size.width, y: 0), animated: false)
    }
    
    private func setupMonthArray() {
        if monthArray.count == 0 {
            refreshMonthData()
            notificationCalendarHeaderChanged()
        }
    }
    
    private func setupCollectionViews() {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: self.bounds.size.width / 7, height: self.bounds.size.width / 7 * 0.95)
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        
        let selfWidth = self.bounds.size.width
        let selfHeight = self.bounds.size.height
        
        collectionViewL = UICollectionView(frame: CGRect(x: 0, y: 0, width: selfWidth, height: selfHeight), collectionViewLayout: flowlayout)
        collectionViewL.dataSource = self
        collectionViewL.delegate = self
        collectionViewL.backgroundColor = UIColor.clear
        collectionViewL.register(SSCalendarCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.addSubview(collectionViewL)
        
        collectionViewM = UICollectionView(frame: CGRect(x: selfWidth, y: 0, width: selfWidth, height: selfHeight), collectionViewLayout: flowlayout)
        collectionViewM.dataSource = self
        collectionViewM.delegate = self
        collectionViewM.backgroundColor = UIColor.clear
        collectionViewM.register(SSCalendarCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.addSubview(collectionViewM)
        
        collectionViewR = UICollectionView(frame: CGRect(x: 2 * selfWidth, y: 0, width: selfWidth, height: selfHeight), collectionViewLayout: flowlayout)
        collectionViewR.dataSource = self
        collectionViewR.delegate = self
        collectionViewR.backgroundColor = UIColor.clear
        collectionViewR.register(SSCalendarCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.addSubview(collectionViewR)
    }
    
    // 传入date，然后拿到date的上个月份的总天数
    private func previousMonthDaysForPreviousDate(date: Date) -> Int {
        if let day = date.previousMonthDate?.daysInMonth {
            return day
        }
        return 0
    }
    
    private func refreshMonthData() {
        currentMonthDate = Date()
        if
            let previousMonthDate = currentMonthDate.previousMonthDate,
            let nextMonthDate = currentMonthDate.nextMonthDate {
            
            monthArray.append(SSCalendarModel(previousMonthDate))
            monthArray.append(SSCalendarModel(currentMonthDate))
            monthArray.append(SSCalendarModel(nextMonthDate))
            //// 存储左边的月份的前一个月份的天数，用来填充左边月份的首部（这里获取的其实是当前月的上上个月）
            monthArray.append(previousMonthDaysForPreviousDate(date: previousMonthDate))
        }
    }
    
    func refreshToCurrentMonth() {
        // 如果现在就在当前月份，则不执行操作
        let currentMonthInfo = monthArray[1] as! SSCalendarModel
        guard let month = Date().month, let year = Date().year else { return }
    
        if currentMonthInfo.month == month && currentMonthInfo.year == year { return }

        refreshMonthData()
        collectionViewL.reloadData()
        collectionViewM.reloadData()
        collectionViewR.reloadData()
    }
    

    private func notificationCalendarHeaderChanged() {
        let currentMonthInfo = monthArray[1] as! SSCalendarModel
        cDelegate?.calendarViewDidChangedDate(currentMonthInfo.year, month: currentMonthInfo.month)
    }
}

extension SSCalendarScrollView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! SSCalendarCell
        if collectionView == collectionViewL {
            cell.setupCell(monthArray, type: .previousMonth, row: indexPath.row)
        } else if collectionView == collectionViewM {
            cell.setupCell(monthArray, type: .thisMonth, row: indexPath.row)
        } else {
            cell.setupCell(monthArray, type: .nextMonth, row: indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SSCalendarCell
        guard let year = currentMonthDate.year, let month = currentMonthDate.month else { return }
        cDelegate?.calendarViewDidChoosenDate(day: cell.todayDay, month: month, year: year)
    }
}

extension SSCalendarScrollView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != self { return }
        
        /**
         注意 ： 当前月份当前天 == 现在这一天     当前显示月份 == 当前界面上显示的那个月份
         假设 当天为 2012年12月12日 那么当前显示的日历为 11月 | 12月 | 1月
         原本的monthArray = [11月monthInfo， 12月monthInfo， 1月monthInfo， 10月份天数];
         说明一下：为什么要传入10月份的天数，因为左侧显示部分会带有10月份后面几天，而1月份后面显示的会有2月份的前几天。由于每个月前几天是确定的，而后几天不确定，所以说数组中要加上这么一个参数。
         */
        // 左滑动
        if scrollView.contentOffset.x < self.bounds.size.width {
            
            guard
                let previousMonthDate = currentMonthDate.previousMonthDate,
                let prepreMonthDate = previousMonthDate.previousMonthDate else { return }
            
            currentMonthDate = previousMonthDate// currentMonthDate 12月15日（向右滑动之后，原本显示在左侧的上个月就变成了当前显示的月份，原本的_currentMonthDate是当前月份当前天，但是向右滑动之后就变成了左侧月份的15号这一天）== 11月份
            let previousDate = prepreMonthDate// previousDate 10月15日（又进行了一次取前一月份15日的操作，在上面一句的基础上）== 10月份
            
            // 取数组中的值（该数组还是滑动之前的）
            let currentMonthInfo = monthArray[0] as! SSCalendarModel// currentMothInfo 11月
            let nextmonthInfo = monthArray[1] as! SSCalendarModel// nextMonthInfo 12月
            let olderNextmonthInfo = monthArray[2] as! SSCalendarModel// olderNextMonthInfo 1月
        
            guard
                let daysInMonth = previousDate.daysInMonth,
                let firstWeekDayInMonth = previousDate.firstWeekDayInMonth,
                let year = previousDate.year,
                let month = previousDate.month else { return }
            
            olderNextmonthInfo.totalDays = daysInMonth
            olderNextmonthInfo.firstWeekday = firstWeekDayInMonth
            olderNextmonthInfo.year = year
            olderNextmonthInfo.month = month
            let previousMonthInfo = olderNextmonthInfo// previousMonthInfo == olderNextMonthInfo == 10月份信息
            
            guard let _previous = currentMonthDate.previousMonthDate else { return }
            
            let prePreviousMonthDays = previousMonthDaysForPreviousDate(date: _previous)// prePreviousMonthDays 拿到9月份的天数 （后面的传值是10月15日）
            monthArray.removeAll()
            monthArray.append(previousMonthInfo)
            monthArray.append(currentMonthInfo)
            monthArray.append(nextmonthInfo)
            monthArray.append(prePreviousMonthDays)
            
            // 新的 monthArray = [10月monthInfo， 11月monthInfo， 12月monthInfo， 9月份天数];
        } else if scrollView.contentOffset.x > self.bounds.size.width {// 右滑动
            guard
                let nextMonth = currentMonthDate.nextMonthDate,
                let nexnextMonth = nextMonth.nextMonthDate else { return }
            
            currentMonthDate = nextMonth
            let nextDate = nexnextMonth
            
            // 数组中最右边的月份现在作为中间的月份，中间的作为左边的月份，新的右边的需要重新获取
            let previousMonthInfo = monthArray[1] as! SSCalendarModel
            let currentMonthInfo = monthArray[2] as! SSCalendarModel
            let olderPreviousMonthInfo = monthArray[0] as! SSCalendarModel
            let prePreviousMonthDays = olderPreviousMonthInfo.totalDays
            
            guard
                let daysInMonth = nextDate.daysInMonth,
                let firstWeekDayInMonth = nextDate.firstWeekDayInMonth,
                let year = nextDate.year,
                let month = nextDate.month else { return }
            
            olderPreviousMonthInfo.totalDays = daysInMonth
            olderPreviousMonthInfo.firstWeekday = firstWeekDayInMonth
            olderPreviousMonthInfo.year = year
            olderPreviousMonthInfo.month = month
            
            let nextmonthInfo = olderPreviousMonthInfo
            
            monthArray.removeAll()
            monthArray.append(previousMonthInfo)
            monthArray.append(currentMonthInfo)
            monthArray.append(nextmonthInfo)
            monthArray.append(prePreviousMonthDays)
        }
        
        collectionViewM.reloadData()// 中间的 collectionView 先刷新数据
        scrollView.setContentOffset(CGPoint(x: self.bounds.size.width, y: 0), animated: false)
        collectionViewL.reloadData()// 最后两边的 collectionView 也刷新数据
        collectionViewR.reloadData()
        
        notificationCalendarHeaderChanged()
    }
}
