//
//  TransitioningDelegates.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/28.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class TransitioningDelegateForWaterVolume: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndWaterVolume(presenting: true)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndWaterVolume(presenting: false)
    }
}

class AnimationTransitioningForDrinkingAndWaterVolume: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = true
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if presenting {
            // *** presenting *** //
            
            guard
                let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? DrinkingViewController,
                let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? WaterVolumeViewController,
                let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) as? UIVisualEffectView
                else {
                    return
            }
            
            let cup = toVC.cupBtn
            let volumeBtns = toVC.volumeBtns
            let cupFrame = fromVC.drinkingCup.frame
            let picker = toVC.volumePicker
            let cupBlurView = toVC.cupBlurView
            let submitBtn = toVC.submitBtn
            let cupWaterView = toVC.waterView
            let imageMask = toVC.imageMask
            let pickedVolume = fromVC.pickedVolume
            let waterColor = fromVC.waterView.backgroundColor!.withAlphaComponent(0.8)
            //cup.backgroundColor = fromVC.view.backgroundColor
            
            fromVC.drinkingCup.alpha = 0.0
            cup?.frame = cupFrame.offsetBy(dx: 0, dy: 0)
            for btn in volumeBtns {
                btn.center = (cup?.center)!
                btn.alpha = 0
            }
            let width = (cup?.frame.width)! * 2.0
            let height = (cup?.frame.height)! * 2.0
            let originX = (cup?.frame.origin.x)! - (cup?.frame.width)! / 2.0
            let originY = (cup?.frame.origin.y)! - (cup?.frame.height)!
            let cupFinalFrame = CGRect(x: originX, y: originY, width: width, height: height)
            //toView.alpha = 0.0
            
            containerView.addSubview(toView)
            
            let duration = self.transitionDuration(using: transitionContext)
            let durationFrist = duration / 4.0
            
                    toView.effect = UIBlurEffect(style: .dark)
            UIView.animate(
                withDuration: durationFrist,
                animations: {
                    () -> Void in
                    cup?.transform = (cup?.transform.scaledBy(x: 2.0, y: 2.0))!
                    cup?.frame.origin.x = originX
                    cup?.frame.origin.y = originY
                },
                completion: {
                    (finished: Bool) -> Void in
                    
                    cup?.transform = CGAffineTransform.identity
                    cup?.frame = cupFinalFrame
                    cup?.setNeedsDisplay()
                    cupBlurView.frame = (cup?.bounds)!
                    cupBlurView.effect = UIBlurEffect(style: .light)
                    toVC.waterView.backgroundColor = waterColor
                    cup?.addSubview(toVC.waterView)
                    cup?.addSubview(cupBlurView)
                    let bounds = cup?.bounds
                    cupWaterView.frame = CGRect(x: 0, y: (bounds?.height)!, width: (bounds?.width)!, height: 0)
                    picker.frame = CGRect(x: 0, y: 0, width: (bounds?.width)!, height: (bounds?.height)! / 2.0)
                    submitBtn.frame = CGRect(x: (bounds?.width)! / 2.0 - 20.0, y: (bounds?.height)! / 2.0, width: 40.0, height: 40.0)
                    submitBtn.setTitle("喝", for: UIControl.State())
                    submitBtn.layer.cornerRadius = 20.0
                    //picker.alpha = 0.0
                    //submitBtn.alpha = 0.0
                    
                    imageMask.frame = bounds!
                    
                    cupBlurView.contentView.addSubview(picker)
                    cupBlurView.contentView.addSubview(submitBtn)
                    cupBlurView.contentView.addSubview(imageMask)
                    
                    toVC.initPickedVolume(pickedVolume)
                    
                    UIView.animate(
                        withDuration: duration - durationFrist,
                        delay: 0.0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 1.0,
                        options: .curveEaseIn,
                        animations: {
                            () -> Void in
                            
                            imageMask.frame = imageMask.frame.offsetBy(dx: 0, dy: imageMask.frame.height)
                            //imageMask.alpha = 0.0
                            let firstBtn = volumeBtns[0]
                            firstBtn.alpha = 1.0
                            firstBtn.center = CGPoint(x: (cup?.center.x)!, y: (cup?.frame.origin.y)! - firstBtn.frame.height/2.0 - 30.0)
                            for index in 1 ..< volumeBtns.count {
                                let curBtn = volumeBtns[index]
                                let preBtn = volumeBtns[index-1]
                                curBtn.alpha = 1.0
                                curBtn.center = CGPoint(x: preBtn.center.x, y: preBtn.center.y - preBtn.frame.height - 30.0)
                            }
                        },
                        completion: {
                            (finished: Bool) -> Void in
                            fromVC.drinkingCup.alpha = 1.0
                            
                            let success = !transitionContext.transitionWasCancelled
                            if !success {
                                toView.removeFromSuperview()
                            }
                            transitionContext.completeTransition(success)
                    })
            })
        } else {
            // *** dismissing *** //
            
            guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? WaterVolumeViewController else {
                return
            }
            guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? DrinkingViewController else {
                return
            }
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) as? UIVisualEffectView
            
            let cup = fromVC.cupBtn
            let volumeBtns = fromVC.volumeBtns
            let imageMask = fromVC.imageMask
            let cupFinalFrame = toVC.drinkingCup.frame.offsetBy(dx: 0, dy: 0)
            
            let duration = self.transitionDuration(using: transitionContext)
            let durationFrist = duration / 4.0 * 3.0
            UIView.animate(
                withDuration: durationFrist,
                delay: 0,
                options: .transitionFlipFromTop,
                animations: {
                    () -> Void in
                    for btn in volumeBtns {
                        btn.alpha = 0.0
                        btn.center = (cup?.center)!
                    }
                    imageMask.frame = imageMask.frame.offsetBy(dx: 0, dy: -imageMask.frame.height)
                },
                completion: {
                    (finished: Bool) -> Void in
                    UIView.animate(
                        withDuration: duration - durationFrist,
                        animations: {
                            () -> Void in
                            cup?.transform = (cup?.transform.scaledBy(x: 0.5, y: 0.5))!
                            cup?.frame.origin = cupFinalFrame.origin
                        },
                        completion: {
                            (finished: Bool) -> Void in
                            fromView!.effect = nil
                            let success = !transitionContext.transitionWasCancelled
                            transitionContext.completeTransition(success)
                    })
            })
            
        }
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
}
/* 初版 没有自定义容量选择
class AnimationTransitioningForDrinkingAndWaterVolume1: NSObject, UIViewControllerAnimatedTransitioning {
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
            let cupFrame = fromVC.drinkingCup.frame
            cup.frame = cupFrame.offsetBy(dx: 0, dy: 0)
            for btn in volumeBtns {
                btn.center = cup.center
                btn.alpha = 0
            }
            //toView.alpha = 0.0
            
            containerView.addSubview(toView)
            
            let duration = self.transitionDuration(transitionContext)
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                //toView.alpha = 1.0
                toView.effect = UIBlurEffect(style: .Dark)
                }, completion: nil)
            UIView.animateWithDuration(duration,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 1.0,
                options: .CurveEaseIn,
                animations: {
                    () -> Void in
                    //cup.animateRevarsal(duration)
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
*/

