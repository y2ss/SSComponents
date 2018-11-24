//
//  DragBadgeViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/19.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class DragBadgeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.width, height: 300)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        let badge = SSDragBadgeView(frame: CGRect(x: self.view.width * 0.5, y: 400, width: 25, height: 25))
        badge.text = "2"
        self.view.addSubview(badge)
        self.view.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Test\(indexPath.row)"
        
        if indexPath.row == 0 {
            let badge = SSDragBadgeView(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
            badge.text = "1"
            badge.center = CGPoint(x: cell.contentView.width * 0.9, y: 40)
            cell.contentView.addSubview(badge)
        } else {
            let badge = SSDragBadgeView(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
            badge.text = "1"
            let container = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
            container.addSubview(badge)
            badge.center = CGPoint.init(x: 25, y: 25)
            cell.accessoryView = container
        }
        return cell
    }
}
