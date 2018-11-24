//
//  SloppySwipeVC2.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/23.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SloppySwipeVC2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.green
        let btn1 = UIButton.init(frame: CGRect.init(x: self.view.width * 0.5, y: self.view.height * 0.5, width: 100, height: 30))
        btn1.setTitle("back", for: .normal)
        btn1.setTitleColor(UIColor.blue, for: .normal)
        btn1.addTarget(self, action: #selector(toAction), for: .touchUpInside)
        self.view.addSubview(btn1)
    }
    
    @objc private func toAction() {
        self.navigationController?.popViewController(animated: true)
    }
    

}