class TransitioningDelegateForSettings: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndSettings(presenting: true)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndSettings(presenting: false)
    }
}

class AnimationTransitioningForDrinkingAndSettings: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = true
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        containerView.addSubview(toView)
        
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
        containerView.layer.sublayerTransform = transform
        
        if presenting {
            toView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0, 1, 0)
            transform = CATransform3DRotate(CATransform3DIdentity, -CGFloat(Double.pi / 2), 0, 1, 0)
        } else {
            toView.layer.transform = CATransform3DMakeRotation(CGFloat(-Double.pi / 2.0), 0, 1, 0)
            transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(Double.pi / 2), 0, 1, 0)
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        let durationHalf = duration / 2.0
        
        UIView.animate(withDuration: durationHalf, animations: { () -> Void in
            fromView.layer.transform = transform
            UIView.animate(withDuration: durationHalf,
                delay: durationHalf,
                options: .curveEaseIn ,
                animations: { () -> Void in
                    toView.layer.transform = CATransform3DIdentity
                }, completion: { (finished: Bool) -> Void in
                    let success = !transitionContext.transitionWasCancelled
                    transitionContext.completeTransition(success)
            })
            }, completion: nil)
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}

class TransitioningDelegateForStatistic: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndStatistic(presenting: true)
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationTransitioningForDrinkingAndStatistic(presenting: false)
    }
}

