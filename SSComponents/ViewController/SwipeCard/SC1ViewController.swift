//
//  SC1ViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/19.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SC1ViewController: UIViewController {
    
    var swipeableView: SwipeableView!
    private let colors = [
        UIColor(red: 0.10196078431372549, green: 0.7372549019607844, blue: 0.611764705882353, alpha: 1.0),
        UIColor(red: 0.08627450980392157, green: 0.6274509803921569, blue: 0.5215686274509804, alpha: 1.0),
        UIColor(red: 0.1803921568627451, green: 0.8, blue: 0.44313725490196076, alpha: 1.0),
        UIColor(red: 0.15294117647058825, green: 0.6823529411764706, blue: 0.3764705882352941, alpha: 1.0),
        UIColor(red: 0.20392156862745098, green: 0.596078431372549, blue: 0.8588235294117647, alpha: 1.0),
        UIColor(red: 0.1607843137254902, green: 0.5019607843137255, blue: 0.7254901960784313, alpha: 1.0)
    ]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        swipeableView = SwipeableView()
        swipeableView.frame = CGRect(x: 0, y: 0, width: UIScreen.width - 100, height: UIScreen.height - 250)
        swipeableView.center = self.view.center
        view.addSubview(swipeableView)
        swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction), vector: \(vector)")
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            print("Did tap at location \(location)")
        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        }
    }
    
    var colorIdx = 0
    func nextCardView() -> UIView? {
        let cardView = SwipeCardView.init(frame: swipeableView.bounds)
        cardView.backgroundColor = colors[colorIdx]
        colorIdx += 1
        if colorIdx >= colors.count {
            colorIdx = 0
        }
        return cardView

    }

}
