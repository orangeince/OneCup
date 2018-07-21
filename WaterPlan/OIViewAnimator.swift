//
//  OIViewAnimator.swift
//  AnimationTest
//
//  Created by 赵少龙 on 15/12/8.
//  Copyright © 2015年 OITown. All rights reserved.
//

//import Foundation
import UIKit

//@objc
public protocol OIViewAnimatorDelegate: AnyObject
{
    /// Called when the Animator has stepped.
    func viewAnimatorUpdated(_ viewAnimator: OIViewAnimator)
    
    /// Called when the Animator has stopped.
    func viewAnimatorStopped(_ viewAnimator: OIViewAnimator)
}

open class OIViewAnimator: NSObject {
    
    open weak var delegate: OIViewAnimatorDelegate?
    open var updateBlock: (() -> Void)?
    open var stopBlock: (() -> Void)?
    
    /// the phase that is animated and influences the drawn values on the y-axis
    open var phaseX: CGFloat = 1.0
    
    /// the phase that is animated and influences the drawn values on the y-axis
    open var phaseY: CGFloat = 1.0
    
    open var isReversal: Bool = false
    
    fileprivate var _startTimeX: TimeInterval = 0.0
    fileprivate var _startTimeY: TimeInterval = 0.0
    fileprivate var _displayLink: CADisplayLink!
    
    fileprivate var _durationX: TimeInterval = 0.0
    fileprivate var _durationY: TimeInterval = 0.0
    
    fileprivate var _endTimeX: TimeInterval = 0.0
    fileprivate var _endTimeY: TimeInterval = 0.0
    fileprivate var _endTime: TimeInterval = 0.0
    
    fileprivate var _enabledX: Bool = false
    fileprivate var _enabledY: Bool = false
    
    open var enabled:Bool {
        return _enabledX || _enabledY
    }
    
    
    //private var _easingX: ChartEasingFunctionBlock?
    //private var _easingY: ChartEasingFunctionBlock?
    
    public override init()
    {
        super.init()
    }
    
    deinit
    {
        stop()
    }
    
    open func stop()
    {
        if (_displayLink != nil)
        {
            _displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
            _displayLink = nil
            
            _enabledX = false
            _enabledY = false
            
            // If we stopped an animation in the middle, we do not want to leave it like this
            if phaseX != 1.0 || phaseY != 1.0
            {
                phaseX = 1.0
                phaseY = 1.0
                
                if (delegate != nil)
                {
                    delegate!.viewAnimatorUpdated(self)
                }
                if (updateBlock != nil)
                {
                    updateBlock!()
                }
            }
            
            if (delegate != nil)
            {
                delegate!.viewAnimatorStopped(self)
            }
            if (stopBlock != nil)
            {
                stopBlock?()
            }
        }
    }
    fileprivate func updateAnimationPhases(_ currentTime: TimeInterval)
    {
        if (_enabledX)
        {
            let elapsedTime: TimeInterval = currentTime - _startTimeX
            let duration: TimeInterval = _durationX
            var elapsed: TimeInterval = elapsedTime
            if (elapsed > duration)
            {
                elapsed = duration
            }
            phaseX = CGFloat(elapsed / duration)
        }
        if (_enabledY)
        {
            let elapsedTime: TimeInterval = currentTime - _startTimeY
            let duration: TimeInterval = _durationY
            var elapsed: TimeInterval = elapsedTime
            if (elapsed > duration)
            {
                elapsed = duration
            }
            phaseY = CGFloat(elapsed / duration)
        }
    }
    @objc fileprivate func animationLoop()
    {
        let currentTime: TimeInterval = CACurrentMediaTime()
        
        updateAnimationPhases(currentTime)
        
        if (delegate != nil)
        {
            delegate!.viewAnimatorUpdated(self)
        }
        if (updateBlock != nil)
        {
            updateBlock!()
        }
        
        if (currentTime >= _endTime)
        {
            stop()
        }
    }
    
    /// Animates the drawing / rendering of the chart on both x- and y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easingX: an easing function for the animation on the x axis
    /// - parameter easingY: an easing function for the animation on the y axis
    open func animate(xAxisDuration: TimeInterval, yAxisDuration: TimeInterval)
    {
        stop()
        
        _startTimeX = CACurrentMediaTime()
        _startTimeY = _startTimeX
        _durationX = xAxisDuration
        _durationY = yAxisDuration
        _endTimeX = _startTimeX + xAxisDuration
        _endTimeY = _startTimeY + yAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledX = xAxisDuration > 0.0
        _enabledY = yAxisDuration > 0.0
        
        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(_startTimeX)
        
        if (_enabledX || _enabledY)
        {
            _displayLink = CADisplayLink(target: self, selector: #selector(OIViewAnimator.animationLoop))
            _displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        }
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easing: an easing function for the animation
    open func animate(xAxisDuration: TimeInterval)
    {
        _startTimeX = CACurrentMediaTime()
        _durationX = xAxisDuration
        _endTimeX = _startTimeX + xAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledX = xAxisDuration > 0.0
        
        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(_startTimeX)
        
        if (_enabledX || _enabledY)
        {
            if _displayLink === nil
            {
                _displayLink = CADisplayLink(target: self, selector: #selector(OIViewAnimator.animationLoop))
                _displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            }
        }
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    open func animate(yAxisDuration: TimeInterval)
    {
        _startTimeY = CACurrentMediaTime()
        _durationY = yAxisDuration
        _endTimeY = _startTimeY + yAxisDuration
        _endTime = _endTimeX > _endTimeY ? _endTimeX : _endTimeY
        _enabledY = yAxisDuration > 0.0
        
        // Take care of the first frame if rendering is already scheduled...
        updateAnimationPhases(_startTimeY)
        
        if (_enabledX || _enabledY)
        {
            if _displayLink === nil
            {
                _displayLink = CADisplayLink(target: self, selector: #selector(OIViewAnimator.animationLoop))
                _displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            }
        }
    }
    
}


