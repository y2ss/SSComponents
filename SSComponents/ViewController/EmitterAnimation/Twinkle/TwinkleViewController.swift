//
//  TwinkleViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/1.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class TwinkleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.SSStyle
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 240, height: 50))
        button.center = self.view.center
        button.setTitle("Tap to Twinkle", for: .normal)
        button.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 32)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func handleButton(_ button: UIButton!) {
        SSTwinkle.twinkle(button)
    }

}
