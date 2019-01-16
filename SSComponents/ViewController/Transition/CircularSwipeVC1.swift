//
//  CircularSwipeVC1.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/13.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class CircularSwipeVC1: UIViewController, UINavigationControllerDelegate {

    var btn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: UIScreen.width - 50 - 20, y: 60, width: 50, height: 50)
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.white
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        self.view.backgroundColor = UIColor.SSStyle
        self.view.addSubview(btn)
        
        let btn1 = UIButton(frame: CGRect(x: self.view.width * 0.5, y: self.view.height * 0.5, width: 100, height: 30))
        btn1.setTitle("back", for: .normal)
        btn1.setTitleColor(UIColor.blue, for: .normal)
        btn1.addTarget(self, action: #selector(toAction), for: .touchUpInside)
        self.view.addSubview(btn1)
    }
    
    @objc private func btnAction() {
        self.navigationController?.pushViewController(CircularSwipeVC2(), animated: true)
    }
    
    @objc private func toAction() {
        self.dismiss(animated: true, completion: nil)
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return SSCircularSwipe.init(type: .push)
        }
        return nil
    }
}
