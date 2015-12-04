//
//  ReminderNewViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/2.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class ReminderNewViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var mondayBtn: UIButton!
    @IBOutlet weak var TuesdayBtn: UIButton!
    @IBOutlet weak var weekBtnStack: UIStackView! //存放星期按钮的stackview，用于初始化button的状态和添加响应事件
    @IBOutlet weak var alertTitleField: UITextField!
    
    var weekBtns = [WeekButton]()
    var alertTime = ""
    var alertTitle = ""
    var repeatDate = ""
    var repeatDateMask = 0
    var theHour = 0
    var theMinute = 0
    var enable = true
    var reminder: ((String, String, String, Int, Int, Int, Bool), Int)?
    var SaveDataDelegate: ReminderTableViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        let curDate = NSDate()
        let calendarComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: curDate)
        self.theHour = calendarComponents.hour
        self.theMinute = calendarComponents.minute
        
        if let reminder = self.reminder {
             ((alertTime, alertTitle, repeatDate, repeatDateMask, theHour, theMinute, enable), _) = reminder
        }
       
        self.pickerView.selectRow(self.pickerView.numberOfRowsInComponent(0) / 2 + self.theHour, inComponent: 0, animated: false)
        self.pickerView.selectRow(self.pickerView.numberOfRowsInComponent(1) / 2 + self.theMinute, inComponent: 1, animated: false)
        self.alertTitleField.text = self.alertTitle
        
        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
        
        self.cancelBtn.layer.cornerRadius = 8.0
        self.cancelBtn.layer.masksToBounds = true
        self.cancelBtn.layer.borderWidth = 1.0
        self.cancelBtn.layer.borderColor = self.cancelBtn.titleColorForState(.Normal)?.CGColor
        
        self.saveBtn.layer.cornerRadius = 8.0
        self.saveBtn.layer.masksToBounds = true
        self.saveBtn.layer.borderWidth = 1.0
        self.saveBtn.layer.borderColor = self.saveBtn.titleColorForState(.Normal)?.CGColor
        
        
        self.cancelBtn.addTarget(self, action: "btnSwapBackgroudColorWithTitleColor:", forControlEvents: .TouchDown)
        self.cancelBtn.addTarget(self, action: "btnSwapBackgroudColorWithTitleColor:", forControlEvents: .TouchUpOutside)
        self.saveBtn.addTarget(self, action: "btnSwapBackgroudColorWithTitleColor:", forControlEvents: .TouchDown)
        self.saveBtn.addTarget(self, action: "btnSwapBackgroudColorWithTitleColor:", forControlEvents: .TouchUpOutside)
        
        let btnsCount = self.weekBtnStack.arrangedSubviews.count
        for index in 0 ... btnsCount-1 {
            if let btn = self.weekBtnStack.arrangedSubviews[index] as? UIButton {
                let weekBtn = WeekButton()
                weekBtn.setTitle(btn.titleForState(.Normal), forState: .Normal)
                weekBtn.setTitleColor(btn.titleColorForState(.Normal), forState: .Normal)
                weekBtn.backgroundColor = btn.tintColor
                weekBtn.bounds = btn.bounds
                weekBtn.day = index + 1
                let mask = repeatDateMask
                if (mask >> index) & 1 == 1 {
                    btnSwapBackgroudColorWithTitleColor(weekBtn)
                }
                weekBtn.layer.cornerRadius = weekBtn.bounds.width / 2.0
                weekBtn.layer.masksToBounds = true
                btn.hidden = true
                weekBtn.addTarget(self, action: "btnSwapBackgroudColorWithTitleColor:", forControlEvents: .TouchDown)
                self.weekBtns.append(weekBtn)
                self.weekBtnStack.addArrangedSubview(weekBtn)
            }
        }
        self.refreshRepeatDate()
        self.registerForKeyboardNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let kbRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        let windowHeight = self.view.window!.bounds.height
        if kbRect.origin.y >= windowHeight {
            return
        }
        let y = windowHeight - self.view.frame.height - kbRect.height
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.frame.origin.y = y
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let kbRect = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        if kbRect.origin.y >= self.view.window!.bounds.height {
            return
        }
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: kbRect.height)
        }
    }
    //MARK: Delegate and DateSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 12 * 60
    }
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 34
    }
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80.0
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let number: Int
        if component == 0 {
            number = row % 24
        } else {
            number = row % 60
        }
        let string = number < 10 ? ("0" + String(number)) : String(number)
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.theHour = row % 24
        } else {
            self.theMinute = row % 60
        }
        self.refreshRepeatDate()
    }
    func refreshRepeatDate() {
        let theHour = self.theHour >= 10 ? String(self.theHour) : String(0) + String(self.theHour)
        let theMinute = self.theMinute >= 10 ? String(self.theMinute) : String(0) + String(self.theMinute)
        self.alertTime = theHour + ":" + theMinute
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func btnSwapBackgroudColorWithTitleColor(sender: UIButton) {
        let color = sender.titleColorForState(.Normal)
        sender.setTitleColor(sender.backgroundColor, forState: .Normal)
        sender.backgroundColor = color
        if let btn = sender as? WeekButton {
            btn.checked = !btn.checked
        }
        //self.alertTitleField.resignFirstResponder()
    }
    @IBAction func cancelTap(sender: UIButton) {
        self.alertTitleField.resignFirstResponder()
        if let presenting = self.presentingViewController {
            presenting.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    @IBAction func saveTap(sender: UIButton) {
        self.alertTitleField.resignFirstResponder()
        var repeatDate = " "
        for btn in self.weekBtns {
            if btn.checked {
                self.repeatDateMask |= (1 << (btn.day - 1))
                repeatDate += " 周" + btn.titleLabel!.text!
            } else {
                self.repeatDateMask &= ~(1 << (btn.day - 1))
            }
        }
        let index = repeatDate.startIndex.advancedBy(1)
        repeatDate = repeatDate.substringFromIndex(index)
        switch self.repeatDateMask {
        case 127:
            self.repeatDate = "每天"
        case 96:
            self.repeatDate = "周末"
        case 31:
            self.repeatDate = "工作日"
        default:
            self.repeatDate = repeatDate
        }
        if let alertText = alertTitleField.text {
            alertTitle = alertText
            if alertText.isEmpty {
                alertTitle = "喝水提醒"
            }
        } else {
            alertTitle = "喝水提醒"
        }
        let newReminder = (self.alertTime, self.alertTitle, self.repeatDate, self.repeatDateMask, self.theHour, self.theMinute, true)
        if let presenting = self.presentingViewController {
            if let reminderSetting = self.SaveDataDelegate {
                if self.reminder == nil {
                    reminderSetting.addReminder(newReminder)
                } else {
                    let (_, atRow) = self.reminder!
                    reminderSetting.modifyReminder(newReminder, atRow: atRow)
                }
            }
            presenting.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
