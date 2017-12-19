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
    var fireDate = Date()
    //var reminder: ((String, String, String, Int, Int, Int, Bool), Int)?
    var reminder: (Reminder, Int)?
    var SaveDataDelegate: ReminderTableViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        let curDate = Date()
        let calendarComponents = (Calendar.current as NSCalendar).components([.hour, .minute], from: curDate)
        self.theHour = calendarComponents.hour!
        self.theMinute = calendarComponents.minute!
        
        if let reminder = self.reminder {
            self.alertTitle = reminder.0.alertTitle
            self.repeatMask = reminder.0.repeatMask
            self.theHour = reminder.0.theHour
            self.theMinute = reminder.0.theMinute
            self.enable = reminder.0.enable
            self.fireDate = reminder.0.fireDate as Date
            self.identifier = reminder.0.identifier
             //((alertTime, alertTitle, repeatDate, repeatDateMask, theHour, theMinute, enable), _) = reminder
        }
       
        self.pickerView.selectRow(self.pickerView.numberOfRows(inComponent: 0) / 2 + self.theHour, inComponent: 0, animated: false)
        self.pickerView.selectRow(self.pickerView.numberOfRows(inComponent: 1) / 2 + self.theMinute, inComponent: 1, animated: false)
        self.alertTitleField.text = self.alertTitle
        
        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
        
        self.cancelBtn.layer.cornerRadius = 8.0
        self.cancelBtn.layer.masksToBounds = true
        self.cancelBtn.layer.borderWidth = 1.0
        self.cancelBtn.layer.borderColor = self.cancelBtn.titleColor(for: UIControlState())?.cgColor
        
        self.saveBtn.layer.cornerRadius = 8.0
        self.saveBtn.layer.masksToBounds = true
        self.saveBtn.layer.borderWidth = 1.0
        self.saveBtn.layer.borderColor = self.saveBtn.titleColor(for: UIControlState())?.cgColor
        
        
        self.cancelBtn.addTarget(self, action: #selector(ReminderNewViewController.btnSwapBackgroudColorWithTitleColor(_:)), for: .touchDown)
        self.cancelBtn.addTarget(self, action: #selector(ReminderNewViewController.btnSwapBackgroudColorWithTitleColor(_:)), for: .touchUpOutside)
        self.saveBtn.addTarget(self, action: #selector(ReminderNewViewController.btnSwapBackgroudColorWithTitleColor(_:)), for: .touchDown)
        self.saveBtn.addTarget(self, action: #selector(ReminderNewViewController.btnSwapBackgroudColorWithTitleColor(_:)), for: .touchUpOutside)
        
        let btnsCount = self.weekBtnStack.arrangedSubviews.count
        for index in 0 ... btnsCount-1 {
            if let btn = self.weekBtnStack.arrangedSubviews[index] as? UIButton {
                let weekBtn = WeekButton()
                weekBtn.setTitle(btn.title(for: UIControlState()), for: UIControlState())
                weekBtn.setTitleColor(btn.titleColor(for: UIControlState()), for: UIControlState())
                weekBtn.backgroundColor = btn.tintColor
                weekBtn.bounds = btn.bounds
                weekBtn.day = index + 1
                //let mask = repeatMask
                if (1 << index) & repeatMask > 0 {
                    btnSwapBackgroudColorWithTitleColor(weekBtn)
                }
                weekBtn.layer.cornerRadius = weekBtn.bounds.width / 2.0
                weekBtn.layer.masksToBounds = true
                btn.isHidden = true
                weekBtn.addTarget(self, action: #selector(ReminderNewViewController.btnSwapBackgroudColorWithTitleColor(_:)), for: .touchDown)
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
        NotificationCenter.default.addObserver(self, selector: #selector(ReminderNewViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReminderNewViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let kbRect = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let windowHeight = self.view.window!.bounds.height
        if (kbRect?.origin.y)! >= windowHeight {
            return
        }
        let y = windowHeight - self.view.frame.height - (kbRect?.height)! + 4.0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame.origin.y = y
        }) 
    }
    func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let kbRect = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        if (kbRect?.origin.y)! >= self.view.window!.bounds.height {
            return
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: (kbRect?.height)! - 4.0)
        }) 
    }
    //MARK: Delegate and DateSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 12 * 60
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 34
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80.0
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let number: Int
        if component == 0 {
            number = row % 24
        } else {
            number = row % 60
        }
        let string = number < 10 ? ("0" + String(number)) : String(number)
        let color = UIColor.black//self.pickerView.tintColor
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: color])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
    func btnSwapBackgroudColorWithTitleColor(_ sender: UIButton) {
        let color = sender.titleColor(for: UIControlState())
        sender.setTitleColor(sender.backgroundColor, for: UIControlState())
        sender.backgroundColor = color
        if let btn = sender as? WeekButton {
            btn.checked = !btn.checked
        }
        //self.alertTitleField.resignFirstResponder()
    }
    @IBAction func cancelTap(_ sender: UIButton) {
        self.alertTitleField.resignFirstResponder()
        if let presenting = self.presentingViewController {
            presenting.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func saveTap(_ sender: UIButton) {
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
        let calendar = Calendar.current
        let now = Date()
        self.fireDate = (calendar as NSCalendar).date(bySettingHour: theHour, minute: theMinute, second: 0, of: now, options: .matchFirst)!
        if self.repeatMask == 0 {
            if (calendar as NSCalendar).compare(self.fireDate, to: now, toUnitGranularity: .minute) != .orderedDescending {
                self.fireDate = Date(timeInterval: TimeInterval(24 * 3600), since: self.fireDate)
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
            presenting.dismiss(animated: true, completion: nil)
        }
    }
    func generateIdentifier() -> String {
        let calendar = Calendar.current
        let curComp = (calendar as NSCalendar).components([.year,.month,.day,.hour,.minute,.second], from: Date())
        return String(describing: curComp.year) + String(describing: curComp.month) + String(describing: curComp.day) + String(describing: curComp.hour) + String(describing: curComp.minute) + String(describing: curComp.second) + String(Int(arc4random()) % 100)
    }

}
