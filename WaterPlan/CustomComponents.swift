//
//  CustomComponents.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/28.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class DigitLabelStack: UIStackView {
    var digit = -1 {
        didSet {
            if digit != oldValue  {
                //print("digit:\(digit) oldValue:\(oldValue)")
                self.frame = self.frame.offsetBy(dx: 0, dy: CGFloat(digit - oldValue) * (self.frame.height / 10))
                //print("stack_frame: x-\(self.frame.origin.x) y-\(self.frame.origin.y) w-\(self.frame.width) h-\(self.frame.height)")
            }
        }
    }
    var digitLabels = [UILabel]()
    
    init(frame: CGRect, digit: Int, let label: UILabel) {
        //给StackView的frame赋值，height应该是10个数字label的高度之和。因为想要得到的StackView是竖直排列从上到下的label是9876543210这个顺序，所以数字9的label则是在point(x:0.0,y:0.0)的位置处，为了让初始时刻StackView可视区域显示数值为digit的label，就需要使frame的y坐标上移（9-digit）＊ label.height
        super.init(frame: CGRectMake(frame.origin.x, frame.origin.y - (CGFloat(10) * frame.height), frame.width, 10 * frame.height))
        //self.backgroundColor = UIColor.blackColor()
        self.axis = .Vertical
        self.alignment = .Center
        self.distribution = .FillEqually
        var index: Int
        for index = 9; index >= 0; index-- {
            let newLabel = UILabel()
            newLabel.textColor = label.textColor
            newLabel.font = label.font
            newLabel.text = String(index)
            self.addArrangedSubview(newLabel)
            digitLabels.append(newLabel)
        }
        //self.frame = self.frame.offsetBy(dx: 0, dy: CGFloat(digit) * frame.height)
        self.digit = digit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class DigitLabel: UILabel {
    var digit = 0 {
        didSet {
            self.digitStack!.digit = digit
        }
    }
    var digitStack: DigitLabelStack?
    
    init(let label: UILabel) {
        super.init(frame: label.bounds)
        self.textColor = label.textColor.colorWithAlphaComponent(1.0)
        self.font = label.font
        self.text = "0"
        self.layer.masksToBounds = true
        self.digitStack = DigitLabelStack(frame: self.bounds, digit: -1, label: self)
        self.addSubview(self.digitStack!)
        self.textColor = self.textColor.colorWithAlphaComponent(0.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class DigitalWheelLabel: UIStackView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var number = 0 {
        didSet {
            if number != oldValue {
                var targetNum = number
                var figures = 0
                var tmpDigits = [Int]()
                repeat {
                    tmpDigits.append(targetNum % 10)
                    figures++
                    targetNum /= 10
                } while targetNum > 0
                
                if figures == self.figures { //显示位数没有变化
                    for index in 0 ..< tmpDigits.count {
                        UIView.animateWithDuration(self.animationDuration,
                            delay: 0.2 * Double(index),
                            options: .CurveEaseIn,
                            animations: { [unowned self] () -> Void in
                                self.digitLabels[index].digit = tmpDigits[index]
                            },
                            completion: nil)
                    }
                } else if figures > self.figures { //显示位数变大啦
                    for index in 0 ..< tmpDigits.count {
                        if index + 1 > digitLabels.count {
                            let digitLabel = DigitLabel(label: self.arrangedSubviews[0] as! UILabel)
                            //self.addArrangedSubview(digitLabel)
                            self.insertArrangedSubview(digitLabel, atIndex: 0)
                            digitLabels.append(digitLabel)
                        } else if index >= self.figures {
                            self.digitLabels[index].hidden = false
                        }
                    }
                        /*
                        UIView.animateWithDuration(self.animationDuration,
                            delay: 0.2 * Double(index),
                            options: .CurveEaseIn,
                            animations: { [unowned self] () -> Void in
                                self.digitLabels[index].digit = tmpDigits[index]
                                //self.layoutIfNeeded()
                            },
                            completion: nil)
                        */
                        UIView.animateWithDuration(0.6,
                            animations: {
                                [unowned self]
                                () -> Void in
                                    self.layoutIfNeeded()
                                },
                            completion: {
                                [unowned self]
                                (finish: Bool) -> Void in
                                for index in 0 ..< tmpDigits.count {
                                    UIView.animateWithDuration(self.animationDuration,
                                    delay: 0.2 * Double(index),
                                    options: .CurveEaseIn,
                                    animations: { [unowned self] () -> Void in
                                        self.digitLabels[index].digit = tmpDigits[index]
                                    },
                                    completion: nil)
                                }
                            }
                        )
                } else { //显示位数变小啦，也就是变小啦
                    var index: Int
                    self.tmpIndex = self.figures - 1
                    for index = self.figures-1; index >= 0; index-- {
                        UIView.animateWithDuration(self.animationDuration,
                            delay: 0.2 * Double(self.figures - 1 - index),
                            options: .CurveEaseIn,
                            animations: { [unowned self] () -> Void in
                                self.digitLabels[index].digit = index > figures-1 ? -1 :tmpDigits[index]
                                if index > figures-1 {
                                }
                            },
                            completion: {
                                [unowned self]
                                (finish: Bool) -> Void in
                                UIView.animateWithDuration(self.animationDuration, animations: { () -> Void in
                                    if self.tmpIndex > figures-1 {
                                        self.digitLabels[self.tmpIndex--].hidden = true
                                        self.layoutIfNeeded()
                                    }
                                })
                        })
                    }
                }
                self.figures = figures
            }
        }
    }
    var figures = 1
    var tmpIndex = 0
    var digits = [Int](count: 10, repeatedValue: 0)
    var digitLabelStacks = [DigitLabelStack]()
    var digitLabels = [DigitLabel]()
    var animationDuration = 0.8
    
    init(let label: UILabel, number: Int) {
        super.init(frame: label.bounds)
        self.number = number
        let digitLabel = DigitLabel(label: label)
        digitLabel.digit = number
        //self.insertSubview(digitLabel, atIndex: 0)
        self.insertArrangedSubview(digitLabel, atIndex: 0)
        digitLabels.append(digitLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class CupView: UIView {
    var leftMaskView = UIView()
    var rightMaskView = UIView()
    var waterView = UIView()
    var inited = false
    
    func initCupView() {
        if inited {
            return
        }
        
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let bounds = self.bounds
        self.layer.masksToBounds = true
        
        //waterView = UIView()
        waterView.frame = CGRectMake(0, bounds.height, bounds.width, 0)
        waterView.backgroundColor = UIColor.blueColor()
        
        //leftMaskView = UIView()
        leftMaskView.layer.anchorPoint = CGPoint(x: 1, y: 0)
        leftMaskView.frame = CGRectMake(-bounds.width, 0, bounds.width, bounds.height * 2)
        leftMaskView.backgroundColor = self.superview?.backgroundColor
        //leftMaskView.backgroundColor = UIColor.blueColor()
        leftMaskView.transform = CGAffineTransformRotate(leftMaskView.transform, CGFloat(-M_PI / 18))
        
        //rightMaskView = UIView()
        rightMaskView.layer.anchorPoint = CGPoint(x: 0, y: 0)
        rightMaskView.frame = CGRectMake(bounds.width, 0, bounds.width, bounds.height * 2)
        rightMaskView.backgroundColor = self.superview?.backgroundColor
        rightMaskView.backgroundColor = UIColor.blueColor()
        rightMaskView.transform = CGAffineTransformRotate(rightMaskView.transform, CGFloat(M_PI / 18))
        
        self.addSubview(leftMaskView)
        self.addSubview(rightMaskView)
        self.addSubview(waterView)
        
        inited = true
    }
}
class VolumeBtn: UIButton {
    var volume = 0
    init(frame: CGRect, volume: Int) {
        super.init(frame: frame)
        self.volume = volume
        self.layer.cornerRadius = frame.width / 2.0
        self.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class WeekButton: UIButton {
    var day = 0
    var checked = false
}