//
//  SC3ViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/19.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SC3ViewController: SC1ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentControl = UISegmentedControl(items: [" ", "←", "↑", "→", "↓", "↔︎", "↕︎", "☩"])
        segmentControl.selectedSegmentIndex = 5
        navigationItem.titleView = segmentControl
        
        segmentControl.addTarget(self, action: #selector(segmentedControlFired), for: .valueChanged)
        
        swipeableView.interpretDirection = {(topView: UIView, direction: SwipeableViewManager.Direction, views: [UIView], swipeableView: SwipeableView) in
            let programmaticSwipeVelocity = CGFloat(500)
            let location = CGPoint(x: topView.center.x-30, y: topView.center.y*0.1)
            var directionVector: CGVector?
            switch direction {
            case .Left:
                directionVector = CGVector(dx: -CGFloat(100), dy: 0)
            case .Right:
                directionVector = CGVector(dx: programmaticSwipeVelocity, dy: 0)
            case .Up:
                directionVector = CGVector(dx: 0, dy: -programmaticSwipeVelocity)
            case .Down:
                directionVector = CGVector(dx: 0, dy: programmaticSwipeVelocity)
            default:
                directionVector = CGVector(dx: 0, dy: 0)
            }
            return (location, directionVector!)
        }
    }

    @objc func segmentedControlFired(control: AnyObject?) {
        if let control = control as? UISegmentedControl {
            let directions: [SwipeableViewManager.Direction] = [.None, .Left, .Up, .Right, .Down, .Horizontal, .Vertical, .All]
            self.swipeableView.allowedDirection = directions[control.selectedSegmentIndex]
        }
    }
}
