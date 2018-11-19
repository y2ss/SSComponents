//
//  SwipeCardViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/19.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SwipeCardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!
    private let titles = [
        "Default",
        "Custom Animation",
        "Allowed Direction"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(SC1ViewController(), animated: true)
            break
        case 1:
            self.navigationController?.pushViewController(SC2ViewController(), animated: true)
            break
        case 2:
            self.navigationController?.pushViewController(SC3ViewController(), animated: true)
            break
        default:
            break
        }
    }

}
