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
    var alertTitle = ""
    //var alertTime = ""
    //var repeatDate = ""
    var repeatMask = 0
    var theHour = 0
    var theMinute = 0
    var enable = true
    var identifier = ""
    var fireDate = NSDate()
    //var reminder: ((String, String, String, Int, Int, Int, Bool), Int)?
    var reminder: (Reminder, Int)?
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
            self.alertTitle = reminder.0.alertTitle
            self.repeatMask = reminder.0.repeatMask
            self.theHour = reminder.0.theHour
            self.theMinute = reminder.0.theMinute
            self.enable = reminder.0.enable
            self.fireDate = reminder.0.fireDate
            self.identifier = reminder.0.identifier
             //((alertTime, alertTitle, repeatDate, repeatDateMask, theHour, theMinute, enable), _) = reminder
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
                //let mask = repeatMask
                if (1 << index) & repeatMask > 0 {
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
        //self.refreshRepeatDate()
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
        let y = windowHeight - self.view.frame.height - kbRect.height + 4.0
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
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: kbRect.height - 4.0)
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
        let color = UIColor.blackColor()//self.pickerView.tintColor
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: color])
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.theHour = row % 24
        } else {
            self.theMinute = row % 60
        }
        //self.refreshRepeatDate()
    }
    //func refreshRepeatDate() {
        //let theHour = self.theHour >= 10 ? String(self.theHour) : String(0) + String(self.theHour)
        //let theMinute = self.theMinute >= 10 ? String(self.theMinute) : String(0) + String(self.theMinute)
        //self.alertTime = theHour + ":" + theMinute
    //}
    

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
        for btn in self.weekBtns {
            if btn.checked {
                self.repeatMask |= (1 << (btn.day - 1))
            } else {
                self.repeatMask &= ~(1 << (btn.day - 1))
            }
        }
        if let alertText = alertTitleField.text {
            alertTitle = alertText
            if alertText.isEmpty {
                alertTitle = "喝水提醒"
            }
        } else {
            alertTitle = "喝水提醒"
        }
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        self.fireDate = calendar.dateBySettingHour(theHour, minute: theMinute, second: 0, ofDate: now, options: .MatchFirst)!
        if self.repeatMask == 0 {
            if calendar.compareDate(self.fireDate, toDate: now, toUnitGranularity: .Minute) != .OrderedDescending {
                self.fireDate = NSDate(timeInterval: NSTimeInterval(24 * 3600), sinceDate: self.fireDate)
            }
        }
        self.identifier = generateIdentifier()
        if let presenting = self.presentingViewController {
            if let reminderSetting = self.SaveDataDelegate {
                if let theReminder = self.reminder {
                    let newReminder = theReminder.0
                    newReminder.alertTitle = self.alertTitle
                    newReminder.theHour = self.theHour
                    newReminder.theMinute = self.theMinute
                    newReminder.enable = true
                    //newReminder.identifier = generateIdentifier()  //Identifier不需要更新
                    newReminder.fireDate = self.fireDate
                    newReminder.repeatMask = self.repeatMask
                    reminderSetting.modifyReminder(theReminder.1)
                } else {
                    let newReminder = Reminder(
                        alertTitle: self.alertTitle,
                        theHour: self.theHour,
                        theMinute: self.theMinute,
                        fireDate: self.fireDate,
                        repeatMask: self.repeatMask,
                        identifier: self.identifier,
                        enable: self.enable
                    )
                    reminderSetting.addReminder(newReminder)
                }
            }
            presenting.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func generateIdentifier() -> String {
        let calendar = NSCalendar.currentCalendar()
        let curComp = calendar.components([.Year,.Month,.Day,.Hour,.Minute,.Second], fromDate: NSDate())
        return String(curComp.year) + String(curComp.month) + String(curComp.day) + String(curComp.hour) + String(curComp.minute) + String(curComp.second) + String(random() % 100)
    }

}
