//
//  TransitionViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/23.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class TransitionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var swipe: SSSloppySwiper!
    private var tableView: UITableView!
    private var nav: UINavigationController!
    private let dataSource = [
        "SloppySwipe",
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = SloppySwipeVC1()
        let nav = UINavigationController.init(rootViewController: vc)
        swipe = SSSloppySwiper.init(navigationController: nav)
        nav.delegate = swipe
        self.nav = nav
        
        tableView = UITableView()
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.present(nav, animated: true, completion: nil)
            break
        default:
            break
        }
    }

}
