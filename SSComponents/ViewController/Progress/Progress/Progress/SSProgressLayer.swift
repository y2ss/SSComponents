//
//  SSProgressLayer.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/3.
//  Copyright © 2018年 y2ss. All rights reserved.
//

class SSProgressLayer: CALayer {
    
    var progressColor: UIColor = UIColor.clear
    var trackColor: UIColor = UIColor.clear
    var trackWidth: CGFloat = 3
    var drawTrack: Bool = true
    var determinate: Bool = true
    var progress: CGFloat = 0
    weak var superLayer: CALayer?
    weak var superView: UIView?
    var isAnimating: Bool = false
    
    init(superLayer: CALayer) {
        super.init()
        self.superLayer = superLayer
        setup()
        self.superLayer?.addSublayer(self)
        self.superLayer?.addObserver(self, forKeyPath: "bounds", options: .init(rawValue: 0), context: nil)
    }
    
    init(superView: UIView) {
        super.init()
        self.superView = superView
        self.superLayer = superView.layer
        setup()
        self.superLayer?.addSublayer(self)
        superView.addObserver(self, forKeyPath: "bounds", options: .init(rawValue: 0), context: nil)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
    }
    
    func superLayerDidResize() {
        
    }
    
    func startAnimating() {
        
    }
    
    func stopAnimating() {
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        superLayerDidResize()
    }
    
    deinit {
        superView?.removeObserver(self, forKeyPath: "bounds")
        superLayer?.removeObserver(self, forKeyPath: "bounds")
    }
}
