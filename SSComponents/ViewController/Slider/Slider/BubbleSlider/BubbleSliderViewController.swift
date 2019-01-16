//
//  BubbleSliderViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/10.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class BubbleSliderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        let slider1 = SSBubbleSlider.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width * 0.7, height: 34))
        slider1.minimumValue = 0
        slider1.maximumValue = 15
        slider1.isEnabledValueLabel = true
        slider1.precisoin = 1
        slider1.value = 4
        slider1.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.3)
        self.view.addSubview(slider1)
        
        let slider2 = SSBubbleSlider.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width * 0.7, height: 34))
        slider2.minimumValue = 0
        slider2.maximumValue = 10
        slider2.isEnabledValueLabel = true
        slider2.precisoin = 0
        slider2.value = 4
        slider2.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.5)
        slider2.step = 1
        self.view.addSubview(slider2)
        
        let slider3 = SSBubbleSlider.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width * 0.7, height: 34))
        slider3.minimumValue = 0
        slider3.maximumValue = 15
        slider3.isEnabledValueLabel = true
        slider3.precisoin = 1
        slider3.value = 4
        slider3.isEnabled = false
        slider3.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.7)
        self.view.addSubview(slider3)
        
    }
}
