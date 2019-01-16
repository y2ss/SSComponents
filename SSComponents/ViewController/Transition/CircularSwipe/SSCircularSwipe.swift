//
//  SSCircularSwipe.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/13.
//  Copyright © 2018年 y2ss. All rights reserved.
//

class SSCircularSwipe: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate, POPAnimationDelegate {
    enum `Type` {
        case pop
        case push
    }
    
    private var _type: Type = .pop
    private var transitionCtx: UIViewControllerContextTransitioning?
    init(type: Type) {
        self._type = type
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionCtx = transitionContext
        if _type == .push {
            
            guard let from = transitionContext.viewController(forKey: .from) as? CircularSwipeVC1,
                let to = transitionContext.viewController(forKey: .to) as? CircularSwipeVC2 else { return }
            let contentView = transitionContext.containerView
            
            if let btn = from.btn {
                var finalPoint: CGPoint
                let maskStartPath = UIBezierPath.init(ovalIn: btn.frame)
                contentView.addSubview(from.view)
                contentView.addSubview(to.view)
                
                if btn.x > to.view.width * 0.5 {
                    if btn.y < to.view.height * 0.5 {
                        finalPoint = CGPoint(x: btn.centerX, y: btn.centerY - to.view.bounds.maxY + 30)
                    } else {
                        finalPoint = CGPoint(x: btn.centerX, y: btn.centerY)
                    }
                } else {
                    if btn.y < to.view.height * 0.5 {
                        finalPoint = CGPoint.init(x: btn.centerX - to.view.bounds.maxX, y: btn.centerY - to.view.bounds.maxY + 30)
                    } else {
                        finalPoint = CGPoint.init(x: btn.centerX - to.view.bounds.maxX, y: btn.centerY)
                    }
                }
                let radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y))
                let maskEndPath = UIBezierPath.init(ovalIn: btn.frame.insetBy(dx: -radius, dy: -radius))
                
                let maskLayer = CAShapeLayer()
                maskLayer.path = maskEndPath.cgPath
                to.view.layer.mask = maskLayer
                
                let maskAnim = CABasicAnimation.init(keyPath: "path")
                maskAnim.fromValue = maskStartPath.cgPath
                maskAnim.toValue = maskEndPath.cgPath
                maskAnim.duration = self.transitionDuration(using: transitionContext)
                maskAnim.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
                maskAnim.delegate = self
                maskLayer.add(maskAnim, forKey: "path")
                
//                let kanim = CAKeyframeAnimation.init(keyPath: "path")
//                kanim.values = [maskStartPath.cgPath, maskEndPath.cgPath]
//                kanim.duration = 100
//                kanim.isAdditive = true
//                kanim.isRemovedOnCompletion = false
//                kanim.fillMode = .forwards
//
//                maskLayer.add(kanim, forKey: nil)
//                maskLayer.speed = 0
//
//                let pop = POPAnimatableProperty.property(withName: "timeOffset") { prop in
//                    prop?.readBlock = { obj, values in
//                        if let obj = obj as? CAShapeLayer {
//
//                            values?.pointee = CGFloat(obj.timeOffset)
//                        }
//                    }
//                    prop?.writeBlock = { obj, values in
//                        if let obj = obj as? CAShapeLayer {
//                            obj.timeOffset = CFTimeInterval(CGFloat(values?.pointee ?? 0))
//                        }
//                    }
//                    prop?.threshold = 0.1
//                }
//                let popString = POPSpringAnimation()
//                popString.fromValue = 0
//                popString.toValue = 100
//                popString.springBounciness = 1
//                popString.springSpeed = 20
//                popString.dynamicsTension = 700
//                popString.dynamicsFriction = 5
//                popString.dynamicsMass = 1
//                popString.property = pop as? POPAnimatableProperty
//                popString.delegate = self
//                maskLayer.pop_add(popString, forKey: nil)
            }
        } else {
            guard let from = transitionContext.viewController(forKey: .from) as? CircularSwipeVC2,
                let to = transitionContext.viewController(forKey: .to) as? CircularSwipeVC1 else { return }
            let contentView = transitionContext.containerView
            if let btn = to.btn {
                contentView.addSubview(to.view)
                contentView.addSubview(from.view)
                
                let finalPath = UIBezierPath(ovalIn: btn.frame)
                var finalPoint: CGPoint
                if btn.x > to.view.width * 0.5 {
                    if btn.y < to.view.height * 0.5 {
                        finalPoint = CGPoint.init(x: btn.centerX, y: btn.centerY - to.view.bounds.maxY + 30)
                    } else {
                        finalPoint = CGPoint.init(x: btn.centerX, y: btn.centerY)
                    }
                } else {
                    if btn.y < to.view.height * 0.5 {
                        finalPoint = CGPoint.init(x: btn.centerX - to.view.bounds.maxX, y: btn.centerY - to.view.bounds.maxY + 30)
                    } else {
                        finalPoint = CGPoint.init(x: btn.centerX - to.view.bounds.maxX, y: btn.centerY)
                    }
                }
                let radius = sqrt(finalPoint.x * finalPoint.x + finalPoint.y * finalPoint.y)
                let startPath = UIBezierPath.init(ovalIn: btn.frame.insetBy(dx: -radius, dy: -radius))
                let maskLayer = CAShapeLayer()
                maskLayer.path = finalPath.cgPath
                from.view.layer.mask = maskLayer
                
                let anim = CABasicAnimation.init(keyPath: "path")
                anim.fromValue = startPath.cgPath
                anim.toValue = finalPath.cgPath
                anim.duration = self.transitionDuration(using: transitionContext)
                anim.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
                anim.delegate = self
                maskLayer.add(anim, forKey: "pingInvert")
            }
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let ctx = self.transitionCtx {
            if _type == .push {
                self.transitionCtx?.completeTransition(!ctx.transitionWasCancelled)
                ctx.viewController(forKey: .from)?.view.layer.mask = nil
                ctx.viewController(forKey: .to)?.view.layer.mask = nil
            } else {
                self.transitionCtx?.completeTransition(!ctx.transitionWasCancelled)
                self.transitionCtx?.viewController(forKey: .from)?.view.layer.mask = nil
                self.transitionCtx?.viewController(forKey: .to)?.view.layer.mask = nil
            }
        }
    }
    
    func pop_animationDidStop(_ anim: POPAnimation!, finished: Bool) {
        if let ctx = self.transitionCtx {
            if _type == .push {
                self.transitionCtx?.completeTransition(!ctx.transitionWasCancelled)
                ctx.viewController(forKey: .from)?.view.layer.mask = nil
                ctx.viewController(forKey: .to)?.view.layer.mask = nil
            } else {
                self.transitionCtx?.completeTransition(!ctx.transitionWasCancelled)
                self.transitionCtx?.viewController(forKey: .from)?.view.layer.mask = nil
                self.transitionCtx?.viewController(forKey: .to)?.view.layer.mask = nil
            }
        }
    }
    
}
