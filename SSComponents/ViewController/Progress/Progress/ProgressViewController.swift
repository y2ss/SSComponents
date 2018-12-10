//
//  ProgressViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/4.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    
    private var progress: Double = 0
    private var cd: SSProgress!
    private var ci: SSProgress!
    private var ld: SSProgress!
    private var li: SSProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        cd = SSProgress.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        cd.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.25)
        cd.progress = 0
        cd.type = .determinate
        cd.progressColor = UIColor.SSStyle
        self.view.addSubview(cd)
        
        ci = SSProgress.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        ci.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.5)
        ci.style = .circular
        ci.type = .indeterminate
        ci.progressColor = UIColor.SSStyle
        ci.progress = 0
        self.view.addSubview(ci)
        
        ld = SSProgress.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width * 0.7, height: 30), type: .determinate)
        ld.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.7)
        ld.style = .linear
        ld.progressColor = UIColor.SSStyle
        ld.progress = 0
        self.view.addSubview(ld)
        
        li = SSProgress.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width * 0.7, height: 30), type: .indeterminate)
        li.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.9)
        li.style = .linear
        li.progressColor = UIColor.SSStyle
        li.progress = 0
        self.view.addSubview(li)
        
        simulateProgress()
    }

    private func simulateProgress() {
        let val: Double = Double(arc4random_uniform(5) + 1) / Double(100)
        progress += val
        if progress > 1 {
            cd.progress = 1
            ld.progress = 1
            progress = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.simulateProgress()
            }
        } else {
            cd.progress = CGFloat(progress)
            ld.progress = CGFloat(progress)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.simulateProgress()
            }
        }
    }
}
