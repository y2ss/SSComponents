//
//  UIBezierPath+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/9.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UIBezierPath {
    private struct BezierSubPath {
        var startPoint: CGPoint
        var controlPoint1: CGPoint?
        var controlPoint2: CGPoint?
        var endPoint: CGPoint
        var length: CGFloat
        var type: CGPathElementType
        
        init(_ type: CGPathElementType = .moveToPoint, startPoint: CGPoint = .zero) {
            self.startPoint = startPoint
            self.endPoint = .zero
            self.length = 0
            self.type = type
        }
    }
    
    //MARK: - public
    //子段数
    var countSubpaths: Int {
        var count = 0
        if #available(iOS 11.0, *) {
            self.cgPath.applyWithBlock { element in
                if element.pointee.type != .moveToPoint {
                    count += 1
                }
            }
        } else {
            fatalError("only support about ios 11")
        }
        return count == 0 ? 1 : count
    }

    //bezierpath length
    var length: CGFloat {
        let count = countSubpaths
        var subpaths = [BezierSubPath](repeating: BezierSubPath(), count: count)
        extractSubpaths(&subpaths)
        var length: CGFloat = 0
        for i in 0 ..< count {
            length += subpaths[i].length
        }
        return length
    }
    
    func pointAtPercentOfLength(_ percent: CGFloat) -> CGPoint {
        var p = percent
        if p < 0 {
            p = 0
        } else if p > 1 {
            p = 1
        }
        let subpathCount = self.countSubpaths
        var subpaths = [BezierSubPath](repeating: BezierSubPath(), count: subpathCount)
        extractSubpaths(&subpaths)
        var length: CGFloat = 0
        for i in 0 ..< subpathCount {
            length += subpaths[i].length
        }
        
        let pointLocationInPath = length * p
        var currentLength: CGFloat = 0
        var subpathContainingPoint = BezierSubPath()
        
        for i in 0 ..< subpathCount {
            if currentLength + subpaths[i].length >= pointLocationInPath {
                subpathContainingPoint = subpaths[i]
                break
            } else {
                currentLength += subpaths[i].length
            }
        }
        
        let lengthInSubpath = pointLocationInPath - currentLength
        if subpathContainingPoint.length == 0 {
            return subpathContainingPoint.endPoint
        } else {
            let t = lengthInSubpath / subpathContainingPoint.length
            return pointAtPercent(t, of: subpathContainingPoint)
        }
    }
    
    //MARK: - private
    private func pointAtPercent(_ per: CGFloat, of subpath: BezierSubPath) -> CGPoint {
        var p = CGPoint.zero
        switch subpath.type {
        case .addLineToPoint:
            p = linearBezierPoint(per, subpath.startPoint, subpath.endPoint)
        case .addQuadCurveToPoint:
            p = quadBezierPoint(per, subpath.startPoint, subpath.controlPoint1!, subpath.endPoint)
        case .addCurveToPoint:
            p = cubicBezierPoint(per, subpath.startPoint, subpath.controlPoint1!, subpath.controlPoint2!, subpath.endPoint)
        default:
            break
        }
        return p
    }
    
    private func extractSubpaths(_ subpaths: inout [BezierSubPath]) {
        var currentPoint = CGPoint.zero
        var i = 0
        
        if #available(iOS 11.0, *) {
            self.cgPath.applyWithBlock { element in
                let points = element.pointee.points
                var subpath = BezierSubPath(element.pointee.type, startPoint: currentPoint)
                switch subpath.type {
                case .moveToPoint:
                    subpath.endPoint = points.advanced(by: 0).pointee
                case .addLineToPoint:
                    subpath.endPoint = points.advanced(by: 0).pointee
                    subpath.length = linearLineLength(currentPoint, subpath.endPoint)
                case .addQuadCurveToPoint:
                    subpath.endPoint = points.advanced(by: 1).pointee
                    let controlPoint = points.advanced(by: 0).pointee
                    subpath.length = quadCurveLength(currentPoint, subpath.endPoint, controlPoint)
                    subpath.controlPoint1 = controlPoint
                case .addCurveToPoint:
                    subpath.endPoint = points.advanced(by: 2).pointee
                    let controlPoint1 = points.advanced(by: 0).pointee
                    let controlPoint2 = points.advanced(by: 1).pointee
                    subpath.length = cubicCurveLength(currentPoint, subpath.endPoint, controlPoint1, controlPoint2)
                    subpath.controlPoint1 = controlPoint1
                    subpath.controlPoint2 = controlPoint2
                case .closeSubpath:
                    break
                }
                if subpath.type != .moveToPoint {
                    subpaths[i] = subpath
                    i += 1
                }
                currentPoint = subpath.endPoint
            }
        } else {
            fatalError("only support about ios 11")
        }
        if i == 0 {
            subpaths[0].length = 0
            subpaths[0].endPoint = currentPoint
        }
    }
}


