//
//  SSTwinkle.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/1.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation


class SSTwinkle {
    
    class func twinkle(_ view: UIView, image: UIImage? = nil) {
        var layers: [TwinkleLayer] = []
        let upper: UInt32 = 10
        let lower: UInt32 = 5
        let count = UInt(arc4random_uniform(upper) + lower)
        for i in 0 ..< count {
            let layer = image == nil ? TwinkleLayer() : TwinkleLayer(image: image!)
            let x = CGFloat(arc4random_uniform(UInt32(view.layer.bounds.width)))
            let y = CGFloat(arc4random_uniform(UInt32(view.layer.bounds.height)))
            layer.position = CGPoint(x: x, y: y)
            layer.opacity = 0
            layers.append(layer)
            view.layer.addSublayer(layer)
            
            layer.addPositionAnimation()
            layer.addRotationAnimation()
            layer.addFadeInOutAnimation(CACurrentMediaTime() + CFTimeInterval(0.15 * Float(i)))
        }
        layers.removeAll(keepingCapacity: false)
    }

}

private class TwinkleLayer: CAEmitterLayer {
    
    convenience init(image: UIImage) {
        self.init()
        setup(image)
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(_ image: UIImage? = nil) {
        var twinkleImg: UIImage? = nil
        if let img = image {
            twinkleImg = img
        } else {
            twinkleImg = UIImage(named: "TwinkleImage")
        }
        
        self.emitterCells?.removeAll()
        let emitterCells: [CAEmitterCell] = [CAEmitterCell(), CAEmitterCell()]
        for cell in emitterCells {
            cell.birthRate = 8
            cell.lifetime = 1.25
            cell.lifetimeRange = 0
            cell.emissionRange = .pi / 4
            cell.velocity = 2
            cell.velocityRange = 18
            cell.scale = 0.65
            cell.scaleSpeed = 0.6
            cell.scaleRange = 0.7
            cell.spin = 0.9
            cell.color = UIColor(white: 1, alpha: 0.3).cgColor
            cell.alphaSpeed = -0.8
            cell.contents = twinkleImg?.cgImage
            cell.magnificationFilter = "linear"
            cell.minificationFilter = "trilinear"
            cell.isEnabled = true
        }
        
        self.emitterCells = emitterCells
        self.emitterPosition = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        self.emitterSize = bounds.size
        self.emitterShape = .circle
        self.emitterMode = .surface
        self.renderMode = .unordered
    }
    
    fileprivate func addPositionAnimation() {
        CATransaction.begin()
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.duration = 0.3
        anim.isAdditive = true
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false
        anim.beginTime = CFTimeInterval(arc4random_uniform(1000) + 1) * 0.2 * 0.25
        let points = [
            NSValue(cgPoint: CGPoint.random(0.25)),
            NSValue(cgPoint: CGPoint.random(0.25)),
            NSValue(cgPoint: CGPoint.random(0.25)),
            NSValue(cgPoint: CGPoint.random(0.25)),
            NSValue(cgPoint: CGPoint.random(0.25)),
        ]
        anim.values = points
        add(anim, forKey: nil)
        CATransaction.commit()
    }
    
    fileprivate func addRotationAnimation() {
        CATransaction.begin()
        let anim = CAKeyframeAnimation(keyPath: "transform")
        anim.duration = 0.3
        anim.valueFunction = CAValueFunction(name: .rotateZ)
        anim.isAdditive = true
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false
        anim.beginTime = CFTimeInterval(arc4random_uniform(1000) + 1) * 0.2 * 0.25
        let radians = 0.104
        anim.values = [-radians, radians, -radians]
        add(anim, forKey: nil)
        CATransaction.commit()
    }
    
    fileprivate func addFadeInOutAnimation(_ beginTime: CFTimeInterval) {
        CATransaction.begin()
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.fromValue = 0
        anim.toValue = 1
        anim.repeatCount = 2
        anim.autoreverses = true
        anim.duration = 0.4
        anim.fillMode = .forwards
        anim.beginTime = beginTime
        CATransaction.setCompletionBlock {
            self.removeFromSuperlayer()
        }
        add(anim, forKey: nil)
        CATransaction.commit()
    }
}

private extension CGPoint {
    static func random(_ range: Float) -> CGPoint {
        let x = Int(-range + (Float(arc4random_uniform(1000)) / 1000.0) * 2 * range)
        let y = Int(-range + (Float(arc4random_uniform(1000)) / 1000.0) * 2 * range)
        return CGPoint(x: x, y: y)
    }
}
