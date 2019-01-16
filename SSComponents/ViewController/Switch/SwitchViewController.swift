//
//  SwitchViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/10.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SwitchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let switch1 = SSFlashSwitch.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 40))
        switch1.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.2)
        switch1.isOn = true
        self.view.addSubview(switch1)

    }
    
    @objc private func `switch`(_ sender: SSFlashSwitch) {
        sender.isOn = !sender.isOn
    }

}
