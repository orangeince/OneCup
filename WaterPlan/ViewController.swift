//
//  ViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/10/18.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var opView: UIView!
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var textField: UITextField!
    var digitalWheelLabel: DigitalWheelLabel?
    
    var stack: DigitLabelStack!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        numberLabel.layer.masksToBounds = true
        let frame = numberLabel.frame
        self.stack = DigitLabelStack(frame: frame, digit: Int(numberLabel.text!)!, label: numberLabel)
        numberLabel.addSubview(stack)
        numberLabel.textColor = numberLabel.textColor.colorWithAlphaComponent(0.0)
        
        for view in bottomStack.arrangedSubviews {
            view.hidden = true
        }
        digitalWheelLabel = DigitalWheelLabel(label: numberLabel, number: 0)
        digitalWheelLabel!.number = 12345
        bottomStack.addArrangedSubview(digitalWheelLabel!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeBtnTap(sender: UIButton) {
        //numberView.frame = visulLabel.frame
        //numberView
        //let frame = numberLabel.frame
        /*
        let newView = UIView(frame: frame)
        newView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        self.view.addSubview(newView)
        let newLabel = UILabel(frame: newView.bounds)
        newLabel.text = "0"
        newLabel.textColor = UIColor.redColor()
        newLabel.font = numberLabel.font
        newView.addSubview(newLabel)
        //newView.backgroundColor =
        numberLabel.hidden = true
        newView.layer.borderColor = UIColor.blackColor().CGColor
        newView.layer.borderWidth = 2.0
        newView.layer.masksToBounds = true
        
        frame = CGRectOffset(newLabel.frame, 0, -newLabel.frame.height)
        let label2 = UILabel(frame: frame)
        label2.textColor = newLabel.textColor
        label2.font = newLabel.font
        label2.text = "1"
        newView.addSubview(label2)
        frame = CGRectOffset(label2.frame, 0, -label2.frame.height)
        let label3 = UILabel(frame: frame)
        label3.text = "2"
        label3.textColor = newLabel.textColor
        label3.font = newLabel.font
        newView.addSubview(label3)
        let height = 2 * frame.height
        UIView.animateWithDuration(0.5) { () -> Void in
            newLabel.frame = newLabel.frame.offsetBy(dx: 0, dy: height)
            label2.frame = label2.frame.offsetBy(dx: 0, dy: height)
            label3.frame = label3.frame.offsetBy(dx: 0, dy: height)
            //self.doAnimation()
        }
        */
        /*
        let frame = numberLabel.frame
        //let digitWheelView = DigitalWheelView(frame: frame, figure: 2, label: numberLabel)
        let digitWheelView = MultiDigitalWheelView(frame: frame, figure: Int(numberLabel.text!)!, label: numberLabel)
        numberLabel.addSubview(digitWheelView)
        UIView.animateWithDuration(1.0) { () -> Void in
            digitWheelView.wheelToFigure(195)
        }
        numberLabel.textColor = numberLabel.textColor.colorWithAlphaComponent(0.0)
        */
        
        /*
        numberLabel.layer.borderWidth = 2.0
        numberLabel.layer.borderColor = UIColor.blackColor().CGColor
        
        var frame = numberLabel.frame
        //numberLabel.layer.masksToBounds = true
        let stack = UIStackView()
        stack.frame = CGRectMake(0.0, 0.0, frame.width, 3 * frame.height)
        //stack.layer.masksToBounds = true
        stack.alignment = .Center
        stack.distribution = .FillEqually
        stack.axis = .Vertical
        let newLable1 = UILabel()
        newLable1.textColor = numberLabel.textColor
        newLable1.font = numberLabel.font
        newLable1.text = "1"
        stack.addArrangedSubview(newLable1)
        frame = frame.offsetBy(dx: 0, dy: frame.height)
        let newLable2 = UILabel()
        newLable2.textColor = numberLabel.textColor
        newLable2.font = numberLabel.font
        newLable2.text = "2"
        stack.addArrangedSubview(newLable2)
        let newLable3 = UILabel()
        newLable3.textColor = numberLabel.textColor
        newLable3.font = numberLabel.font
        newLable3.text = "3"
        stack.addArrangedSubview(newLable3)
        numberLabel.addSubview(stack)
        UIView.animateWithDuration(1.0) { () -> Void in
            stack.frame = stack.frame.offsetBy(dx: 0, dy: -2 * frame.height)
        }
        //numberLabel.hidden = true
        //digitWheelView.bounds = frame
        //UIView.animateWithDuration(1.0) { () -> Void in
         //   digitWheelView.wheelToFigure(9)
        //}
        
        //numberLabel.text = "8"
        //self.view.layoutIfNeeded()
*/
        
        UIView.animateWithDuration(1.0) { () -> Void in
            self.stack.digit = random()%10
        }
        /*
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            digitWheelView.wheelToFigure(9)
            }) { (finish: Bool) -> Void in
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    digitWheelView.wheelToFigure(0)
                    }) { (finish: Bool) -> Void in
                        digitWheelView.hidden = true
                        self.numberLabel.hidden = false
                }
        }
        */
    }
    func doAnimation() {
        self.view.backgroundColor = UIColor.redColor()
    }
    @IBAction func doBtnTap(sender: UIButton) {
        //for view in bottomStack.arrangedSubviews {
         //   view.hidden = true
       // }
        
        /*
        let frame = numberLabel.bounds
        for n in 0 ..< 5 {
            let newLabel = UILabel()
            newLabel.font = numberLabel.font
            newLabel.text = "0"
            bottomStack.addArrangedSubview(newLabel)
            //bottomStack.layoutIfNeeded()
            let stack = DigitLabelStack(frame: frame, digit: Int(newLabel.text!)!, label: newLabel)
            newLabel.layer.masksToBounds = true
            newLabel.textColor = numberLabel.textColor.colorWithAlphaComponent(0.0)
            newLabel.addSubview(stack)
            UIView.animateWithDuration(0.8,
                delay: 0.1 * Double(n),
                options: .CurveEaseIn,
                animations: {
                    () -> Void in
                        stack.digit = random() % 10
                },
                completion: nil
            )
        }
        var frame = numberLabel.bounds
        print("frame( x:\(frame.origin.x) y:\(frame.origin.y) w:\(frame.width) h:\(frame.height))")
        frame = digitalLabel.bounds
        print("frame( x:\(frame.origin.x) y:\(frame.origin.y) w:\(frame.width) h:\(frame.height))")
        print("frame: x-\(digitalLabel.frame.origin.x) y-\(digitalLabel.frame.origin.y) w-\(digitalLabel.frame.width) h-\(digitalLabel.frame.height)")
        print("bounds: x-\(digitalLabel.bounds.origin.x) y-\(digitalLabel.bounds.origin.y) w-\(digitalLabel.bounds.width) h-\(digitalLabel.bounds.height)")
*/
        /*
        let digitalLabel = DigitLabel(label: numberLabel)
        bottomStack.addArrangedSubview(digitalLabel)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.bottomStack.layoutIfNeeded()
            digitalLabel.digit = 8
        }
*/
        //digitalWheelLabel!.number = 12347
        if let text = textField.text {
            var x = Int(text)!
            if x > 10 || x < 1 {
                x = 1
            }
            var y = 1
            while x-- > 0 {
                y *= 10
            }
            y = random() % y
            digitalWheelLabel!.number = y
            print("y=\(y)")
        }
        for label in digitalWheelLabel!.subviews as! [DigitLabel] {
            print("\(label.digit)")
        }
        /*
        let digitalLabel = DigitalWheelLabel(label: numberLabel, number: 0)
        print("frame: x-\(digitalLabel.frame.origin.x) y-\(digitalLabel.frame.origin.y) w-\(digitalLabel.frame.width) h-\(digitalLabel.frame.height)")
        bottomStack.addArrangedSubview(digitalLabel)
        */
    }

}

