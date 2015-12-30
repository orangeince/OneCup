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
    private var _descriptionAreaHeight = CGFloat(80.0)
    private var _descriptionMargin = CGFloat(16.0)
    private var _centreRadius = CGFloat(0)
    
    var fillClock = true
    var fillColor = UIColor.whiteColor()
    var dataFillColor: UIColor!
    var strokeColor = UIColor.blackColor()
    var scaleColor = UIColor.blackColor()
    var dataPointRedius = CGFloat(3.0)
    var drawDataPoint = false
    
    enum Location {
        case Center
        case LeftBottom
        case RightBottom
    }
    var descriptionLocation: Location = .Center
    
    var descriptionFont = UIFont.systemFontOfSize(12.0)
    var descriptionTexts = [("喝水次数 ", " 0"), ("每次平均 ", " 0ml"), ("最早时间 "," 无记录"), ("最常时段 "," 无记录")]
    var drinkedCount = 0 {
        didSet {
           descriptionTexts[0].1 = String(drinkedCount)
        }
    }
    var totalVolume = 0
    var minDrinkTime = 2400
    var perInervalCount = [
        ("00:00 - 03:59", 0),
        ("04:00 - 07:59", 0),
        ("08:00 - 11:59", 0),
        ("12:00 - 15:59", 0),
        ("16:00 - 19:59", 0),
        ("20:00 - 23:59", 0)
    ]
    var drawDescription = true
    let frequentlyTimeInterval = 4
    
    
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
        let clockAreaHeight = drawDescription ? rect.height - _descriptionMargin - _descriptionAreaHeight : rect.height
        let radius = min(clockAreaHeight, CGRectGetWidth(rect)) / 2.0
        let orginX = CGRectGetWidth(rect) / 2.0
        let orginY = clockAreaHeight / 2.0
        
        if self.dataFillColor == nil {
            self.dataFillColor = self.tintColor
        }
        
        fillColor.setFill()
        strokeColor.setStroke()
        CGContextSetLineWidth(context, 2)
        
        let margin = 0.0
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
        _centreRadius = _radius / 5.0
        
        var font = UIFont(name: "HelveticaNeue", size: 12.0)
        
        let aniamteRatio = _animator.isReversal ? 1 - _animator.phaseY : _animator.phaseY
        
        let phaseAngle = aniamteRatio * CGFloat(M_PI * 2.0) + CGFloat(M_PI)
        
        //draw the clock
        for idx in 0 ..< 12 {
            let i = 2 * idx
            let angle = CGFloat(Double(i) * M_PI / 12.0 + M_PI)
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
            if drawDataPoint {
                CGContextMoveToPoint(context, 0, 0)
            } else {
                CGContextMoveToPoint(context, 0, _centreRadius)
            }
            CGContextAddLineToPoint(context, 0, _radius - 3 * length)
            CGContextSetLineWidth(context, 0.05)
            CGContextStrokePath(context)
            if (font == nil) {
                font = UIFont.systemFontOfSize(UIFont.systemFontSize())
            }
            let textHeight = font!.lineHeight
            _dataAreaRadius = _radius - length - textHeight - _centreRadius
            
            if i % 2 == 0 {
                let offX: CGFloat = i < 10 ? 4.0 : 2.0
                //CGContextTranslateCTM(context, 0, _radius + textHeight / 2.0)
                CGContextTranslateCTM(context, 0, _radius - length - textHeight / 2.0)
                //CGContextMoveToPoint(context, 0, length + textHeight)
                CGContextRotateCTM(context, -CGFloat(Double(i) * M_PI / 12.0 - M_PI))
                let textRect = CGRectMake(0 - textHeight / offX, -textHeight / 2.0, textHeight, textHeight)
                var attrs = [String: AnyObject]()
                attrs[NSFontAttributeName] = font
                attrs[NSForegroundColorAttributeName] = scaleColor
                //NSString(string: String(i)).drawAtPoint(textPoint, withAttributes: attrs)
                NSString(string: String(i)).drawInRect(textRect, withAttributes: attrs)
                //--end
            }
            CGContextRestoreGState(context)
        }
        
        //draw the datapoint or dataline
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
            CGContextTranslateCTM(context, 0, _centreRadius)
            if drawDataPoint {
                let pointRect = CGRectMake(0, distance, dataPointRedius, dataPointRedius)
                CGContextAddEllipseInRect(context, pointRect)
                CGContextFillPath(context)
            } else { //draw dataline
                dataFillColor.setStroke()
                CGContextMoveToPoint(context, 0, 0)
                CGContextSetLineWidth(context, 0.8)
                CGContextAddLineToPoint(context, 0, distance)
                CGContextStrokePath(context)
            }
            CGContextMoveToPoint(context, 0, 0)
            CGContextRestoreGState(context)
            
        }
        strokeColor.setStroke()
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
        
        if drawDescription {
            CGContextSaveGState(context)
            CGContextMoveToPoint(context, 0, 0)
            self.totalVolume = 0
            self.drinkedCount = 0
            for idx in 0 ..< self.perInervalCount.count {
                self.perInervalCount[idx].1 = 0
            }
            for data in _data {
                let (hour, minute, volume) = data
                let intervalIndex = hour / frequentlyTimeInterval
                if intervalIndex < self.perInervalCount.count {
                    self.perInervalCount[intervalIndex].1++
                    self.totalVolume += volume
                    self.drinkedCount++
                    let tmpTime = hour * 100 + minute
                    if tmpTime < minDrinkTime {
                        self.descriptionTexts[2].1 = (hour < 10 ? "0" + String(hour) : String(hour)) + ":" + (minute < 10 ? "0" + String(minute) : String(minute))
                        minDrinkTime = tmpTime
                    }
                }
            }
            if totalVolume > 0 && drinkedCount > 0 {
                self.descriptionTexts[1].1 = String(totalVolume / drinkedCount) + "ml"
                
                var maxCount = 0
                for intervalCount in perInervalCount {
                    if intervalCount.1 > maxCount {
                        maxCount = intervalCount.1
                        self.descriptionTexts[3].1 = intervalCount.0 + "(\(maxCount))"
                    }
                }
            }
            var attrs = [String: AnyObject]()
            attrs[NSFontAttributeName] = descriptionFont
            //attrs[NSForegroundColorAttributeName] = UIColor.blackColor()
            attrs[NSForegroundColorAttributeName] = UIColor.whiteColor()
            /*
            var descriptionText = "   "
            for texts in self.descriptionTexts {
                descriptionText += (texts.0 + texts.1 + "  ")
            }
            let descriptionTextWidth = descriptionText.sizeWithAttributes(attrs).width
            CGContextTranslateCTM(context, rect.width / 2.0 - descriptionTextWidth / 2.0 , rect.height - _descriptionAreaHeight)
            //let descriptionAreaRect = CGRectMake(0, 0, descriptionTextWidth, _descriptionAreaHeight)
            //let path = UIBezierPath(roundedRect: descriptionAreaRect, cornerRadius: 4.0)
            //CGContextAddPath(context, path.CGPath)
            //CGContextFillPath(context)
            let fontHeight = descriptionFont.lineHeight
            let textPoint = CGPoint(x: 0, y: (_descriptionAreaHeight - fontHeight) / 2.0)
            NSString(string: descriptionText).drawAtPoint(textPoint, withAttributes: attrs)
            */
            let maxWidthKeyText = "最常时段 "
            let maxKeyTextwidth = maxWidthKeyText.sizeWithAttributes(attrs).width
            let textHeight = descriptionFont.lineHeight
            let textMargin = (_descriptionAreaHeight - textHeight * 4.0) / 5.0
            if descriptionLocation == .Center {
                CGContextTranslateCTM(context, rect.width / 2.0 - maxKeyTextwidth, rect.height - _descriptionAreaHeight)
            } else if descriptionLocation == .LeftBottom {
                CGContextTranslateCTM(context, 0, rect.height - _descriptionAreaHeight)
            }
            for index in 0 ..< descriptionTexts.count {
                let key = descriptionTexts[index].0
                let value = " " + descriptionTexts[index].1
                let offsetY = CGFloat(index) * (textHeight + textMargin)
                let keyTextWidth = key.sizeWithAttributes(attrs).width
                let keyTextPoint = CGPoint(x: maxKeyTextwidth - keyTextWidth, y: offsetY)
                NSString(string: key).drawAtPoint(keyTextPoint, withAttributes: attrs)
                
                //let valueTextWidth = value.sizeWithAttributes(attrs).width
                let valueTextPoint = CGPoint(x: maxKeyTextwidth, y: offsetY)
                NSString(string: value).drawAtPoint(valueTextPoint, withAttributes: attrs)
            }
            
            /*
            let maxWidthText = "最常时段"
            let textwidth = maxWidthText.sizeWithAttributes(attrs).width
            let textHeight = descriptionFont.lineHeight + descriptionFont.lineHeight / 2.0
            let areaMargin = textHeight / 2.0
            let descriptionAreaHeight = 4 * textHeight
            let descriptionAreaWidth = textwidth * 2.0 + areaMargin
            
            if descriptionLocation == .LeftBottom {
                CGContextTranslateCTM(context, 0, rect.height - descriptionAreaHeight)
                
            } else if descriptionLocation == .RightBottom {
                CGContextTranslateCTM(context, rect.width - descriptionAreaWidth, rect.height - descriptionAreaHeight)
            } else {
                
            }
            
            //let descriptionAreaRect = CGRectMake(0, 0, descriptionAreaWidth, descriptionAreaHeight)
            //let path = UIBezierPath(roundedRect: descriptionAreaRect, cornerRadius: 8.0)
            //CGContextAddPath(context, path.CGPath)
            //CGContextFillPath(context)
            
            for index in 0 ..< descriptionTexts.count {
                let key = descriptionTexts[index].0
                let value = descriptionTexts[index].1
                let keyTextWidth = key.sizeWithAttributes(attrs).width
                let keyTextPoint = CGPoint(x: textwidth - keyTextWidth, y: CGFloat(index) * textHeight)
                NSString(string: key).drawAtPoint(keyTextPoint, withAttributes: attrs)
                if value.isEmpty {
                    continue
                }
                //let valueTextWidth = value.sizeWithAttributes(attrs).width
                let valueTextPoint = CGPoint(x: textwidth + areaMargin, y: CGFloat(index) * textHeight)
                NSString(string: value).drawAtPoint(valueTextPoint, withAttributes: attrs)
            }
            CGContextRestoreGState(context)
         */
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
        return CGFloat(hour) * hourAngle + CGFloat(minute) * minuteAngle + CGFloat(M_PI)
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
