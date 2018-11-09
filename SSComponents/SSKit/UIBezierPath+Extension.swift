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
        var controlPoint1: CGPoint
        var controlPoint2: CGPoint
        var endPoint: CGPoint
        var length: CGFloat
        var type: CGPathElementType
    }
    
    typealias bezierSubPathEnumerator = (CGPathElement)->(Void)
    
    
    /*
     typedef void(^BezierSubpathEnumerator)(const CGPathElement *element);
     
     static void bezierSubpathFunction(void *info, CGPathElement const *element) {
     BezierSubpathEnumerator block = (__bridge BezierSubpathEnumerator)info;
     block(element);
     }
     
     @implementation UIBezierPath (JKLength)
     
     #pragma mark - Internal
     
     - (void)enumerateSubpaths:(BezierSubpathEnumerator)enumeratorBlock
     {
     CGPathApply(self.CGPath, (__bridge void *)enumeratorBlock, bezierSubpathFunction);
     }
     */
    
    
    private func enumerateSubpaths(_ enumerator: bezierSubPathEnumerator) {
        self.cgPath.apply(info: nil) { info, element in
            
        }
    }
    
    private func extractSubpaths(_ subpaths: [BezierSubPath]) {
        self.cgPath.applyWithBlock { element in
            print(element)
        }

    }
    
    /*
     - (void)extractSubpaths:(JKBezierSubpath*)subpathArray
     {
     __block CGPoint currentPoint = CGPointZero;
     __block NSUInteger i = 0;
     [self enumerateSubpaths:^(const CGPathElement *element) {
     
     CGPathElementType type = element->type;
     CGPoint *points = element->points;
     
     CGFloat subLength = 0.0f;
     CGPoint endPoint = CGPointZero;
     
     JKBezierSubpath subpath;
     subpath.type = type;
     subpath.startPoint = currentPoint;
     
     /*
     *  All paths, no matter how complex, are created through a combination of these path elements.
     */
     switch (type) {
     case kCGPathElementMoveToPoint:
     
     endPoint = points[0];
     
     break;
     case kCGPathElementAddLineToPoint:
     
     endPoint = points[0];
     
     subLength = linearLineLength(currentPoint, endPoint);
     
     break;
     case kCGPathElementAddQuadCurveToPoint:
     
     endPoint = points[1];
     CGPoint controlPoint = points[0];
     
     subLength = quadCurveLength(currentPoint, endPoint, controlPoint);
     
     subpath.controlPoint1 = controlPoint;
     
     break;
     case kCGPathElementAddCurveToPoint:
     
     endPoint = points[2];
     CGPoint controlPoint1 = points[0];
     CGPoint controlPoint2 = points[1];
     
     subLength = cubicCurveLength(currentPoint, endPoint, controlPoint1, controlPoint2);
     
     subpath.controlPoint1 = controlPoint1;
     subpath.controlPoint2 = controlPoint2;
     
     break;
     case kCGPathElementCloseSubpath:
     default:
     break;
     }
     
     subpath.length = subLength;
     subpath.endPoint = endPoint;
     
     if (type != kCGPathElementMoveToPoint) {
     subpathArray[i] = subpath;
     i++;
     }
     
     currentPoint = endPoint;
     }];
     if (i == 0) {
     subpathArray[0].length = 0.0f;
     subpathArray[0].endPoint = currentPoint;
     }
     }
     */

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
