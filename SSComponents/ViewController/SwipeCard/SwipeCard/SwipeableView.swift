//
//  ZLSwipeableView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 4/27/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

// MARK: - Main
class SwipeableView: UIView {
    
    // data source
    typealias NextViewHandler = () -> UIView?
    typealias PreviousViewHandler = () -> UIView?
    
    // customization
    typealias AnimateViewHandler = (_ view: UIView, _ index: Int, _ views: [UIView], _ swipeableView: SwipeableView) -> ()
    typealias InterpretDirectionHandler = (_ topView: UIView, _ direction:  SwipeableViewManager.Direction, _ views: [UIView], _ swipeableView: SwipeableView) -> (CGPoint, CGVector)
    typealias ShouldSwipeHandler = (_ view: UIView, _ movement: SwipeableViewManager.Movement, _ swipeableView: SwipeableView) -> Bool
    
    // delegates
    public typealias DidStartHandler = (_ view: UIView, _ atLocation: CGPoint) -> ()
    public typealias SwipingHandler = (_ view: UIView, _ atLocation: CGPoint, _ translation: CGPoint) -> ()
    public typealias DidEndHandler = (_ view: UIView, _ atLocation: CGPoint) -> ()
    typealias DidSwipeHandler = (_ view: UIView, _ inDirection: SwipeableViewManager.Direction, _ directionVector: CGVector) -> ()
    typealias DidCancelHandler = (_ view: UIView) -> ()
    typealias DidTap = (_ view: UIView, _ atLocation: CGPoint) -> ()
    typealias DidDisappear = (_ view: UIView) -> ()

    // MARK: Data Source
    var numberOfActiveView = UInt(4)
    var nextView: NextViewHandler? {
        didSet {
            loadViews()
        }
    }
    var previousView: PreviousViewHandler?
    // Rewinding
    var history = [UIView]()
    var numberOfHistoryItem = UInt(10)

    // MARK: Customizable behavior
    var animateView = SwipeableView.defaultAnimateViewHandler()
    var interpretDirection = SwipeableView.defaultInterpretDirectionHandler()
    var shouldSwipeView = SwipeableView.defaultShouldSwipeViewHandler()
    var minTranslationInPercent = CGFloat(0.25)
    var minVelocityInPointPerSecond = CGFloat(750)
    var allowedDirection = SwipeableViewManager.Direction.Horizontal
    var onlySwipeTopCard = false

    // MARK: Delegate
    var didStart: DidStartHandler?
    var swiping: SwipingHandler?
    var didEnd: DidEndHandler?
    var didSwipe: DidSwipeHandler?
    var didCancel: DidCancelHandler?
    var didTap: DidTap? {
        didSet {
            guard didTap != nil else { return }
            // Update all viewManagers to listen for taps
            
            viewManagers.forEach { view, viewManager in
                viewManager.addTapRecognizer()
            }
        }
    }
    var didDisappear: DidDisappear?

    // MARK: Private properties
    /// Contains subviews added by the user.
    private var containerView = UIView()

    /// Contains auxiliary subviews.
    private var miscContainerView = UIView()

    private var animator: UIDynamicAnimator!

    private var viewManagers = [UIView: SwipeableViewManager]()

    private var scheduler = Scheduler()

