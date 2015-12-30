//
//  OIBarChartView.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/8.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class OIBarChartView: UIView, OIViewAnimatorDelegate {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    private var _data = [(Int, Int)]()
    private var _lazyData = [(Int, Int)]()
    
    private var _animator: OIViewAnimator!
    private var _barLabels = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    private var _margin = CGFloat(10)
    private var _descriptionHeight = CGFloat(16)
    private var _descriptionMargin = CGFloat(5)
    private var _phases:Int = 7
    private var _drawSeparator = true
    private var _maxVolume = 8000
    private var _limitVolume = 2000
    private var _barLabelHeight = CGFloat(15)
    private var _barLabelMargin = CGFloat(5)
    
    private var _dataReducedPercent = CGFloat(0.0)
    
    var fillColor: UIColor?
    var strokeColor = UIColor.blackColor()
    
    var barColor = UIColor.blueColor()
    var barLabelColor = UIColor.blackColor()
    var barLabelFont = UIFont.systemFontOfSize(10.0)
    var barDescription = "每日喝水量"
    var barDataValueFont = UIFont.systemFontOfSize(8.0)
    var drawLimitLine = true
    var limitVolume: Int {
        get {
            return _limitVolume
        }
        set {
            _limitVolume = newValue
        }
    }
    
    
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
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
    }
    
    func dataReduceWithRatio(ratio: CGFloat) {
        _dataReducedPercent = ratio
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        let barCount = _barLabels.count
        if barCount == 0 {
            return
        }
        let context = UIGraphicsGetCurrentContext()
        
        if fillColor == nil {
            fillColor = self.tintColor
        }
        fillColor!.setFill()
        strokeColor.setStroke()
        
        let labelTextHeight = barLabelFont.lineHeight
        
        let barAreaHeight: CGFloat = CGRectGetHeight(rect) -  _descriptionHeight - _margin - _margin
        let barAreaWidth = CGRectGetWidth(rect) - _margin - _margin
        
        let barWidth = barAreaWidth / CGFloat(barCount)
        let barHegiht = barAreaHeight - _barLabelHeight - _barLabelMargin - _barLabelMargin - labelTextHeight
        
        let barLineX = _margin
        let barLineY = _margin + barHegiht + labelTextHeight
        
        //draw barBottomLine
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, barLineX, barLineY)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, barAreaWidth, 0)
        CGContextSetLineWidth(context, 0.1)
        CGContextStrokePath(context)
        CGContextMoveToPoint(context, 0, 0)
        
        for idx in 0 ..< barCount {
            var attrs = [String: AnyObject]()
            attrs[NSFontAttributeName] = barLabelFont
            attrs[NSForegroundColorAttributeName] = barLabelColor
            let text = _barLabels[idx]
            let textWidth = text.sizeWithAttributes(attrs).width
            //let textRect = CGRectMake(CGFloat(idx) * barWidth + _margin, _barLabelMargin, barWidth, barWidth)
            let textPoint = CGPoint(x: (CGFloat(idx) + CGFloat(0.5)) * barWidth - textWidth / 2.0, y: _barLabelMargin)
            //NSString(string: text).drawInRect(textRect, withAttributes: attrs)
            NSString(string: text).drawAtPoint(textPoint, withAttributes: attrs)
        }
        CGContextRestoreGState(context)
        
        var avg = 0
        if _data.count > 0 {
            var sum = 0
            var count = 0
            for data in _data {
                sum += data.0
                if data.0 > 0 {
                    count++
                }
            }
            if count > 0 {
                avg = Int(sum / count)
            }
        }
        let avgText = "日平均: "
        CGContextSaveGState(context)
        //draw description
        CGContextTranslateCTM(context, 0, barAreaHeight + _margin)
        CGContextMoveToPoint(context, 0, 0)
        if _drawSeparator {
            CGContextAddLineToPoint(context, rect.width, 0)
            CGContextSetLineWidth(context, 0.5)
            CGContextStrokePath(context)
            CGContextMoveToPoint(context, 0, 0)
        }
        let legendHeight = _descriptionHeight - _descriptionMargin
        let legendRect = CGRectMake(_margin, _descriptionMargin + 1.0 , legendHeight, legendHeight)
        CGContextFillRect(context, legendRect)
        let descriptionPoint = CGPoint(x: _margin + legendHeight + _descriptionMargin, y: _descriptionMargin)
        var attrs = [String: AnyObject]()
        attrs[NSFontAttributeName] = barLabelFont
        attrs[NSForegroundColorAttributeName] = barLabelColor
        let avgWidth = avgText.sizeWithAttributes(attrs).width
        let maxVolumeText = "10000 ml"
        let maxVolumeTextWidth = maxVolumeText.sizeWithAttributes(attrs).width
        let avgPoint = CGPoint(x: barAreaWidth - avgWidth - maxVolumeTextWidth + _margin , y: _descriptionMargin)
        NSString(string: barDescription).drawAtPoint(descriptionPoint, withAttributes: attrs)
        NSString(string: avgText + String(avg) + " ml").drawAtPoint(avgPoint, withAttributes: attrs)
        CGContextRestoreGState(context)
        
        //draw bar data
        if _data.count == 0 {
            return
        }
        //按比例画view，分两段，第一段为压缩后的bar长度，第二段为剩下需要animator画的部分。比如滑动view的时候bar被缩小了30%，当滑动结束后剩下的70%可能需要animator来画。
        let drawRatio: CGFloat
        if !_animator.isReversal {
            if _animator.phaseY < 1.0 {
                if _dataReducedPercent > 0.0 {
                    drawRatio = (1.0 - _dataReducedPercent) + _dataReducedPercent  * _animator.phaseY
                } else {
                    drawRatio = _animator.phaseY
                }
            } else {
                drawRatio = 1.0 - _dataReducedPercent
            }
        } else {
            if _animator.phaseY == 1.0 {
                drawRatio = 0.0
            } else{
                if _dataReducedPercent > 0.0 {
                    drawRatio = (1.0 - _dataReducedPercent) * (1.0 - _animator.phaseY)
                } else {
                    drawRatio = (1.0 - _animator.phaseY)
                }
            }
        }
        
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, barLineX, barLineY)
        //draw the limitLine
        if drawLimitLine {
            let height = getHeihtForBar(_limitVolume, barHeight: barHegiht)
            CGContextMoveToPoint(context, 0, -height)
            let dashLineLenghts = [CGFloat(6),CGFloat(12)]
            CGContextSetLineDash(context, 0.0, dashLineLenghts, 1)
            CGContextSetLineWidth(context, 0.3)
            UIColor.lightGrayColor().setStroke()
            CGContextAddLineToPoint(context, barAreaWidth, -height)
            CGContextStrokePath(context)
        }
        
        //draw dataBar
        for index in 0 ..< _data.count {
            let (volume, _) = _data[index]
            let height = getHeihtForBar(volume, barHeight: barHegiht) * drawRatio
            let width = barWidth - _margin - _margin
            let barRect = CGRectMake(CGFloat(index) * barWidth + _margin, -height, width, height)
            fillColor!.setFill()
            CGContextFillRect(context, barRect)
            
            attrs[NSFontAttributeName] = barDataValueFont
            attrs[NSForegroundColorAttributeName] = barLabelColor
            let v = String(volume)
            let fontHeight = barDataValueFont.lineHeight
            let fontWidth = v.sizeWithAttributes(attrs).width
            //let dataValueRect = CGRectMake(CGFloat(index) * barWidth + _margin, , width, fontHeight)
            let textPoint = CGPoint(x: (CGFloat(index) + CGFloat(0.5)) * barWidth - fontWidth / 2.0, y: -height - fontHeight - fontHeight / 3.0)
            //NSString(string: v).drawInRect(dataValueRect, withAttributes: attrs)
            NSString(string: v).drawAtPoint(textPoint, withAttributes: attrs)
        }
        
        CGContextRestoreGState(context)
    }
    
    func setData(data: [(Int, Int)]) {
        _data = data
        self.setNeedsDisplay()
    }
    func setDateWithAnimation(data: [(Int, Int)], animationDurtion: NSTimeInterval) {
        _data = data
        animate(animationDurtion)
    }
    func setBarLabels(barLabels: [String]) {
        _barLabels = barLabels
    }
    func getHeihtForBar(volume: Int, barHeight: CGFloat) -> CGFloat {
        let phaseHeight = barHeight / CGFloat(_phases)
        if volume > _limitVolume {
            let v = min(volume, _maxVolume)
            return CGFloat(v - _limitVolume) / CGFloat(_maxVolume - _limitVolume) * phaseHeight * 2 + 5 * phaseHeight
        } else {
            return CGFloat(volume) / CGFloat(2000) * phaseHeight * 5
        }
    }
    
    func viewAnimatorUpdated(viewAnimator: OIViewAnimator) {
        self.setNeedsDisplay()
    }
    func viewAnimatorStopped(viewAnimator: OIViewAnimator) {
        //
        self._dataReducedPercent = 0.0
    }
    func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
    {
        _animator.isReversal = false
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    func animateReversal(duration: NSTimeInterval) {
        _animator.isReversal = true
        _animator.animate(yAxisDuration: duration)
    }
    func animate(duration: NSTimeInterval) {
        _animator.isReversal = false
        _animator.animate(yAxisDuration: duration)
    }
    func animate(duration: NSTimeInterval, delay: NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: "timerFireAnimate:", userInfo: duration, repeats: false)
    }
    func animateReversal(duration: NSTimeInterval, delay: NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: "timerFireAnimateReversal:", userInfo: duration, repeats: false)
    }
    func setDataWithAnimation(data: [(Int, Int)], animationDurtion: NSTimeInterval, delay: NSTimeInterval) {
        _lazyData = data
        NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: "timerFireSetDataWithAnimation:", userInfo: delay, repeats: false)
    }
    func timerFireAnimate(timer: NSTimer) {
        let duration = timer.userInfo! as! NSTimeInterval
        animate(duration)
    }
    func timerFireAnimateReversal(timer: NSTimer) {
        let duration = timer.userInfo! as! NSTimeInterval
        animateReversal(duration)
    }
    func timerFireSetDataWithAnimation(timer: NSTimer) {
        let data = _lazyData
        let duration = timer.userInfo! as! NSTimeInterval
        self.setDateWithAnimation(data, animationDurtion: duration)
    }
}
