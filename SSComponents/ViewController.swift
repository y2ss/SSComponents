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
        
        //test1()
        //test2()
        //test3()
        test4()
    }

    private func test1() {
        let v1 = UIView()
        v1.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: self.view.height)
        v1.tag = 1
//        v1.backgroundColor = UIColor.gradient(from: UIColor.red, to: UIColor.orange, with: CGSize.init(width: v1.width, height: 0))
        let layer = CAGradientLayer.createGradientLayer(v1.frame, direction: .fromTop, colors: [UIColor.red, UIColor.orange, UIColor.yellow])
        self.view.layer.addSublayer(layer)
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
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: 0, y: 0))
        path.addLine(to: CGPoint.init(x: self.view.width * 0.5, y: self.view.height * 0.3))
        path.addLine(to: CGPoint.init(x: self.view.width * 0.3, y: self.view.height * 0.6))
        path.stroke()
        print(path.length)
    }
    
    static var _count = 1
    private func test3() {
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 150, height: 40))
        btn.setTitle("购物车", for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.backgroundColor = UIColor.blue
        btn.setImage(UIImage.init(named: "user_online"), for: .normal)
        btn.addTarget(self, action: #selector(tapAction2(_:)), for: .touchUpInside)
        self.view .addSubview(btn)
        btn.badgeFont = UIFont.systemFont(ofSize: 10)
        btn.shouldAnimateBadge = true
        btn.badgeOriginX = btn.badgeOriginX ?? 0 - 5
        btn.badgeValue = "\(ViewController._count)"
        btn.setImagePosition(.right, spacing: 0)
        btn.touchAreaInsets = UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 50)
        print(btn.touchAreaInsets)
        
    }
    
    @objc private func tapAction2(_ sender: UIButton) {
        ViewController._count += 1
        sender.badgeValue = "\(ViewController._count)"
        sender.touchAreaInsets = nil
        print(sender.touchAreaInsets)
    }
    
    
    private func test4() {
        let view = UIImageView.init(frame: self.view.bounds)
        if let pdf_filepath = Bundle.main.path(forResource: "test.pdf", ofType: nil) {
            //let image = UIImag
            if let image = UIImage.pdfConvertImage(with: pdf_filepath, for: view.bounds.size) {
                view.image = image
            }
        }
        self.view.addSubview(view)
    }
}