    // MARK: Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubview(containerView)
        addSubview(miscContainerView)
        animator = UIDynamicAnimator(referenceView: self)
    }

    deinit {
        nextView = nil
        didStart = nil
        swiping = nil
        didEnd = nil
        didSwipe = nil
        didCancel = nil
        didDisappear = nil
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
        for viewManager in viewManagers.values {
            viewManager.resnapView()
        }
    }

    // MARK: Public APIs
    func topView() -> UIView? {
        return activeViews().first
    }

    // top view first
    func activeViews() -> [UIView] {
        return allViews().filter() {
            view in
            guard let viewManager = viewManagers[view] else { return false }
            if case .swiping(_) = viewManager.state {
                return false
            }
            return true
        }.reversed()
    }

    func loadViews() {
        for _ in UInt(activeViews().count) ..< numberOfActiveView {
            if let nextView = nextView?() {
                insert(nextView, atIndex: 0)
            }
        }
        updateViews()
    }

    func rewind() {
        var viewToBeRewinded: UIView?
        if let lastSwipedView = history.popLast() {
            viewToBeRewinded = lastSwipedView
        } else if let view = previousView?() {
            viewToBeRewinded = view
        }

        guard let view = viewToBeRewinded else { return }

        if UInt(activeViews().count) == numberOfActiveView && activeViews().first != nil {
            remove(activeViews().last!)
        }
        insert(view, atIndex: allViews().count)
        updateViews()
    }
    
    func discardTopCard() {
        guard let topView = topView() else { return }
        
        remove(topView)
        loadViews()
    }

    func discardViews() {
        for view in allViews() {
            remove(view)
        }
    }

    func swipeTopView(inDirection direction: SwipeableViewManager.Direction) {
        guard let topView = topView() else { return }
        let (location, directionVector) = interpretDirection(topView, direction, activeViews(), self)
        swipeTopView(fromPoint: location, inDirection: directionVector)
    }

    func swipeTopView(fromPoint location: CGPoint, inDirection directionVector: CGVector) {
        guard let topView = topView(), let topViewManager = viewManagers[topView] else { return }
        topViewManager.state = .swiping(location, directionVector)
        swipeView(topView, location: location, directionVector: directionVector)
    }

    // MARK: Private APIs
    private func allViews() -> [UIView] {
        return containerView.subviews
    }

    private func insert(_ view: UIView, atIndex index: Int) {
        guard !allViews().contains(view) else {
            // this view has been schedule to be removed
            guard let viewManager = viewManagers[view] else { return }
            viewManager.state = viewManager.snappingStateAtContainerCenter()
            return
        }

        let viewManager = SwipeableViewManager(view: view, containerView: containerView, index: index, miscContainerView: miscContainerView, animator: animator, swipeableView: self)
        viewManagers[view] = viewManager
    }

    private func remove(_ view: UIView) {
        guard allViews().contains(view) else { return }

        viewManagers.removeValue(forKey: view)
        self.didDisappear?(view)
    }

    func updateViews() {
        let activeViews = self.activeViews()
        let inactiveViews = allViews().arrayByRemoveObjectsInArray(activeViews)

        for view in inactiveViews {
            view.isUserInteractionEnabled = false
        }

        guard let gestureRecognizers = activeViews.first?.gestureRecognizers, gestureRecognizers.filter({ gestureRecognizer in gestureRecognizer.state != .possible }).count == 0 else { return }

        for i in 0 ..< activeViews.count {
            let view = activeViews[i]
            view.isUserInteractionEnabled = onlySwipeTopCard ? i == 0 : true
            let shouldBeHidden = i >= Int(numberOfActiveView)
            view.isHidden = shouldBeHidden
            guard !shouldBeHidden else { continue }
            animateView(view, i, activeViews, self)
        }
    }

    func swipeView(_ view: UIView, location: CGPoint, directionVector: CGVector) {
        let direction = SwipeableViewManager.Direction.fromPoint(CGPoint(x: directionVector.dx, y: directionVector.dy))

        scheduleToBeRemoved(view) { aView in
            !self.containerView.convert(aView.frame, to: nil).intersects(UIScreen.main.bounds)
        }
        didSwipe?(view, direction, directionVector)
        loadViews()
    }

    func scheduleToBeRemoved(_ view: UIView, withPredicate predicate: @escaping (UIView) -> Bool) {
        guard allViews().contains(view) else { return }

        history.append(view)
        if UInt(history.count) > numberOfHistoryItem {
            history.removeFirst()
        }
        scheduler.scheduleRepeatedly({ () -> Void in
            self.allViews().arrayByRemoveObjectsInArray(self.activeViews()).filter({ view in predicate(view) }).forEach({ view in self.remove(view) })
            }, interval: 0.3) { () -> Bool in
                print("\(self.activeViews().count), \(self.allViews().count)")
                return self.activeViews().count == self.allViews().count
        }
    }

}

