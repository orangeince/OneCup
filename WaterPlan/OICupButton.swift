//
//  OICupButton.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/14.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class OICupButton: UIButton, OIViewAnimatorDelegate {
    private var _animator: OIViewAnimator!
    private var image: UIImage?
    
    private var _gradient: CGFloat = 0.18
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    func initialize() {
        _animator = OIViewAnimator()
        _animator.delegate = self
    }
    func abseverForWaterFrame() {
        
    }
    override func drawRect(rect: CGRect) {
        //
        super.drawRect(rect)
        //let radius = min(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2.0
        let width = CGRectGetWidth(rect)
        let height = CGRectGetHeight(rect)
        
        let color = self.tintColor
        UIColor.lightGrayColor().setStroke()
        color.setFill()
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0, 0)
        let tmpWidth = CGFloat(width * _gradient)
        CGPathAddLineToPoint(path, nil, tmpWidth, height)
        CGPathAddLineToPoint(path, nil, width - tmpWidth, height)
        CGPathAddLineToPoint(path, nil, width, 0)
        CGPathAddLineToPoint(path, nil, 0, 0)
        CGPathCloseSubpath(path)
        let shape = CAShapeLayer()
        shape.path = path
        self.layer.mask = shape
        
        /*
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path)
        */
        
    }
    func viewAnimatorUpdated(viewAnimator: OIViewAnimator) {
        self.setNeedsDisplay()
    }
    func viewAnimatorStopped(viewAnimator: OIViewAnimator) {
    }
    func setGradient() {
        if _animator.isReversal {
            self._gradient = 0.0
        } else {
            self._gradient = 0.18
        }
    }
    func animate(duration: NSTimeInterval)
    {
        _animator.isReversal = false
        _animator.animate(yAxisDuration: duration)
    }
    func animateRevarsal(duration: NSTimeInterval) {
        _animator.isReversal = true
        _animator.animate(yAxisDuration: duration)
    }
    
    func animate(xDuration duration: NSTimeInterval)
    {
        setGradient()
        _animator.animate(xAxisDuration: duration)
    }
    func animateRevarsal(xDuration duration: NSTimeInterval) {
        _animator.isReversal = true
        _animator.animate(xAxisDuration: duration)
    }
    
    func animate(xDuration: NSTimeInterval, yDuration: NSTimeInterval) {
        _animator.isReversal = false
        _animator.animate(xAxisDuration: xDuration, yAxisDuration: yDuration)
    }
    func animateRevasal(xDuration: NSTimeInterval, yDuration: NSTimeInterval) {
        _animator.isReversal = true
        _animator.animate(xAxisDuration: xDuration, yAxisDuration: yDuration)
    }
}