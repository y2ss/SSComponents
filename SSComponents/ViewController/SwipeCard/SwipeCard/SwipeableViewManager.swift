//
//  ViewManager.swift
//  ZLSwipeableViewSwift
//
//  Created by Andrew Breckenridge on 5/17/16.
//  Copyright © 2016 Andrew Breckenridge. All rights reserved.
//

import UIKit

class SwipeableViewManager: NSObject {
    
    struct Movement {
        let location: CGPoint
        let translation: CGPoint
        let velocity: CGPoint
    }
    
    struct Direction: OptionSet, CustomStringConvertible {
        
        var rawValue: UInt
        
        init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        static let None = Direction(rawValue: 0b0000)
        static let Left = Direction(rawValue: 0b0001)
        static let Right = Direction(rawValue: 0b0010)
        static let Up = Direction(rawValue: 0b0100)
        static let Down = Direction(rawValue: 0b1000)
        static let Horizontal: Direction = [Left, Right]
        static let Vertical: Direction = [Up, Down]
        static let All: Direction = [Horizontal, Vertical]
        
        static func fromPoint(_ point: CGPoint) -> Direction {
            switch (point.x, point.y) {
            case let (x, y) where abs(x) >= abs(y) && x > 0:
                return .Right
            case let (x, y) where abs(x) >= abs(y) && x < 0:
                return .Left
            case let (x, y) where abs(x) < abs(y) && y < 0:
                return .Up
            case let (x, y) where abs(x) < abs(y) && y > 0:
                return .Down
            case (_, _):
                return .None
            }
        }
        
        var description: String {
            switch self {
            case Direction.None:
                return "None"
            case Direction.Left:
                return "Left"
            case Direction.Right:
                return "Right"
            case Direction.Up:
                return "Up"
            case Direction.Down:
                return "Down"
            case Direction.Horizontal:
                return "Horizontal"
            case Direction.Vertical:
                return "Vertical"
            case Direction.All:
                return "All"
            default:
                return "Unknown"
            }
        }
    }

    
    // Snapping -> [Moving]+ -> Snapping
    // Snapping -> [Moving]+ -> Swiping -> Snapping
    enum State {
        case snapping(CGPoint), moving(CGPoint), swiping(CGPoint, CGVector)
    }
    
    var state: State {
        didSet {
            if case .snapping(_) = oldValue,  case let .moving(point) = state {
                print("1")
                unsnapView()
                attachView(toPoint: point)
            } else if case .snapping(_) = oldValue, case let .swiping(origin, direction) = state {
                print("2")
                unsnapView()
                attachView(toPoint: origin)
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .moving(_) = oldValue, case let .moving(point) = state {
                print("3")
                moveView(toPoint: point)
            } else if case .moving(_) = oldValue, case let .snapping(point) = state {
                print("4")
                detachView()
                snapView(point)
            } else if case .moving(_) = oldValue, case let .swiping(origin, direction) = state {
                print("5")
                pushView(fromPoint: origin, inDirection: direction)
            } else if case .swiping(_, _) = oldValue, case let .snapping(point) = state {
                print("6")
                unpushView()
                detachView()
                snapView(point)
            }
            print(oldValue)
        }
    }
    
    static private let anchorViewWidth = CGFloat(1000)
    private var anchorView = UIView(frame: CGRect(x: 0, y: 0, width: anchorViewWidth, height: anchorViewWidth))
    
    private var snapBehavior: UISnapBehavior!
    private var viewToAnchorViewAttachmentBehavior: UIAttachmentBehavior!
    private var anchorViewToPointAttachmentBehavior: UIAttachmentBehavior!
    private var pushBehavior: UIPushBehavior!
    
    private let view: UIView
    private let containerView: UIView
    private let miscContainerView: UIView
    private let animator: UIDynamicAnimator
    private weak var swipeableView: SwipeableView?
    
    init(view: UIView, containerView: UIView, index: Int, miscContainerView: UIView, animator: UIDynamicAnimator, swipeableView: SwipeableView) {
        self.view = view
        self.containerView = containerView
        self.miscContainerView = miscContainerView
        self.animator = animator
        self.swipeableView = swipeableView
        self.state = SwipeableViewManager.defaultSnappingState(view)
        
        super.init()
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        if swipeableView.didTap != nil {
            self.addTapRecognizer()
        }
        miscContainerView.addSubview(anchorView)
        containerView.insertSubview(view, at: index)
    }
    
    static func defaultSnappingState(_ view: UIView) -> State {
        return .snapping(view.convert(view.center, from: view.superview))
    }
    
    func snappingStateAtContainerCenter() -> State {
        guard let swipeableView = swipeableView else { return SwipeableViewManager.defaultSnappingState(view) }
        return .snapping(containerView.convert(swipeableView.center, from: swipeableView.superview))
    }
    
    deinit {
        if let snapBehavior = snapBehavior {
            removeBehavior(snapBehavior)
        }
        if let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior {
            removeBehavior(viewToAnchorViewAttachmentBehavior)
        }
        if let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior {
            removeBehavior(anchorViewToPointAttachmentBehavior)
        }
        if let pushBehavior = pushBehavior {
            removeBehavior(pushBehavior)
        }
        
        for gestureRecognizer in view.gestureRecognizers! {
            if gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) {
                view.removeGestureRecognizer(gestureRecognizer)
            }
        }
        
        anchorView.removeFromSuperview()
        view.removeFromSuperview()
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let swipeableView = swipeableView else { return }
        
        let translation = recognizer.translation(in: containerView)
        let location = recognizer.location(in: containerView)
        let velocity = recognizer.velocity(in: containerView)
        let movement = Movement(location: location, translation: translation, velocity: velocity)
        
        switch recognizer.state {
        case .began:
            guard case .snapping(_) = state else { return }
            state = .moving(location)
            swipeableView.didStart?(view, location)
        case .changed:
            guard case .moving(_) = state else { return }
            state = .moving(location)
            swipeableView.swiping?(view, location, translation)
        case .ended, .cancelled:
            guard case .moving(_) = state else { return }
            if swipeableView.shouldSwipeView(view, movement, swipeableView) {
                let directionVector = CGVector(point: translation.normalized * max(velocity.magnitude, swipeableView.minVelocityInPointPerSecond))
                state = .swiping(location, directionVector)
                swipeableView.swipeView(view, location: location, directionVector: directionVector)
            } else {
                state = snappingStateAtContainerCenter()
                swipeableView.didCancel?(view)
            }
            swipeableView.didEnd?(view, location)
        default:
            break
        }
    }
    
