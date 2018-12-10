//
//  SSFireworks.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/1.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation


class SSFireworks {
    
    private static let TAG = 3333
    class func fire(_ view: UIView, image: UIImage? = nil) {
        if let _ = view.viewWithTag(TAG) { return }
        let emitterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        emitterView.backgroundColor = UIColor.clear
        emitterView.tag = TAG
        emitterView.isUserInteractionEnabled = false
        view.addSubview(emitterView)
        
        let bg = UIView(frame: view.bounds)
        bg.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.addSubview(bg)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            bg.removeFromSuperview()
            emitterView.removeFromSuperview()
        }
        
        let layer = FireworksLayer(bg, window: emitterView)
        layer.startAnimation()
    }
}

private class FireworksLayer: CAEmitterLayer {
    
    private let red = UIColor(red: 1, green: 0, blue:0.545098, alpha: 1)
    private let yellow = UIColor(red: 0.984313, green: 0.772549, blue: 0.050980, alpha: 1)
    private let blue = UIColor(red: 0.196078, green: 0.666667, blue: 0.803921, alpha: 1)
    

    init(_ view: UIView, window: UIView) {
        super.init()
        
        let tmp = UIImage(named: "success_star")!
        let cell1 = subCell(from: image(with: red) ?? tmp)
        cell1.name = "red"
        let cell2 = subCell(from: image(with: yellow) ?? tmp)
        cell2.name = "yellow"
        let cell3 = subCell(from: image(with: blue) ?? tmp)
        cell3.name = "blue"
        let cell4 = subCell(from: tmp)
        cell4.name = "star"
        
        self.emitterPosition = window.center
        self.emitterSize = window.size
        self.emitterMode = .points
        self.emitterShape = .rectangle
        self.renderMode = .oldestFirst
        self.emitterCells = [cell1, cell2, cell3, cell4]
        view.layer.addSublayer(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func image(with color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 13, height: 17)
        UIGraphicsBeginImageContext(rect.size)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func subCell(from image: UIImage) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.name = "heart"
        cell.contents = image.cgImage
        // 缩放比例
        cell.scale = 0.6
        cell.scaleRange = 0.6
        // 每秒产生的数量
        cell.birthRate = 40
        cell.lifetime = 20
        // 秒速
        cell.velocity = 200
        cell.velocityRange = 200
        cell.yAcceleration = 9.8
        cell.xAcceleration = 0
        //掉落的角度范围
        cell.emissionRange = .pi
        cell.scaleSpeed = -0.05
        cell.spin = 2 * .pi
        cell.spinRange = 2 * .pi
        return cell
    }

    fileprivate func startAnimation() {
        let redBurst = CABasicAnimation(keyPath: "emitterCells.red.birthRate")
        redBurst.fromValue = NSNumber(value: 50)
        redBurst.toValue = NSNumber(value: 0)
        redBurst.duration = 0.5
        redBurst.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let yellowBurst = CABasicAnimation(keyPath: "emitterCells.yellow.birthRate")
        yellowBurst.fromValue = NSNumber(value: 50)
        yellowBurst.toValue = NSNumber(value: 0)
        yellowBurst.duration = 0.5
        yellowBurst.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let blueBurst = CABasicAnimation(keyPath: "emitterCells.blue.birthRate")
        blueBurst.fromValue = NSNumber(value: 50)
        blueBurst.toValue = NSNumber(value: 0)
        blueBurst.duration = 0.5
        blueBurst.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let starBurst = CABasicAnimation(keyPath: "emitterCells.star.birthRate")
        starBurst.fromValue = NSNumber(value: 70)
        starBurst.toValue = NSNumber(value: 0)
        starBurst.duration = 0.5
        starBurst.timingFunction = CAMediaTimingFunction(name: .linear)
        
        let group = CAAnimationGroup()
        group.animations = [redBurst, yellowBurst, blueBurst, starBurst]
        self.add(group, forKey: nil)
    }
}
