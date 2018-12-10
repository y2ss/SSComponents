//
//  PictureSwipeVC2.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/26.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class PictureSwipeVC2: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var img: UIImageView!
    private var percentDrivenTransition: UIPercentDrivenInteractiveTransition?
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        img.center = CGPoint(x: UIScreen.width * 0.5, y: 0)
        img.y = self.navigationController!.navigationBar.height + 40
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.delegate = self
        
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panGestrue(_:)))
        pan.edges = .left
        self.view.addGestureRecognizer(pan)
    }
    
    @objc private func panGestrue(_ pgr: UIScreenEdgePanGestureRecognizer) {
        let progress = pgr.translation(in: self.view).x / self.view.bounds.width
        if pgr.state == .began {
            self.percentDrivenTransition = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewController(animated: true)
        } else if pgr.state == .changed {
            self.percentDrivenTransition?.update(progress)
        } else if pgr.state == .cancelled || pgr.state == .ended {
            if progress > 0.5 {
                self.percentDrivenTransition?.finish()
            } else {
                percentDrivenTransition?.cancel()
            }
            percentDrivenTransition = nil
        }
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return SSPictureSwiper(type: .pop)
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController is SSPictureSwiper {
            return self.percentDrivenTransition
        }
        return nil
    }

}
