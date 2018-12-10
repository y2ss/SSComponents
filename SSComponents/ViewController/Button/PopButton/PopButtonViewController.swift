//
//  PopButtonViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/24.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class PopButtonViewController: UIViewController {
    
    private var roundedBtn: SSPopButton!
    private var plainBtn: SSPopButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.SSStyle
        roundedBtn = SSPopButton(frame: CGRect(x: 100, y: 100, width: 30, height: 30), type: .menu, style: .round, animate: true)
        roundedBtn.roundBackgroundColor = UIColor.white
        roundedBtn.lineThickness = 3
        roundedBtn.lineRadius = 1
        roundedBtn.tintColor = UIColor.SSStyle
        roundedBtn.addTarget(self, action: #selector(randomRound), for: .touchUpInside)
        self.view.addSubview(roundedBtn)
      
        plainBtn = SSPopButton(frame: CGRect(x: 200, y: 100, width: 30, height: 30), type: .add, style: .plain, animate: false)
        plainBtn.lineThickness = 2
        plainBtn.tintColor = UIColor.white
        plainBtn.backgroundColor = UIColor.clear
        plainBtn.addTarget(self, action: #selector(randomPlain), for: .touchUpInside)
        self.view.addSubview(plainBtn)
    }
    
    @IBAction func onButonAction(_ sender: UIButton) {
        if sender.tag != 21 {
            plainBtn.animate(to: PopButtonType(rawValue: sender.tag) ?? .default)
            roundedBtn.animate(to: PopButtonType(rawValue: sender.tag) ?? .default)
        } else {
            roundedBtn.animate(to: PopButtonType(rawValue: Int(arc4random() % 21)) ?? .default)
            plainBtn.animate(to: PopButtonType(rawValue: Int(arc4random() % 21)) ?? .default)
        }
    }
    
    @objc private func randomRound() {
        roundedBtn.animate(to: PopButtonType(rawValue: Int(arc4random() % 21)) ?? .default)
    }
    
    @objc private func randomPlain() {
        plainBtn.animate(to: PopButtonType(rawValue: Int(arc4random() % 21)) ?? .default)
    }
    
}
