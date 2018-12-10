//
//  RippleTableViewCell.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/3.
//  Copyright © 2018年 y2ss. All rights reserved.
//

class RippleTableViewCell: UITableViewCell {
    
    var rippleColor: UIColor? {
        willSet {
            if let newValue = newValue {
                rippleLayer?.effectColor = newValue
            }
        }
    }
    private var rippleLayer: SSRippleLayer?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initLayer()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayer()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initLayer()
    }
    
    private func initLayer() {
        if let rippleLayer = rippleLayer {
            rippleLayer.removeFromSuperlayer()
            self.rippleLayer = nil
        }
        if rippleColor == nil {
            rippleColor = UIColor(white: 0.5, alpha: 1)
        }
        
        rippleLayer = SSRippleLayer.init(superLayer: self.layer)
        rippleLayer?.effectColor = rippleColor!
        rippleLayer?.rippleScaleRatio = 1
        rippleLayer?.isEnableElevation = false
        rippleLayer?.effectSpeed = 300
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let point = touches.first?.location(in: self) {
            rippleLayer?.startEffectsAtLocation(point)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        rippleLayer?.stopEffectsImmediately()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        rippleLayer?.stopEffects()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        rippleLayer?.stopEffects()
    }
}
