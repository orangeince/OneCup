//
//  OIClockView.swift
//  AnimationTest
//
//  Created by 赵少龙 on 15/12/5.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class OIClockView: UIView, OIViewAnimatorDelegate  {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    private var _data = [(Int, Int, Int)]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    private var _animator: OIViewAnimator!
    private var _radius = CGFloat(0)
    private var _margin = CGFloat(0)
    private var _centre = CGPoint(x: 0, y: 0)
    private var _dataAreaRadius = CGFloat(0)
    private var _phases:Int = 7
    private var _volumeOfPhase: Int = 100
    private var _maxVolume = 1000
    private var _drawScaleLine = false
    
    var fillClock = true
    var fillColor = UIColor.whiteColor()
    var dataFillColor: UIColor!
    var strokeColor = UIColor.blackColor()
    var scaleColor = UIColor.blackColor()
    var dataPointRedius = CGFloat(3.0)
    
    var drawRatio = CGFloat(1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    internal func initialize() {
        _animator = OIViewAnimator()
        _animator.delegate = self
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        let radius = min(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2.0
        let orginX = CGRectGetWidth(rect) / 2.0
        let orginY = CGRectGetHeight(rect) / 2.0
        
        if self.dataFillColor == nil {
            self.dataFillColor = self.tintColor
        }
        
        fillColor.setFill()
        strokeColor.setStroke()
        CGContextSetLineWidth(context, 2)
        
        let margin = 0.1
        let tmpRect = CGRectMake(
            orginX - radius * CGFloat(1.0 - margin),
            orginY - radius * CGFloat(1.0 - margin),
            2 * CGFloat(1 - margin) * radius,
            2 * CGFloat(1 - margin) * radius
        )
        CGContextAddEllipseInRect(context, tmpRect)
        if fillClock {
            CGContextFillPath(context)
        } else {
            CGContextStrokePath(context)
        }
        
        _radius = CGFloat(1 - margin) * radius
        
        var font = UIFont(name: "HelveticaNeue", size: 12.0)
        
        let aniamteRatio = _animator.isReversal ? 1 - _animator.phaseY : _animator.phaseY
        
        let phaseAngle = aniamteRatio * CGFloat(M_PI * 2.0)
        
        //draw the clock
        for idx in 0 ..< 12 {
            let i = 2 * idx
            let angle = CGFloat(Double(i) * M_PI / 12.0)
            //if angle > phaseAngle || (_animator.isReversal && phaseAngle == 0.0) {
                //break
            //}
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, orginX, orginY)
            CGContextRotateCTM(context, angle)
            CGContextMoveToPoint(context, 0, _radius)
            let lengthFactor = i % 6 == 0 ? 0.01 : 0.01
            let length = _radius *  CGFloat(lengthFactor)
            if _drawScaleLine {
            //CGContextSetLineWidth(context, 1)
                CGContextAddLineToPoint(context, 0, _radius - length)
                CGContextStrokePath(context)
            }
            CGContextMoveToPoint(context, 0, 0)
            CGContextAddLineToPoint(context, 0, _radius - 3 * length)
            CGContextSetLineWidth(context, 0.05)
            CGContextStrokePath(context)
            
            if i % 2 == 0 {
                let offX: CGFloat = i < 10 ? 4.0 : 2.0
                let textHeight = font!.lineHeight
                _dataAreaRadius = _radius - length - textHeight
                //CGContextTranslateCTM(context, 0, _radius + textHeight / 2.0)
                CGContextTranslateCTM(context, 0, _radius - length - textHeight / 2.0)
                //CGContextMoveToPoint(context, 0, length + textHeight)
                CGContextRotateCTM(context, -CGFloat(Double(i) * M_PI / 12.0))
                let textRect = CGRectMake(0 - textHeight / offX, -textHeight / 2.0, textHeight, textHeight)
                var attrs = [String: AnyObject]()
                if (font == nil)
                {
                    font = UIFont.systemFontOfSize(UIFont.systemFontSize())
                }
                attrs[NSFontAttributeName] = font
                attrs[NSForegroundColorAttributeName] = scaleColor
                //NSString(string: String(i)).drawAtPoint(textPoint, withAttributes: attrs)
                NSString(string: String(i)).drawInRect(textRect, withAttributes: attrs)
                //--end
            }
            CGContextRestoreGState(context)
        }
        
        //draw the datapoint
        dataFillColor.setFill()
        for data in self._data {
            let (hour, minute, volume) = data
            let angle = angleInClock(hour, minute)
            if angle > phaseAngle {
                continue
            }
            let distance = distanceToCentre(volume)
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, orginX, orginY)
            CGContextRotateCTM(context, angle)
            //CGContextMoveToPoint(context, 0, distance)
            let pointRect = CGRectMake(0, distance, dataPointRedius, dataPointRedius)
            CGContextAddEllipseInRect(context, pointRect)
            CGContextFillPath(context)
            CGContextMoveToPoint(context, 0, 0)
            CGContextRestoreGState(context)
            
        }
        fillColor.setFill()
        
        if _animator.phaseY > 0.0 && _animator.phaseY < 1.0
        {
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, orginX, orginY)
            CGContextRotateCTM(context, phaseAngle)
            CGContextMoveToPoint(context, 0, 0)
            CGContextAddLineToPoint(context, 0, _radius)
            CGContextSetLineWidth(context, 0.5)
            //UIColor.redColor().setStroke()
            //CGContextSetStrokeColor(context, UIColor.redColor().CGColor)
            CGContextStrokePath(context)
            CGContextRestoreGState(context)
        }
    }
    /*
    override func drawRect(rect: CGRect) {
    //super.drawRect(rect)
    let aPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, 200, 100))
    UIColor.blackColor().setStroke()
    UIColor.yellowColor().setFill()
    
    let aRef = UIGraphicsGetCurrentContext()
    CGContextTranslateCTM(aRef, 50, 50)
    
    aPath.lineWidth = 5
    
    aPath.fill()
    aPath.stroke()
    
    }
    */
    private func angleInClock(hour: Int, _ minute: Int) -> CGFloat {
        let hourAngle = CGFloat(M_PI / 12.0)
        let minuteAngle = hourAngle / 60.0
        return CGFloat(hour) * hourAngle + CGFloat(minute) * minuteAngle
    }
    private func distanceToCentre(volume: Int) -> CGFloat {
        let v = min(volume, _maxVolume)
        let phaseLength = _dataAreaRadius / CGFloat(_phases)
        switch v {
        case 0 ... 500:
            return CGFloat(v) / CGFloat(100) * phaseLength + phaseLength
        default:
            return CGFloat(v - 500) / CGFloat(500) * phaseLength + 6 * phaseLength
        }
    }
    func setData(data: [(Int, Int, Int)]) {
        _data = data
    }
    func viewAnimatorUpdated(viewAnimator: OIViewAnimator) {
        self.setNeedsDisplay()
    }
    func viewAnimatorStopped(viewAnimator: OIViewAnimator) {
        //
    }
    func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
    {
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    func animateReversal(duration: NSTimeInterval) {
        _animator.isReversal = true
        _animator.animate(yAxisDuration: duration)
    }
    
}
