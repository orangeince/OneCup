//
//  TransitioningDelegates.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/28.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class TransitioningDelegateForWaterVolume: NSObject, UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndWaterVolume(presenting: true)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndWaterVolume(presenting: false)
    }
}

class AnimationTransitioningForDrinkingAndWaterVolume: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = true
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        
        if presenting {
            // *** presenting *** //
            
            guard
                let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? DrinkingViewController,
                toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? WaterVolumeViewController,
                toView = transitionContext.viewForKey(UITransitionContextToViewKey) as? UIVisualEffectView
            else {
                return
            }
            
            let cup = toVC.cupBtn
            let volumeBtns = toVC.volumeBtns
            cup.frame = fromVC.drinkingCup.frame
            for btn in volumeBtns {
                btn.center = cup.center
                btn.alpha = 0
            }
            //toView.alpha = 0.0
            
            containerView.addSubview(toView)
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                //toView.alpha = 1.0
                toView.effect = UIBlurEffect(style: .Dark)
                }, completion: nil)
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 1.0,
                options: .CurveEaseIn,
                animations: {
                    () -> Void in
                    cup.transform = CGAffineTransformScale(cup.transform, 1.6, 1.6)
            
                    UIView.animateWithDuration(0.6, delay: 0.3, options: .TransitionFlipFromBottom, animations: { () -> Void in
                        let firstBtn = volumeBtns[0]
                        firstBtn.alpha = 1.0
                        firstBtn.center = CGPoint(x: cup.center.x, y: cup.frame.origin.y - firstBtn.frame.height/2.0 - 30.0)
                        for index in 1 ..< volumeBtns.count {
                            let curBtn = volumeBtns[index]
                            let preBtn = volumeBtns[index-1]
                            curBtn.alpha = 1.0
                            curBtn.center = CGPoint(x: preBtn.center.x, y: preBtn.center.y - preBtn.frame.height - 30.0)
                        }
                        }, completion: nil)
                },
                completion: {
                    (finished: Bool) -> Void in
                    let success = !transitionContext.transitionWasCancelled()
                    if !success {
                        toView.removeFromSuperview()
                    }
                    transitionContext.completeTransition(success)
                })
        } else {
            // *** dismissing *** //
            
            guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? WaterVolumeViewController else {
                return
            }
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) as? UIVisualEffectView
            
            let cup = fromVC.cupBtn
            let volumeBtns = fromVC.volumeBtns
            
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext),
                delay: 0,
                options: .TransitionFlipFromTop,
                animations: {
                    () -> Void in
                        for btn in volumeBtns {
                            btn.alpha = 0.0
                            btn.center = cup.center
                        }
            
                    UIView.animateWithDuration(0.6,
                        delay: 0.3,
                        usingSpringWithDamping: 0.6,
                        initialSpringVelocity: 0.5,
                        options: .CurveEaseOut,
                        animations: { () -> Void in cup.transform = CGAffineTransformIdentity },
                        completion: nil)
                    
                    UIView.animateWithDuration(0.3,
                        delay: 0.3,
                        options: .CurveEaseInOut,
                        animations: { () -> Void in fromView!.effect = nil },
                        completion: nil)
                },
                completion: {
                    (finished: Bool) -> Void in
                        let success = !transitionContext.transitionWasCancelled()
                        transitionContext.completeTransition(success)
                })
            
        }
    }
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.6
    }
}

class TransitioningDelegateForSettings: NSObject, UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndSettings(presenting: true)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndSettings(presenting: false)
        //return nil
    }
}

class AnimationTransitioningForDrinkingAndSettings: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = true
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
            containerView.addSubview(toView)
            
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500.0
            containerView.layer.sublayerTransform = transform
            
            if presenting {
                toView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 1, 0)
                transform = CATransform3DRotate(CATransform3DIdentity, -CGFloat(M_PI_2), 0, 1, 0)
            } else {
                toView.layer.transform = CATransform3DMakeRotation(CGFloat(-M_PI / 2.0), 0, 1, 0)
                transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(M_PI_2), 0, 1, 0)
            }
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext) / 2.0, animations: { () -> Void in
                fromView.layer.transform = transform
                    UIView.animateWithDuration(0.25,
                        delay: 0.25,
                        options: .CurveEaseIn ,
                        animations: { () -> Void in
                        toView.layer.transform = CATransform3DIdentity
                        }, completion: { (finished: Bool) -> Void in
                        let success = !transitionContext.transitionWasCancelled()
                        transitionContext.completeTransition(success)
                    })
                }, completion: nil)
    }
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
}

class TransitioningDelegateForReminderNew: NSObject, UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PresentationControllerForReminderNew(presentedViewController: presented, presentingViewController: presenting)
    }
}
class PresentationControllerForReminderNew: UIPresentationController {
    var dimmingView: UIView?
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = self.containerView!.bounds
        presentedViewFrame.size = CGSizeMake(containerBounds.width, containerBounds.height / 2.0)
        presentedViewFrame.origin.y = containerBounds.height - presentedViewFrame.height
        return presentedViewFrame
    }
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        self.dimmingView = UIView()
        self.dimmingView!.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.dimmingView!.alpha = 0.0
        let gesture = UITapGestureRecognizer(target: self, action: "dimmingViewTap:")
        self.dimmingView!.addGestureRecognizer(gesture)
    }
    override func presentationTransitionWillBegin() {
        let containerView = self.containerView!
        let presentedViewController = self.presentedViewController
        //let presentingViewController = self.presentingViewController
        
        self.dimmingView!.frame = containerView.bounds
        self.dimmingView!.alpha = 0.0
        containerView.insertSubview(self.dimmingView!, atIndex: 0)
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView!.alpha = 1.0
                self.presentingViewController.view.transform = CGAffineTransformMakeScale(0.96, 0.96)
                }, completion: nil)
        } else {
            self.dimmingView!.alpha = 1.0
            self.presentingViewController.view.transform = CGAffineTransformMakeScale(0.96, 0.96)
        }
    }
    override func presentationTransitionDidEnd(completed: Bool) {
        if !completed {
            self.dimmingView!.removeFromSuperview()
        }
    }
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView!.alpha = 0.0
                self.presentingViewController.view.transform = CGAffineTransformIdentity
                if let presented = self.presentedViewController as? ReminderNewViewController{
                    if let reminderSetting = presented.SaveDataDelegate {
                        if let selectedRow = reminderSetting.tableView.indexPathForSelectedRow {
                            reminderSetting.tableView.deselectRowAtIndexPath(selectedRow, animated: true)
                        }
                    }
                }
                }, completion: nil)
        } else {
            self.dimmingView!.alpha = 0.0
            self.presentingViewController.view.transform = CGAffineTransformIdentity
        }
    }
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            self.dimmingView!.removeFromSuperview()
        }
    }
    func dimmingViewTap(gesture: UITapGestureRecognizer) {
        if let presented = self.presentedViewController as? ReminderNewViewController {
            presented.alertTitleField.resignFirstResponder()
            
        }
        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}