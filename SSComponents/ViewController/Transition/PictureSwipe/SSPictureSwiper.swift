//
//  SSPictureSwipe.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/26.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SSPictureSwiper: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum PictureSwiperType {
        case pop
        case push
    }
    
    var type: PictureSwiperType
    
    init(type: PictureSwiperType) {
        self.type = type
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if type == .push {
            let fromVc = transitionContext.viewController(forKey: .from) as! PictureSwipeVC1
            let toVc = transitionContext.viewController(forKey: .to) as! PictureSwipeVC2
            let container = transitionContext.containerView
            //创建一个 Cell 中 imageView 的截图，并把 imageView 隐藏，造成使用户以为移动的就是 imageView 的假象
            let snapshotview = fromVc.selectedCell.imgview.snapshotView(afterScreenUpdates: false)
            snapshotview?.frame = container.convert(fromVc.selectedCell.imgview.frame, from: fromVc.selectedCell)
            fromVc.selectedCell.imgview.isHidden = true
            //设置目标控制器的位置，并把透明度设为0，在后面的动画中慢慢显示出来变为1
            toVc.view.frame = transitionContext.finalFrame(for: toVc)
            toVc.view.alpha = 0
            //都添加到 container 中。注意顺序不能错了
            container.addSubview(toVc.view)
            container.addSubview(snapshotview!)
            
            //
            toVc.img.layoutIfNeeded()

            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                snapshotview?.frame = toVc.img.frame
                toVc.view.alpha = 1
            }) { flag in
                fromVc.selectedCell.imgview.isHidden = false
                toVc.img.image = toVc.image
                snapshotview?.removeFromSuperview()
                //一定要记得动画完成后执行此方法，让系统管理 navigation
                transitionContext.completeTransition(true)
            }
        } else {
            let fromVc = transitionContext.viewController(forKey: .from) as! PictureSwipeVC2
            let toVc = transitionContext.viewController(forKey: .to) as! PictureSwipeVC1
            let container = transitionContext.containerView
            let snapshotView = fromVc.img.snapshotView(afterScreenUpdates: false)
            snapshotView?.frame = container.convert(fromVc.img.frame, to: fromVc.view)
            fromVc.img.isHidden = true
            toVc.view.frame = transitionContext.finalFrame(for: toVc)
            toVc.selectedCell.imgview.isHidden = true
            container.insertSubview(toVc.view, belowSubview: fromVc.view)
            container.addSubview(snapshotView!)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                snapshotView?.frame = container.convert(toVc.selectedCell.imgview.frame, from: toVc.selectedCell)
                fromVc.view.alpha = 0
            }) { flag in
                toVc.selectedCell.imgview.isHidden = false
                snapshotView?.removeFromSuperview()
                fromVc.img.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    
}
