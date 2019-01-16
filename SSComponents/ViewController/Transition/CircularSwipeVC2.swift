//
//  CircularSwipeVC2.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/13.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class CircularSwipeVC2: UIViewController, UINavigationControllerDelegate {

    var btn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 20, y: 60, width: 50, height: 50)
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.SSStyle
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(btn)
    }
    
    @objc private func btnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return SSCircularSwipe.init(type: .pop)
        }
        return nil
    }
}
