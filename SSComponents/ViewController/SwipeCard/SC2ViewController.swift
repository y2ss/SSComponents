//
//  SC2ViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/19.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SC2ViewController: SC1ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        func toRadian(_ degree: CGFloat) -> CGFloat {
            return degree * CGFloat(M_PI/180)
        }
        
        func rotateAndTranslateView(_ view: UIView, forDegree degree: CGFloat, translation: CGPoint, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: SwipeableView) {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                transform = transform.rotated(by: toRadian(degree))
                transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                transform = transform.translatedBy(x: translation.x, y: translation.y)
                view.transform = transform
            }, completion: nil)
        }
        
        swipeableView.numberOfActiveView = 10
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: SwipeableView) in
            let degree = CGFloat(sin(0.5*Double(index)))
            let offset = CGPoint(x: 0, y: swipeableView.bounds.height*0.3)
            let translation = CGPoint(x: degree*10, y: CGFloat(-index*5))
            let duration = 0.4
            rotateAndTranslateView(view, forDegree: degree, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }

    }

}
