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
    fileprivate var _data = [(Int, Int)]()
    fileprivate var _lazyData = [(Int, Int)]()
    
    fileprivate var _animator: OIViewAnimator!
    fileprivate var _barLabels = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    fileprivate var _margin = CGFloat(10)
    fileprivate var _descriptionHeight = CGFloat(16)
    fileprivate var _descriptionMargin = CGFloat(5)
    fileprivate var _phases:Int = 7
    fileprivate var _drawSeparator = true
    fileprivate var _maxVolume = 8000
    fileprivate var _limitVolume = 2000
    fileprivate var _barLabelHeight = CGFloat(15)
    fileprivate var _barLabelMargin = CGFloat(5)
    
    fileprivate var _dataReducedPercent = CGFloat(0.0)
    
    var fillColor: UIColor?
    var strokeColor = UIColor.black
    
    var barColor = UIColor.blue
    var barLabelColor = UIColor.black
    var barLabelFont = UIFont.systemFont(ofSize: 10.0)
    var barDescription = "每日喝水量"
    var barDataValueFont = UIFont.systemFont(ofSize: 8.0)
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
    
    func dataReduceWithRatio(_ ratio: CGFloat) {
        _dataReducedPercent = ratio
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
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
        
        let barAreaHeight: CGFloat = rect.height -  _descriptionHeight - _margin - _margin
        let barAreaWidth = rect.width - _margin - _margin
        
        let barWidth = barAreaWidth / CGFloat(barCount)
        let barHegiht = barAreaHeight - _barLabelHeight - _barLabelMargin - _barLabelMargin - labelTextHeight
        
        let barLineX = _margin
        let barLineY = _margin + barHegiht + labelTextHeight
        
        //draw barBottomLine
        context?.saveGState()
        context?.translateBy(x: barLineX, y: barLineY)
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: barAreaWidth, y: 0))
        context?.setLineWidth(0.1)
        context?.strokePath()
        context?.move(to: CGPoint(x: 0, y: 0))
        
        for idx in 0 ..< barCount {
            var attrs = [String: AnyObject]()
            attrs[convertFromNSAttributedStringKey(NSAttributedString.Key.font)] = barLabelFont
            attrs[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = barLabelColor
            let text = _barLabels[idx]
            let textWidth = text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs)).width
            //let textRect = CGRectMake(CGFloat(idx) * barWidth + _margin, _barLabelMargin, barWidth, barWidth)
            let textPoint = CGPoint(x: (CGFloat(idx) + CGFloat(0.5)) * barWidth - textWidth / 2.0, y: _barLabelMargin)
            //NSString(string: text).drawInRect(textRect, withAttributes: attrs)
            NSString(string: text).draw(at: textPoint, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        }
        context?.restoreGState()
        
        var avg = 0
        if _data.count > 0 {
            var sum = 0
            var count = 0
            for data in _data {
                sum += data.0
                if data.0 > 0 {
                    count += 1
                }
            }
            if count > 0 {
                avg = Int(sum / count)
            }
        }
        let avgText = "日平均: "
        context?.saveGState()
        //draw description
        context?.translateBy(x: 0, y: barAreaHeight + _margin)
        context?.move(to: CGPoint(x: 0, y: 0))
        if _drawSeparator {
            context?.addLine(to: CGPoint(x: rect.width, y: 0))
            context?.setLineWidth(0.5)
            context?.strokePath()
            context?.move(to: CGPoint(x: 0, y: 0))
        }
        let legendHeight = _descriptionHeight - _descriptionMargin
        let legendRect = CGRect(x: _margin, y: _descriptionMargin + 1.0 , width: legendHeight, height: legendHeight)
        context?.fill(legendRect)
        let descriptionPoint = CGPoint(x: _margin + legendHeight + _descriptionMargin, y: _descriptionMargin)
        var attrs = [String: AnyObject]()
        attrs[convertFromNSAttributedStringKey(NSAttributedString.Key.font)] = barLabelFont
        attrs[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = barLabelColor
        let avgWidth = avgText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs)).width
        let maxVolumeText = "10000 ml"
        let maxVolumeTextWidth = maxVolumeText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs)).width
        let avgPoint = CGPoint(x: barAreaWidth - avgWidth - maxVolumeTextWidth + _margin , y: _descriptionMargin)
        NSString(string: barDescription).draw(at: descriptionPoint, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        NSString(string: avgText + String(avg) + " ml").draw(at: avgPoint, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        context?.restoreGState()
        
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
        
        context?.saveGState()
        context?.translateBy(x: barLineX, y: barLineY)
        //draw the limitLine
        if drawLimitLine {
            let height = getHeihtForBar(_limitVolume, barHeight: barHegiht)
            context?.move(to: CGPoint(x: 0, y: -height))
            let dashLineLenghts = [CGFloat(6),CGFloat(12)]
            context?.setLineDash(phase: 0.0, lengths: dashLineLenghts)
            //CGContextSetLineDash(context, 0.0, dashLineLenghts, 1)
            context?.setLineWidth(0.3)
            UIColor.lightGray.setStroke()
            context?.addLine(to: CGPoint(x: barAreaWidth, y: -height))
            context?.strokePath()
        }
        
        //draw dataBar
        for index in 0 ..< _data.count {
            let (volume, _) = _data[index]
            let height = getHeihtForBar(volume, barHeight: barHegiht) * drawRatio
            let width = barWidth - _margin - _margin
            let barRect = CGRect(x: CGFloat(index) * barWidth + _margin, y: -height, width: width, height: height)
            fillColor!.setFill()
            context?.fill(barRect)
            
            attrs[convertFromNSAttributedStringKey(NSAttributedString.Key.font)] = barDataValueFont
            attrs[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = barLabelColor
            let v = String(volume)
            let fontHeight = barDataValueFont.lineHeight
            let fontWidth = v.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs)).width
            //let dataValueRect = CGRectMake(CGFloat(index) * barWidth + _margin, , width, fontHeight)
            let textPoint = CGPoint(x: (CGFloat(index) + CGFloat(0.5)) * barWidth - fontWidth / 2.0, y: -height - fontHeight - fontHeight / 3.0)
            //NSString(string: v).drawInRect(dataValueRect, withAttributes: attrs)
            NSString(string: v).draw(at: textPoint, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        }
        
        context?.restoreGState()
    }
    
    func setData(_ data: [(Int, Int)]) {
        _data = data
        self.setNeedsDisplay()
    }
    func setDateWithAnimation(_ data: [(Int, Int)], animationDurtion: TimeInterval) {
        _data = data
        animate(animationDurtion)
    }
    func setBarLabels(_ barLabels: [String]) {
        _barLabels = barLabels
    }
    func getHeihtForBar(_ volume: Int, barHeight: CGFloat) -> CGFloat {
        let phaseHeight = barHeight / CGFloat(_phases)
        if volume > _limitVolume {
            let v = min(volume, _maxVolume)
            return CGFloat(v - _limitVolume) / CGFloat(_maxVolume - _limitVolume) * phaseHeight * 2 + 5 * phaseHeight
        } else {
            return CGFloat(volume) / CGFloat(2000) * phaseHeight * 5
        }
    }
    
    func viewAnimatorUpdated(_ viewAnimator: OIViewAnimator) {
        self.setNeedsDisplay()
    }
    func viewAnimatorStopped(_ viewAnimator: OIViewAnimator) {
        //
        self._dataReducedPercent = 0.0
    }
    func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval)
    {
        _animator.isReversal = false
        _animator.animate(xAxisDuration: xAxisDuration, yAxisDuration: yAxisDuration)
    }
    func animateReversal(_ duration: TimeInterval) {
        _animator.isReversal = true
        _animator.animate(yAxisDuration: duration)
    }
    func animate(_ duration: TimeInterval) {
        _animator.isReversal = false
        _animator.animate(yAxisDuration: duration)
    }
    func animate(_ duration: TimeInterval, delay: TimeInterval) {
        Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(OIBarChartView.timerFireAnimate(_:)), userInfo: duration, repeats: false)
    }
    func animateReversal(_ duration: TimeInterval, delay: TimeInterval) {
        Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(OIBarChartView.timerFireAnimateReversal(_:)), userInfo: duration, repeats: false)
    }
    func setDataWithAnimation(_ data: [(Int, Int)], animationDurtion: TimeInterval, delay: TimeInterval) {
        _lazyData = data
        Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(OIBarChartView.timerFireSetDataWithAnimation(_:)), userInfo: delay, repeats: false)
    }
    @objc func timerFireAnimate(_ timer: Timer) {
        let duration = timer.userInfo! as! TimeInterval
        animate(duration)
    }
    @objc func timerFireAnimateReversal(_ timer: Timer) {
        let duration = timer.userInfo! as! TimeInterval
        animateReversal(duration)
    }
    @objc func timerFireSetDataWithAnimation(_ timer: Timer) {
        let data = _lazyData
        let duration = timer.userInfo! as! TimeInterval
        self.setDateWithAnimation(data, animationDurtion: duration)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
