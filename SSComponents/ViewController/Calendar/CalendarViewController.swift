//
//  CalendarViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, SSCalendarViewDelegate {
    
    func calendarViewDidChoosenDate(_ date: Date) {
        print(date)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let calendar = SSCalendarView(CGPoint(x: 0, y: 64 + 80), width: self.view.width)
        calendar.delegate = self
        self.view.addSubview(calendar)
    }

}
