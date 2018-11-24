//
//  SSSwipeAnimator.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/22.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

protocol SSSwipeAnimatorDelegate: class {
    func animatorShouldAnimateTabBar(_ animator: SSSwipeAnimator) -> Bool
    func animatorTransitionDimAmount(_ animator: SSSwipeAnimator) -> CGFloat
}

class SSSwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private weak var toViewController: UIViewController?
    weak var delegate: SSSwipeAnimatorDelegate?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let ctx = transitionContext else { return 0 }
        return ctx.isInteractive ? 0.25 : 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVc = transitionContext.viewController(forKey: .to),
            let fromVc = transitionContext.viewController(forKey: .from) else { return }
        
        transitionContext.containerView.insertSubview(toVc.view, belowSubview: fromVc.view)
        let toVcTranslationX = -transitionContext.containerView.bounds.width * 0.3
        toVc.view.bounds = transitionContext.containerView.bounds
        toVc.view.center = transitionContext.containerView.center
        toVc.view.transform = CGAffineTransform(translationX: toVcTranslationX, y: 0)
        
        fromVc.view.addShadowAnimation()
        let previousClipsTouBounds = fromVc.view.clipsToBounds
        fromVc.view.clipsToBounds = false
        
        let dimmingView = UIView(frame: toVc.view.bounds)
        let dimAmount = delegate?.animatorTransitionDimAmount(self)
        dimmingView.backgroundColor = UIColor(white: 0, alpha: dimAmount ?? 0.1)
        toVc.view.addSubview(dimmingView)

        var shouldAddTabBarBackToTabBarController = false
        var tabBarControllerContainsToViewController = false
        var tabBarControllerContainsNavController = false
        var isToViewControllerFirstInNavController = false
        let shouldAnimateTabBar = delegate?.animatorShouldAnimateTabBar(self) ?? false
        
        if let tabBarVc = toVc.tabBarController {
            let tabBar = tabBarVc.tabBar
            if let vcs = tabBarVc.viewControllers {
                tabBarControllerContainsToViewController = vcs.contains(toVc)
                if let navVc = toVc.navigationController {
                    tabBarControllerContainsNavController = vcs.contains(navVc)
                    if let firstVc = navVc.viewControllers.first {
                        isToViewControllerFirstInNavController = firstVc == toVc
                    }
                }
            }
            if shouldAnimateTabBar && (tabBarControllerContainsToViewController || (isToViewControllerFirstInNavController && tabBarControllerContainsNavController)) {
                tabBar.layer.removeAllAnimations()
                var tabBarRect = tabBar.frame
                tabBarRect.x = toVc.view.x
                tabBar.frame = tabBarRect
                
                toVc.view.addSubview(tabBar)
                shouldAddTabBarBackToTabBarController = true
            }
        }
        
        let curveOpt: UIView.AnimationOptions = transitionContext.isInteractive ? .curveLinear : .init(rawValue: 7 << 16)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: [curveOpt], animations: {
            toVc.view.transform = CGAffineTransform.identity
            fromVc.view.transform = CGAffineTransform(translationX: toVc.view.width, y: 0)
            dimmingView.alpha = 0
        }) { flag in
            
            if shouldAddTabBarBackToTabBarController {
                let tabBarVc = toVc.tabBarController
                let tabBar = tabBarVc?.tabBar
                tabBarVc?.view.addSubview(tabBar!)
                var tabBarRect = tabBar?.frame
                tabBarRect?.origin.x = (tabBarVc?.view.x)!
                tabBar?.frame = tabBarRect!
            }
            
            dimmingView.removeFromSuperview()
            fromVc.view.transform = CGAffineTransform.identity
            fromVc.view.clipsToBounds = previousClipsTouBounds
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        self.toViewController = toVc
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        if !transitionCompleted {
            self.toViewController?.view.transform = CGAffineTransform.identity
        }
    }
}

private extension UIView {
    func addShadowAnimation() {
        let shadowWidth: CGFloat = 4
        let shadowVerticalPadding: CGFloat = -20
        let shadowHeight: CGFloat = self.frame.height - 2 * shadowVerticalPadding
        let shadowRect = CGRect(x: -shadowWidth, y: shadowVerticalPadding, width: shadowWidth, height: shadowHeight)
        let shadowPath = UIBezierPath(rect: shadowRect)
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowOpacity = 0.2
        let toValue: Float = 0
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = self.layer.shadowOpacity
        animation.toValue = toValue
        self.layer.add(animation, forKey: nil)
        self.layer.shadowOpacity = toValue
    }
    
}
