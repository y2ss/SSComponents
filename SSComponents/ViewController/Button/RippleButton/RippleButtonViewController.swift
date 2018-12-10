//
//  RippleButtonViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/3.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class RippleButtonViewController: UIViewController {
    
    private var bottomView: UIView!
    private var btn: SSRippleButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let btn1 = SSRippleButton.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 50), type: .flat)
        btn1.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.3)
        btn1.setTitle("Flat Button", for: .normal)
        btn1.setTitleColor(UIColor.SSStyle, for: .normal)
        self.view.addSubview(btn1)
        
        let btn2 = SSRippleButton.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 50), type: .raised)
        btn2.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.52)
        btn2.backgroundColor = UIColor.SSStyle
        btn2.setTitle("Raised Button", for: .normal)
        btn2.setTitleColor(UIColor.white, for: .normal)
        self.view.addSubview(btn2)
        
        let btn3 = SSRippleButton.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100), type: .floating)
        btn3.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.75)
        btn3.backgroundColor = UIColor.SSStyle
        btn3.setTitleColor(UIColor.white, for: .normal)
        btn3.setTitle("Float", for: .normal)
        btn3.addTarget(self, action: #selector(goahead(_:)), for: .touchUpInside)
        self.view.addSubview(btn3)
        btn = btn3
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: UIScreen.height - 60, width: UIScreen.width, height: 60))
        view.backgroundColor = UIColor.SSStyle
        view.isHidden = true
        view.isUserInteractionEnabled = true
        let tag = UITapGestureRecognizer.init(target: self, action: #selector(backoff))
        view.addGestureRecognizer(tag)
        self.view.addSubview(view)
        bottomView = view
    }
    
    @objc private func goahead(_ button: SSRippleButton) {
        let duration: TimeInterval = 0.2
        let center = button.center
        CATransaction.begin()
        bottomView.layer.removeAllAnimations()
        button.layer.removeAllAnimations()
        
        let anim = CABasicAnimation.init(keyPath: "position")
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        
        let endPoint = bottomView.center
        anim.fromValue = NSValue.init(cgPoint: center)
        anim.toValue = NSValue.init(cgPoint: endPoint)
        anim.duration = duration
        
        CATransaction.setCompletionBlock {
            CATransaction.begin()
            self.bottomView.alpha = 1
            self.bottomView.isHidden = false
            button.isHidden = true
            
            let circle = CAShapeLayer()
            let ratio = button.width / self.bottomView.width
            let width = self.bottomView.width
            let path = UIBezierPath.init(ovalIn: CGRect.init(x: self.bottomView.centerX - button.width * 0.5, y: -(self.bottomView.width * ratio) * 0.5 + self.bottomView.height * 0.5, width: width * ratio, height: width * ratio))
            circle.path = path.cgPath
            circle.fillColor = UIColor.black.cgColor
            self.bottomView.layer.mask = circle
            
            let _rect = CGRect.init(x: 0, y: -self.bottomView.width * 0.5 + self.bottomView.height * 0.5, width: width, height: width)
            
            let cAnim = CABasicAnimation.init(keyPath: "path")
            cAnim.toValue = UIBezierPath.init(ovalIn: _rect).cgPath
            cAnim.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
            cAnim.autoreverses = false
            cAnim.repeatCount = 1
            cAnim.duration = duration * 0.5
            cAnim.fillMode = .forwards
            cAnim.isRemovedOnCompletion = false
            
            CATransaction.setCompletionBlock({
                self.bottomView.layer.mask = nil
                self.bottomView.isUserInteractionEnabled = true
            })
            circle.add(cAnim, forKey: cAnim.keyPath)
            CATransaction.commit()
        }
        button.layer.add(anim, forKey: anim.keyPath)
        CATransaction.commit()
    }
    
    @objc private func backoff() {
        let duration = 0.2
        let center = btn.center
        
        let circle = CAShapeLayer()
        let width = bottomView.width
        let path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: -self.bottomView.width * 0.5 + self.bottomView.height * 0.5, width: width, height: width))
        circle.path = path.cgPath
        circle.fillColor = UIColor.black.cgColor
        bottomView.layer.mask = circle
        
        CATransaction.begin()
        let ratio = btn.width / bottomView.width
        let _rect = CGRect.init(x: self.bottomView.centerX - self.btn.bounds.width * 0.5, y: -(self.bottomView.width * ratio) * 0.5 + self.bottomView.height * 0.5
            , width: width * ratio, height: width * ratio)
        let cAnim = CABasicAnimation.init(keyPath: "path")
        cAnim.toValue = UIBezierPath.init(ovalIn: _rect).cgPath
        cAnim.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        cAnim.autoreverses = false
        cAnim.repeatCount = 1
        cAnim.duration = duration
        cAnim.isRemovedOnCompletion = false
        cAnim.fillMode = .forwards
        
        CATransaction.setCompletionBlock {
            self.btn.layer.removeAllAnimations()
            self.bottomView.isHidden = true
            self.bottomView.isUserInteractionEnabled = false
            self.btn.isHidden = false
            self.bottomView.layer.removeAllAnimations()
            
            let anim = CABasicAnimation.init(keyPath: "position")
            anim.fillMode = .forwards
            anim.isRemovedOnCompletion = false
            anim.autoreverses = false
            anim.repeatCount = 1
            anim.fromValue = NSValue.init(cgPoint: self.bottomView.center)
            anim.toValue = NSValue.init(cgPoint: center)
            anim.duration = duration
            self.btn.layer.add(anim, forKey: anim.keyPath)
        }
        circle.add(cAnim, forKey: cAnim.keyPath)
        CATransaction.commit()
        
    }
    
    deinit {
        print("deinit")
    }
}