// MARK: - Default behaviors
extension SwipeableView {

    static func defaultAnimateViewHandler() -> AnimateViewHandler {
        func toRadian(_ degree: CGFloat) -> CGFloat {
            return degree * CGFloat(Double.pi / 180)
        }

        func rotateView(_ view: UIView, forDegree degree: CGFloat, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: SwipeableView,  completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                transform = transform.rotated(by: toRadian(degree))
                transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                view.transform = transform
                },
                completion: completion)
        }

        return { (view: UIView, index: Int, views: [UIView], swipeableView: SwipeableView) in
            let degree = CGFloat(1)
            let duration = 0.4
            let offset = CGPoint(x: 0, y: swipeableView.bounds.height * 0.3)
            switch index {
            case 0:
                rotateView(view, forDegree: 0, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            case 1:
                rotateView(view, forDegree: degree, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            case 2:
                rotateView(view, forDegree: -degree, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            default:
                rotateView(view, forDegree: 0, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
            }
        }
    }

    static func defaultInterpretDirectionHandler() -> InterpretDirectionHandler {
        return { (topView: UIView, direction: SwipeableViewManager.Direction, views: [UIView], swipeableView: SwipeableView) in
            let programmaticSwipeVelocity = CGFloat(1000)
            let location = CGPoint(x: topView.center.x, y: topView.center.y*0.7)
            var directionVector: CGVector!

            switch direction {
            case .Left:
                directionVector = CGVector(dx: -programmaticSwipeVelocity, dy: 0)
            case .Right:
                directionVector = CGVector(dx: programmaticSwipeVelocity, dy: 0)
            case .Up:
                directionVector = CGVector(dx: 0, dy: -programmaticSwipeVelocity)
            case .Down:
                directionVector = CGVector(dx: 0, dy: programmaticSwipeVelocity)
            default:
                directionVector = CGVector(dx: 0, dy: 0)
            }
            
            return (location, directionVector)
        }
    }

    static func defaultShouldSwipeViewHandler() -> ShouldSwipeHandler {
        return { (view: UIView, movement: SwipeableViewManager.Movement, swipeableView: SwipeableView) -> Bool in
            let translation = movement.translation
            let velocity = movement.velocity
            let bounds = swipeableView.bounds
            let minTranslationInPercent = swipeableView.minTranslationInPercent
            let minVelocityInPointPerSecond = swipeableView.minVelocityInPointPerSecond
            let allowedDirection = swipeableView.allowedDirection

            func areTranslationAndVelocityInTheSameDirection() -> Bool {
                return CGPoint.areInSameTheDirection(translation, p2: velocity)
            }

            func isDirectionAllowed() -> Bool {
                return SwipeableViewManager.Direction.fromPoint(translation).intersection(allowedDirection) != .None
            }

            func isTranslationLargeEnough() -> Bool {
                return abs(translation.x) > minTranslationInPercent * bounds.width || abs(translation.y) > minTranslationInPercent * bounds.height
            }

            func isVelocityLargeEnough() -> Bool {
                return velocity.magnitude > minVelocityInPointPerSecond
            }

            return isDirectionAllowed() && areTranslationAndVelocityInTheSameDirection() && (isTranslationLargeEnough() || isVelocityLargeEnough())
        }
    }
}

// MARK: - Helper extensions
func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

extension Array where Element: Equatable {
    func arrayByRemoveObjectsInArray(_ array: [Element]) -> [Element] {
        return Array(self).filter() { element in !array.contains(element) }
    }
}