class AnimationTransitioningForDrinkingAndStatistic: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = true
    var transitionStyle: TransitonStyleForStatistic = .entryTopBottom
    enum TransitonStyleForStatistic {
        case scale
        case entryTopBottom
        case entryLeft
    }
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        switch Int(arc4random()) % 3 {
        case 0:
            self.transitionStyle = .scale
        case 1:
            self.transitionStyle = .entryTopBottom
        case 2:
            self.transitionStyle = .entryLeft
        default:
            self.transitionStyle = .entryLeft
        }
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        //let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        //let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromView = fromVC.view
        let toView = toVC.view
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        
        containerView.addSubview(fromView!)
        containerView.addSubview(toView!)
        containerView.backgroundColor = toView?.backgroundColor
        
        toView?.alpha = 0.0
        
        if self.presenting {
            toView?.backgroundColor = toView?.backgroundColor?.withAlphaComponent(0.0)
            if let vc = toVC as? StatisticViewController {
                switch self.transitionStyle {
                case .scale:
                    vc.view.transform = vc.view.transform.scaledBy(x: 0.01, y: 0.01)
                case .entryTopBottom:
                    var offsetY = vc.volumeChart.frame.origin.y + vc.volumeChart.frame.height
                    vc.volumeChart.transform = vc.volumeChart.transform.translatedBy(x: 0, y: -offsetY)
                    offsetY = containerView.bounds.height - vc.clockView.frame.origin.y
                    vc.clockView.transform = vc.clockView.transform.translatedBy(x: 0, y: offsetY)
                case .entryLeft:
                    var offsetX = vc.volumeChart.frame.origin.x + vc.volumeChart.frame.width
                    vc.volumeChart.transform = vc.volumeChart.transform.translatedBy(x: -offsetX, y: 0)
                    offsetX = vc.clockView.frame.origin.x + vc.clockView.frame.width
                    vc.clockView.transform = vc.volumeChart.transform.translatedBy(x: -offsetX, y: 0)
                }
            }
        } else {
            containerView.backgroundColor = fromView?.backgroundColor
            //if let vc = fromVC as? StatisticViewController {
            //   vc.clearDatas(true)
            //}
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        let durationHalf = duration / 2.0
        
        UIView.animate(
            withDuration: durationHalf,
            animations: {
                () -> Void in
                
                if self.presenting {
                    if let vc = fromVC as? DrinkingViewController {
                        vc.saveDrinkedVolume()
                    }
                } else {
                    if let vc = fromVC as? StatisticViewController {
                        switch self.transitionStyle {
                        case .scale:
                            vc.view.transform = vc.view.transform.scaledBy(x: 0.01, y: 0.01)
                            vc.view.alpha = 0.0
                        case .entryTopBottom:
                            var offsetY = vc.volumeChart.frame.origin.y + vc.volumeChart.frame.height
                            vc.volumeChart.transform = vc.volumeChart.transform.translatedBy(x: 0, y: -offsetY)
                            offsetY = containerView.bounds.height - vc.clockView.frame.origin.y
                            vc.clockView.transform = vc.clockView.transform.translatedBy(x: 0, y: offsetY)
                        case .entryLeft:
                            var offsetX = vc.volumeChart.frame.origin.x + vc.volumeChart.frame.width
                            vc.volumeChart.transform = vc.volumeChart.transform.translatedBy(x: -offsetX, y: 0)
                            offsetX = vc.clockView.frame.origin.x + vc.clockView.frame.width
                            vc.clockView.transform = vc.volumeChart.transform.translatedBy(x: -offsetX, y: 0)
                        }
                    }
                }
                
            },
            completion: {
                (finished: Bool) -> Void in
                UIView.animate(
                    withDuration: durationHalf,
                    //delay: durationHalf,
                    //options: UIViewAnimationOptions.CurveLinear,
                    animations: { () -> Void in
                        fromView?.alpha = 0.0
                        toView?.alpha = 1.0
                        if self.presenting {
                            if let vc = toVC as? StatisticViewController {
                                vc.view.transform = CGAffineTransform.identity
                                vc.volumeChart.transform = CGAffineTransform.identity
                                vc.clockView.transform = CGAffineTransform.identity
                                vc.initializeDatas(true)
                            }
                        } else {
                            if let vc = toVC as? DrinkingViewController {
                                vc.restoreDrinkedVolume()
                            }
                        }
                    },
                    completion: {
                        (finished: Bool) -> Void in
                        let success = !transitionContext.transitionWasCancelled
                        if success {
                            fromView?.removeFromSuperview()
                        }
                        toView?.backgroundColor = toView?.backgroundColor?.withAlphaComponent(1.0)
                        transitionContext.completeTransition(success)
                })
                
            }
        )
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
}