    func addTapRecognizer() {
        for gesture in view.gestureRecognizers ?? [] {
            if let tapGesture = gesture as? UITapGestureRecognizer {

                // Remove previous tap gesture
                view.removeGestureRecognizer(tapGesture)

            }
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let swipeableView = swipeableView, let topView = swipeableView.topView()  else { return }
        
        let location = recognizer.location(in: containerView)
        swipeableView.didTap?(topView, location)
    }
    
    fileprivate func snapView(_ point: CGPoint) {
        snapBehavior = UISnapBehavior(item: view, snapTo: point)
        snapBehavior!.damping = 0.75
        addBehavior(snapBehavior)
    }
    
    fileprivate func unsnapView() {
        guard let snapBehavior = snapBehavior else { return }
        removeBehavior(snapBehavior)
    }
    
    func resnapView() {
        if case .snapping(_) = state {
            unsnapView()
            state = snappingStateAtContainerCenter()
        }
    }
    
    fileprivate func attachView(toPoint point: CGPoint) {
        anchorView.center = point
        anchorView.backgroundColor = UIColor.blue
        anchorView.isHidden = true
        
        // attach aView to anchorView
        let p = view.center
        viewToAnchorViewAttachmentBehavior = UIAttachmentBehavior(item: view, offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)), attachedTo: anchorView, offsetFromCenter: UIOffset.zero)
        viewToAnchorViewAttachmentBehavior!.length = 0
        
        // attach anchorView to point
        anchorViewToPointAttachmentBehavior = UIAttachmentBehavior(item: anchorView, offsetFromCenter: UIOffset.zero, attachedToAnchor: point)
        anchorViewToPointAttachmentBehavior!.damping = 100
        anchorViewToPointAttachmentBehavior!.length = 0
        
        addBehavior(viewToAnchorViewAttachmentBehavior!)
        addBehavior(anchorViewToPointAttachmentBehavior!)
    }
    
    fileprivate func moveView(toPoint point: CGPoint) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let toPoint = anchorViewToPointAttachmentBehavior else { return }
        toPoint.anchorPoint = point
    }
    
    fileprivate func detachView() {
        guard let viewToAnchorViewAttachmentBehavior = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior else { return }
        removeBehavior(viewToAnchorViewAttachmentBehavior)
        removeBehavior(anchorViewToPointAttachmentBehavior)
    }
    
    fileprivate func pushView(fromPoint point: CGPoint, inDirection direction: CGVector) {
        guard let _ = viewToAnchorViewAttachmentBehavior, let anchorViewToPointAttachmentBehavior = anchorViewToPointAttachmentBehavior  else { return }
        
        removeBehavior(anchorViewToPointAttachmentBehavior)
        
        pushBehavior = UIPushBehavior(items: [anchorView], mode: .instantaneous)
        pushBehavior.pushDirection = direction
        addBehavior(pushBehavior)
    }
    
    fileprivate func unpushView() {
        guard let pushBehavior = pushBehavior else { return }
        removeBehavior(pushBehavior)
    }
    
    fileprivate func addBehavior(_ behavior: UIDynamicBehavior) {
        animator.addBehavior(behavior)
    }
    
    fileprivate func removeBehavior(_ behavior: UIDynamicBehavior) {
        animator.removeBehavior(behavior)
    }
}


extension SwipeableViewManager.Direction: Equatable {}
func ==(lhs: SwipeableViewManager.Direction, rhs: SwipeableViewManager.Direction) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

extension CGPoint {
    init(vector: CGVector) {
        self.init(x: vector.dx, y: vector.dy)
    }
    
    var normalized: CGPoint {
        return CGPoint(x: x / magnitude, y: y / magnitude)
    }
    
    var magnitude: CGFloat {
        return CGFloat(sqrtf(powf(Float(x), 2) + powf(Float(y), 2)))
    }
    
    static func areInSameTheDirection(_ p1: CGPoint, p2: CGPoint) -> Bool {
        func signNum(_ n: CGFloat) -> Int {
            return (n < 0.0) ? -1 : (n > 0.0) ? +1 : 0
        }
        return signNum(p1.x) == signNum(p2.x) && signNum(p1.y) == signNum(p2.y)
    }
}


extension CGVector {
    init(point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }
    
}
