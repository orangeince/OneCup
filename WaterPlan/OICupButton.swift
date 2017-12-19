//
//  OICupButton.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/14.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class OICupButton: UIButton, OIViewAnimatorDelegate {
    fileprivate var _animator: OIViewAnimator!
    fileprivate var image: UIImage?
    
    fileprivate var _gradient: CGFloat = 0.18
    
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
    override func draw(_ rect: CGRect) {
        //
        super.draw(rect)
        //let radius = min(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2.0
        let width = rect.width
        let height = rect.height
        
        let color = self.tintColor
        UIColor.darkGray.setStroke()
        color?.setFill()
        let path = CGMutablePath()
        
        path.move(to: .zero)
        
        let tmpWidth = CGFloat(width * _gradient)
        //CGPathAddLineToPoint(path, nil, tmpWidth, height)
        //CGPathAddLineToPoint(path, nil, width - tmpWidth, height)
        //CGPathAddLineToPoint(path, nil, width, 0)
        //CGPathAddLineToPoint(path, nil, 0, 0)
        path.addLine(to: CGPoint(x: tmpWidth, y: height))
        path.addLine(to: CGPoint(x: width - tmpWidth, y: height))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: .zero)
        path.closeSubpath()
        let shape = CAShapeLayer()
        shape.path = path
        self.layer.mask = shape
        
        /*
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path)
        let shadowSize = CGSize(width: 5, height: 50)
        CGContextSetShadow(context, shadowSize, 5)
        CGContextFillPath(context)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, tmpWidth, height)
        CGContextStrokePath(context)
        CGContextMoveToPoint(context, tmpWidth, height)
        CGContextAddLineToPoint(context, width - tmpWidth, height)
        CGContextStrokePath(context)
        CGContextMoveToPoint(context, width - tmpWidth, height)
        CGContextAddLineToPoint(context, width, 0)
        CGContextStrokePath(context)
        */
        
    }
    func viewAnimatorUpdated(_ viewAnimator: OIViewAnimator) {
        self.setNeedsDisplay()
    }
    func viewAnimatorStopped(_ viewAnimator: OIViewAnimator) {
    }
    func setGradient() {
        if _animator.isReversal {
            self._gradient = 0.0
        } else {
            self._gradient = 0.18
        }
    }
    func animate(_ duration: TimeInterval)
    {
        _animator.isReversal = false
        _animator.animate(yAxisDuration: duration)
    }
    func animateRevarsal(_ duration: TimeInterval) {
        _animator.isReversal = true
        _animator.animate(yAxisDuration: duration)
    }
    
    func animate(xDuration duration: TimeInterval)
    {
        setGradient()
        _animator.animate(xAxisDuration: duration)
    }
    func animateRevarsal(xDuration duration: TimeInterval) {
        _animator.isReversal = true
        _animator.animate(xAxisDuration: duration)
    }
    
    func animate(_ xDuration: TimeInterval, yDuration: TimeInterval) {
        _animator.isReversal = false
        _animator.animate(xAxisDuration: xDuration, yAxisDuration: yDuration)
    }
    func animateRevasal(_ xDuration: TimeInterval, yDuration: TimeInterval) {
        _animator.isReversal = true
        _animator.animate(xAxisDuration: xDuration, yAxisDuration: yDuration)
    }
}