//MARK: - MATH Helper
private func quadCurveLength(_ fromPoint: CGPoint, _ toPoint: CGPoint, _ controlPoint: CGPoint) -> CGFloat {
    let iterations = 100
    var length: CGFloat = 0
    for idx in 0 ..< iterations {
        let t = CGFloat(idx) * (1.0 / CGFloat(iterations))
        let tt = t + (1.0 / CGFloat(iterations))
        let p = quadBezierPoint(t, fromPoint, controlPoint, toPoint)
        let pp = quadBezierPoint(tt, fromPoint, controlPoint, toPoint)
        length += linearLineLength(p, pp)
    }
    return length
}

private func cubicCurveLength(_ fromPoint: CGPoint, _ toPoint: CGPoint, _ controlPoint1: CGPoint, _ controlPoint2: CGPoint) -> CGFloat {
    let iterations = 100
    var length: CGFloat = 0
    for idx in 0 ..< iterations {
        let t = CGFloat(idx) * (1.0 / CGFloat(iterations))
        let tt = t + (1.0 / CGFloat(iterations))
        let p = cubicBezierPoint(t, fromPoint, controlPoint1, controlPoint2, toPoint)
        let pp = cubicBezierPoint(tt, fromPoint, controlPoint1, controlPoint2, toPoint)
        length += linearLineLength(p, pp)
    }
    return length
}

private func linearLineLength(_ fromPoint: CGPoint, _ toPoint: CGPoint) -> CGFloat {
    return CGFloat(sqrtf(powf(Float(toPoint.x - fromPoint.x), 2)
        + powf(Float(toPoint.y - fromPoint.y), 2)))
}

private func linearBezierPoint(_ t: CGFloat, _ start: CGPoint, _ end: CGPoint) -> CGPoint {
    let dx = end.x - start.x
    let dy = end.y - start.y
    let px = start.x + t * dx
    let py = start.y + t * dy
    return CGPoint(x: px, y: py)
}

private func quadBezierPoint(_ t: CGFloat, _ start: CGPoint, _ c1: CGPoint, _ end: CGPoint) -> CGPoint {
    let x = quadBezier(t, start.x, c1.x, end.x)
    let y = quadBezier(t, start.y, c1.y, end.y)
    return CGPoint(x: x, y: y)
}

private func cubicBezierPoint(_ t: CGFloat, _ start: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ end: CGPoint) -> CGPoint {
    let x = cubicBezier(t, start.x, c1.x, c2.x, end.x)
    let y = cubicBezier(t, start.y, c1.y, c2.y, end.y)
    return CGPoint(x: x, y: y)
}

private func cubicBezier(_ t: CGFloat, _ start: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ end: CGFloat) -> CGFloat {
    let t_ = 1 - t
    let tt_ = t_ * t_
    let ttt_ = t_ * t_ * t_
    let tt = t * t
    let ttt = t * t * t
    return start * ttt_ + 3 * c1 * tt_ * t + 3 * c2 * t_ * tt + end * ttt
}

private func quadBezier(_ t: CGFloat, _ start: CGFloat, _ c1: CGFloat, _ end: CGFloat) -> CGFloat {
    let t_ = 1 - t
    let tt_ = t_ * t_
    let tt = t * t
    return start * tt_ + 2 * c1 * t_ * t + end * tt
}
