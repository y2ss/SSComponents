//
//  CAGradientLayer.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/15.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    enum GradientDirection {
        case fromTop
        case fromLeft
        case fromLeftAndTop
        case fromLeftAndBottom
    }

    class func createGradientLayer(_ frame: CGRect, direction: GradientDirection, colors: [UIColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        switch direction {
        case .fromTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .fromLeft:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .fromLeftAndTop:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .fromLeftAndBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }
        let c = colors.map { color in
            return color.cgColor
        }
        gradientLayer.colors = c
        return gradientLayer
    }
}
