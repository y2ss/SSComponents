//
//  SloppySwipeVC1.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/23.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SloppySwipeVC1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        let btn1 = UIButton(frame: CGRect(x: self.view.width * 0.5, y: self.view.height * 0.5, width: 100, height: 30))
        btn1.setTitle("back", for: .normal)
        btn1.setTitleColor(UIColor.blue, for: .normal)
        btn1.addTarget(self, action: #selector(toAction), for: .touchUpInside)
        self.view.addSubview(btn1)
        
        let btn2 = UIButton(frame: CGRect(x: self.view.width * 0.5, y: self.view.height * 0.7, width: 100, height: 30))
        btn2.setTitle("go", for: .normal)
        btn2.setTitleColor(UIColor.blue, for: .normal)
        btn2.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        self.view.addSubview(btn2)
    }
    
    @objc private func toAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func addAction() {
        self.navigationController?.pushViewController(SloppySwipeVC2(), animated: true)
    }
}