class TransitioningDelegateForReminderNew: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationControllerForReminderNew(presentedViewController: presented, presenting: presenting)
    }
}
class PresentationControllerForReminderNew: UIPresentationController {
    var dimmingView: UIView?
    override var frameOfPresentedViewInContainerView : CGRect {
        var presentedViewFrame = CGRect.zero
        let containerBounds = self.containerView!.bounds
        presentedViewFrame.size = CGSize(width: containerBounds.width, height: containerBounds.height / 5.0 * 3.0)
        presentedViewFrame.origin.y = containerBounds.height - presentedViewFrame.height
        return presentedViewFrame
    }
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.dimmingView = UIView()
        self.dimmingView!.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.dimmingView!.alpha = 0.0
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PresentationControllerForReminderNew.dimmingViewTap(_:)))
        self.dimmingView!.addGestureRecognizer(gesture)
    }
    override func presentationTransitionWillBegin() {
        let containerView = self.containerView!
        let presentedViewController = self.presentedViewController
        //let presentingViewController = self.presentingViewController
        
        self.dimmingView!.frame = containerView.bounds
        self.dimmingView!.alpha = 0.0
        containerView.insertSubview(self.dimmingView!, at: 0)
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView!.alpha = 1.0
                self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                }, completion: nil)
        } else {
            self.dimmingView!.alpha = 1.0
            self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            self.dimmingView!.removeFromSuperview()
        }
    }
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView!.alpha = 0.0
                self.presentingViewController.view.transform = CGAffineTransform.identity
                if let presented = self.presentedViewController as? ReminderNewViewController{
                    if let reminderSetting = presented.SaveDataDelegate {
                        if let selectedRow = reminderSetting.tableView.indexPathForSelectedRow {
                            reminderSetting.tableView.deselectRow(at: selectedRow, animated: true)
                        }
                    }
                }
                }, completion: nil)
        } else {
            self.dimmingView!.alpha = 0.0
            self.presentingViewController.view.transform = CGAffineTransform.identity
        }
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.dimmingView!.removeFromSuperview()
        }
    }
    @objc func dimmingViewTap(_ gesture: UITapGestureRecognizer) {
        if let presented = self.presentedViewController as? ReminderNewViewController {
            presented.alertTitleField.resignFirstResponder()
        }
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
}
