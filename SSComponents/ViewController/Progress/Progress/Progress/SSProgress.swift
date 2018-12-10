//
//  SSProgress.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/3.
//  Copyright © 2018年 y2ss. All rights reserved.
//

class SSProgress: UIView {
    enum Style {
        case circular
        case linear
    }
    
    enum `Type` {
        case indeterminate
        case determinate
    }
    
    var type: Type = .indeterminate {
        didSet {
            switch type {
            case .indeterminate:
                drawingLayer.determinate = false
                break
            case .determinate:
                drawingLayer.determinate = true
                drawingLayer.progress = progress
                break
            }
        }
    }
    
    var style: Style = .circular {
        willSet {
            if newValue != style {
                drawingLayer.removeFromSuperlayer()
                drawingLayer.superLayer?.sublayers = nil
                switch newValue {
                case .circular:
                    drawingLayer = SSProgressCircularLayer.init(superLayer: self.layer)
                    break
                case .linear:
                    drawingLayer = SSProgressLinearLayer(superLayer: self.layer)
                    break
                }
                drawingLayer.progressColor = progressColor
                drawingLayer.trackColor = trackColor
                drawingLayer.determinate = type == .determinate
                if type == .indeterminate {
                    drawingLayer.startAnimating()
                }
            }
        }
    }
    var trackWidth: CGFloat = 2 {
        willSet {
            drawingLayer.trackWidth = newValue
        }
    }
    var circularSize: CGFloat = 100 {
        willSet {
            if drawingLayer.isKind(of: SSProgressCircularLayer.self) {
                (drawingLayer as! SSProgressCircularLayer).circleDiameter = newValue
            }
        }
    }
    var progress: CGFloat = 0 {
        willSet {
            drawingLayer.progress = newValue
        }
    }
    var isEnableTrackColor: Bool = true {
        willSet {
            drawingLayer.drawTrack = newValue
        }
    }
    var progressColor = UIColor.SSStyle {
        willSet {
            drawingLayer.progressColor = newValue
        }
    }
    var trackColor = UIColor(hex: 0xB4CFEE) {
        willSet {
            drawingLayer.trackColor = newValue
        }
    }
    
    private lazy var drawingLayer: SSProgressLayer = {
       let layer = SSProgressCircularLayer.init(superLayer: self.layer)
        layer.progressColor = progressColor
        layer.trackColor = trackColor
        if type == .indeterminate {
            layer.startAnimating()
        }
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, type: Type) {
        super.init(frame: frame)
        self.type = type
    }
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawingLayer.superLayerDidResize()
    }    
}

