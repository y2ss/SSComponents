//
//  ViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        test1()
    }

    private func test1() {
        let v1 = UIView()
        v1.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: self.view.height)
        v1.tag = 1
        self.view.addSubview(v1)
        
        let v2 = UIView()
        v2.frame = CGRect.init(x: 0, y: 0, width: self.view.width * 0.5, height: self.view.height)
        v2.tag = 2

        v1.addSubview(v2)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        v2.addGestureRecognizer(tap)
    }
    
    @objc func tapAction() {
        print(view.responderChainDescription())
    }
    
    private func test2() {
        
    }
    
}


