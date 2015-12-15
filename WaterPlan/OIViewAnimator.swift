//
//  OIViewAnimator.swift
//  AnimationTest
//
//  Created by 赵少龙 on 15/12/8.
//  Copyright © 2015年 OITown. All rights reserved.
//

//import Foundation
import UIKit

@objc
public protocol OIViewAnimatorDelegate
{
    /// Called when the Animator has stepped.
    func viewAnimatorUpdated(viewAnimator: OIViewAnimator)
    
    /// Called when the Animator has stopped.
    func viewAnimatorStopped(viewAnimator: OIViewAnimator)
}

public class OIViewAnimator: NSObject {
    
    public weak var delegate: OIViewAnimatorDelegate?
    public var updateBlock: (() -> Void)?
    public var stopBlock: (() -> Void)?
    
    /// the phase that is animated and influences the drawn values on the y-axis
    public var phaseX: CGFloat = 1.0
    
    /// the phase that is animated and influences the drawn values on the y-axis
    public var phaseY: CGFloat = 1.0
    
    public var isReversal: Bool = false
    
    private var _startTimeX: NSTimeInterval = 0.0
    private var _startTimeY: NSTimeInterval = 0.0
    private var _displayLink: CADisplayLink!
    
    private var _durationX: NSTimeInterval = 0.0
    private var _durationY: NSTimeInterval = 0.0
    
    private var _endTimeX: NSTimeInterval = 0.0
    private var _endTimeY: NSTimeInterval = 0.0
    private var _endTime: NSTimeInterval = 0.0
    
    private var _enabledX: Bool = false
    private var _enabledY: Bool = false
    
    public var enabled:Bool {
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
    
    public func stop()
    {
        if (_displayLink != nil)
        {
            _displayLink.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
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
    private func updateAnimationPhases(currentTime: NSTimeInterval)
    {
        if (_enabledX)
        {
            let elapsedTime: NSTimeInterval = currentTime - _startTimeX
            let duration: NSTimeInterval = _durationX
            var elapsed: NSTimeInterval = elapsedTime
            if (elapsed > duration)
            {
                elapsed = duration
            }
            phaseX = CGFloat(elapsed / duration)
        }
        if (_enabledY)
        {
            let elapsedTime: NSTimeInterval = currentTime - _startTimeY
            let duration: NSTimeInterval = _durationY
            var elapsed: NSTimeInterval = elapsedTime
            if (elapsed > duration)
            {
                elapsed = duration
            }
            phaseY = CGFloat(elapsed / duration)
        }
    }
    @objc private func animationLoop()
    {
        let currentTime: NSTimeInterval = CACurrentMediaTime()
        
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
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval, yAxisDuration: NSTimeInterval)
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
            _displayLink = CADisplayLink(target: self, selector: Selector("animationLoop"))
            _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        }
    }
    
    /// Animates the drawing / rendering of the chart the x-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter xAxisDuration: duration for animating the x axis
    /// - parameter easing: an easing function for the animation
    public func animate(xAxisDuration xAxisDuration: NSTimeInterval)
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
                _displayLink = CADisplayLink(target: self, selector: Selector("animationLoop"))
                _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            }
        }
    }
    
    /// Animates the drawing / rendering of the chart the y-axis with the specified animation time.
    /// If `animate(...)` is called, no further calling of `invalidate()` is necessary to refresh the chart.
    /// - parameter yAxisDuration: duration for animating the y axis
    /// - parameter easing: an easing function for the animation
    public func animate(yAxisDuration yAxisDuration: NSTimeInterval)
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
                _displayLink = CADisplayLink(target: self, selector: Selector("animationLoop"))
                _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            }
        }
    }
    
}


