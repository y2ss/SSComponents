//
//  SSSloppySwiper.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/23.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

@objc protocol SSSloppySwiperDelegate: class, NSObjectProtocol {
    @objc optional func sloppySwiperShouldAnimateTabBar(_ swiper: SSSloppySwiper) -> Bool
    @objc optional func sloppySwiperTransitionDimAmount(_ swiper: SSSloppySwiper) -> CGFloat
}

class SSSloppySwiper: NSObject {
    
    weak var delegate: SSSloppySwiperDelegate?
    
    private weak var panRecognizer: UIPanGestureRecognizer?
    private weak var navigationController: UINavigationController?
    private lazy var animator: SSSwipeAnimator = {
        let _animator = SSSwipeAnimator()
        _animator.delegate = self
        return _animator
    }()
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var duringAnimation: Bool = false
    
    init(navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
        commonInit()
    }
    
    @objc private func pan(_ pgr: UIPanGestureRecognizer) {
        guard let nav = self.navigationController, let _view = nav.view else { return }
        
        if pgr.state == .began {
            if nav.viewControllers.count > 1 && !self.duringAnimation {
                self.interactionController = UIPercentDrivenInteractiveTransition()
                self.interactionController?.completionCurve = .easeOut
                self.navigationController?.popViewController(animated: true)
            }
        } else if pgr.state == .changed {
            let translation = pgr.translation(in: _view)
            let d = translation.x > 0 ? translation.x / _view.bounds.width : 0
            self.interactionController?.update(d)
        } else if pgr.state == .ended || pgr.state == .cancelled {
            if pgr.velocity(in: _view).x > 0 {
                self.interactionController?.finish()
            } else {
                self.interactionController?.cancel()
                self.duringAnimation = false
            }
            self.interactionController = nil
        }
    }
    
    private func commonInit() {
        let panRecognizer = PanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panRecognizer.direction = .right
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delegate = self
        self.navigationController?.view.addGestureRecognizer(panRecognizer)
        self.panRecognizer = panRecognizer
        
        self.animator = SSSwipeAnimator()
        self.animator.delegate = self
    }
    
    deinit {
        self.panRecognizer?.removeTarget(self, action: #selector(pan(_:)))
        if let nav = self.navigationController, let pgr = panRecognizer {
            nav.view.removeGestureRecognizer(pgr)
        }
    }
}

extension SSSloppySwiper: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return self.animator
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if animated {
            self.duringAnimation = true
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.duringAnimation = false
        if let vcs = self.navigationController?.viewControllers {
            if vcs.count <= 1 {
                self.panRecognizer?.isEnabled = false
            } else {
                self.panRecognizer?.isEnabled = true
            }
        } else {
            self.panRecognizer?.isEnabled = false
        }
    }
}

extension SSSloppySwiper: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let vcs = self.navigationController?.viewControllers else { return false }
        if vcs.count > 1 { return true }
        return false
    }
}

extension SSSloppySwiper: SSSwipeAnimatorDelegate {
    func animatorShouldAnimateTabBar(_ animator: SSSwipeAnimator) -> Bool {
        if let res = delegate?.sloppySwiperShouldAnimateTabBar?(self) {
            return res
        }
        return true
    }
    
    func animatorTransitionDimAmount(_ animator: SSSwipeAnimator) -> CGFloat {
        if let res = delegate?.sloppySwiperTransitionDimAmount?(self) {
            return res
        }
        return 0.1
    }
}

private class PanGestureRecognizer: UIPanGestureRecognizer {
    
    enum PanDirection: Int {
        case right = 0
        case down
        case left
        case up
    }
    
    var direction: PanDirection = .right
    private var dragging = false

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if self.state == .failed { return }
        
        let velocity = self.velocity(in: self.view)
        if !self.dragging && velocity != .zero {
            let velocities = [
                PanDirection.right : velocity.x,
                PanDirection.down : velocity.y,
                PanDirection.left : -velocity.x,
                PanDirection.up : -velocity.y
            ]
            let sortedVelocities = velocities.sorted { (a: (key: PanDirection, value: CGFloat), b: (key: PanDirection, value: CGFloat)) in
                return a.value < b.value
            }
            if let last = sortedVelocities.last {
                if last.key != self.direction {
                    self.state = .failed
                }
                self.dragging = true
            }
        }
    }
    
    override func reset() {
        super.reset()
        self.dragging = false
        print("reset")
    }
}
