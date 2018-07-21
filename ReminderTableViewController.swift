//
//  ReminderTableViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/10/23.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class Reminder {
    var alertTitle: String
    var theHour: Int
    var theMinute: Int
    var enable: Bool
    var repeatMask: Int
    var fireDate: Date
    var identifier: String
    
    init(alertTitle: String, theHour: Int, theMinute: Int, fireDate: Date, repeatMask: Int, identifier: String, enable: Bool) {
        self.alertTitle = alertTitle
        self.theHour = theHour
        self.theMinute = theMinute
        self.fireDate = fireDate
        self.repeatMask = repeatMask
        self.identifier = identifier
        self.enable = enable
    }
}
class ReminderTableViewController: UITableViewController {
    //MARK: Properties
    //var reminders = [Reminder]()
    
    //var reminders = [(String, String, String, Int, Int, Int, Bool)]() //alertTime,alertTitle,repeatDate,repeatDateMask, hour, minute, enable
    var reminders = [Reminder]()
    var settingsDataSource: SettingsTableViewController?
    var reminderEnable = false
    var reminderEnableSwitch: UISwitch?
    var transitionDelegateForNew: TransitioningDelegateForReminderNew?
    var tableHasBeenLoaded = false
    var needSave = false
    var roundCorner = true
    var tmpMaskLayer: CALayer?
    var maxNotificationsCount = 40
    var notificationsGroup = [([UILocalNotification], Bool)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if let settings = self.settingsDataSource {
            let reminderArray = settings.reminderArray
            if reminderArray.count > 0 {
                for item in reminderArray {
                    guard
                        let reminder = item as? NSDictionary,
                        let alertTitle = reminder.value(forKey: "AlertTitle") as? String,
                        let repeatMask = reminder.value(forKey: "RepeatMask") as? NSNumber,
                        let theHour = reminder.value(forKey: "TheHour") as? NSNumber,
                        let theMinute = reminder.value(forKey: "TheMinute") as? NSNumber,
                        let enable = reminder.value(forKey: "Enable") as? Bool,
                        let fireDate = reminder.value(forKey: "FireDate") as? Date,
                        let identifier = reminder.value(forKey: "Identifier") as? String
                    else {
                        continue
                    }
                    //self.reminders.append(Reminder(time: time, alertTitle: alertTitle, repeatDate: repeatDate))
                    //let theReminder = (time, alertTitle, repeatDate, Int(repeatDateMask), Int(theHour), Int(theMinute), enable)
                    let theReminder = Reminder(
                        alertTitle: alertTitle,
                        theHour: Int(truncating: theHour),
                        theMinute: Int(truncating: theMinute),
                        fireDate: fireDate,
                        repeatMask: Int(truncating: repeatMask),
                        identifier: identifier,
                        enable: enable
                    )
                    if repeatMask == 0 && enable {
                        if (Calendar.current as NSCalendar).compare(fireDate, to: Date(), toUnitGranularity: .minute) != .orderedDescending {
                            theReminder.enable = false
                        }
                    }
                    self.reminders.append(theReminder)
                }
            }
            self.reminderEnable = settings.reminderEnable
        }
        //self.reminders.sortInPlace({r1, r2 in r2.enable && !r1.enable})
        /*self.reminders.sortInPlace {
            (r1: Reminder, r2: Reminder) -> Bool in
            if r2.enable && !r1.enable {
                return false
            } else if r1.enable && !r2.enable {
                return true
            }
            return r1.theHour * 100 + r2.theMinute < r2.theHour * 100 + r2.theMinute
        }*/
        self.reminders.sort(by: {r1, r2 in r1.theHour * 100 + r2.theMinute < r2.theHour * 100 + r2.theMinute})
        //self.reminders.i
        //resetReminderSetting()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func saveReminderSetting() {
        if let settings = self.settingsDataSource {
            let reminderArray = NSMutableArray()
            for reminder in self.reminders {
                //let (alertTime, alertTitle, repeatDate, repeatDateMask, theHour, theMinute, enable) = reminder
                let values = [
                    //NSString(string: alertTime),
                    NSString(string: reminder.alertTitle),
                    NSNumber(value: reminder.theHour as Int),
                    NSNumber(value: reminder.theMinute as Int),
                    NSNumber(value: reminder.repeatMask as Int),
                    NSString(string: reminder.identifier),
                    reminder.fireDate,
                    reminder.enable
                ] as [Any]
                let keys = [
                    NSString(string: "AlertTitle"),
                    NSString(string: "TheHour"),
                    NSString(string: "TheMinute"),
                    NSString(string: "RepeatMask"),
                    NSString(string: "Identifier"),
                    NSString(string: "FireDate"),
                    NSString(string: "Enable")
                ]
                let reminderDict = NSDictionary(objects: values, forKeys: keys)
                reminderArray.add(reminderDict)
            }
            settings.reminderArray = reminderArray
        }
    }
    func resetReminderSetting() {
        //let reminder = Reminder(time: "00:00", alertTitle: "该喝水啦!! >_<!", repeatDate: "每天")
        reminders.removeAll()
        //var reminder = ("08:00", "记得喝水哦,o(^_^)o", "每天", 127, 8, 0, true)
        let calendar = Calendar.current
        let now = Date()
        let fireDate = (calendar as NSCalendar).date(bySettingHour: 8, minute: 0, second: 0, of: now, options: .matchFirst)!
        var reminder = Reminder(
            alertTitle: "记得喝水哦,o(^_^)o",
            theHour: 8,
            theMinute: 0,
            fireDate: fireDate,
            repeatMask: 127,
            identifier: "DailyFirstCup",
            enable: true
        )
        reminders += [reminder]
        
        reminder = Reminder(
            alertTitle: "主人该喝水啦!! >_<!!",
            theHour: 8,
            theMinute: 0,
            fireDate: now,
            repeatMask: 30,
            identifier: "WorkDayFirstCup",
            enable: true
        )
        //reminder = ("09:30", "主人主人请喝水！", "工作日", 31, 9, 30, true)
        reminders += [reminder]
        
        //reminder = ("14:59", "该喝水啦!! >_<!", "周末", 96, 14, 59, false)
        //reminders += [reminder]
        
        saveReminderSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return reminders.count
        default:
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 44.0
        case 1:
            return 72.0
        default:
            return 44.0
            //return self.tableView.
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderControlCell", for: indexPath) as! ReminderContorlCell
            self.reminderEnableSwitch = cell.reminderEnableSwitch
            cell.reminderEnableSwitch.addTarget(self, action: #selector(ReminderTableViewController.reminderEnableSwitchChange(_:)), for: .valueChanged)
            self.reminderEnableSwitch!.isOn = self.reminderEnable
            return cell
            
        } else if indexPath.section == 1 {
            let cellIdentifier = "ReminderTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReminderTableViewCell
            let reminder = reminders[indexPath.row]
            cell.reminder = reminder
            cell.timeLabel.text = getTimeDescription(reminder.theHour, minute: reminder.theMinute)
            cell.alertTitleLabel.text = reminder.alertTitle
            cell.enableSwitch.isOn = reminder.enable
            cell.enableSwitch.addTarget(self, action: #selector(ReminderTableViewController.cellEnableSwitchChange(_:)), for: .valueChanged)
            
            if !reminder.enable {
                let tmpCell = self.tableView.dequeueReusableCell(withIdentifier: "ReminderColorCell")!
                cell.backgroundColor =  tmpCell.backgroundColor!
                cell.timeLabel.textColor = UIColor.lightGray
                cell.alertTitleLabel.textColor = UIColor.lightGray
            } else {
                cell.backgroundColor = UIColor.white
                cell.timeLabel.textColor = UIColor.black
                cell.alertTitleLabel.textColor = UIColor.lightGray
            }
            
            if reminder.repeatMask > 0 {
                cell.alertTitleLabel.text! += ("，" + getRepeatDescription(reminder.repeatMask))
            }
            
            if !self.reminderEnable {
                cell.isHidden = true
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderAddCell", for: indexPath)
            if !self.reminderEnable {
                cell.isHidden = true
            }
            return cell
        }
    }
    func getTimeDescription(_ hour: Int, minute: Int) -> String {
        let hourDesc = hour < 10 ? "0" + String(hour) : String(hour)
        let minuteDesc = minute < 10 ? "0" + String(minute) : String(minute)
        return hourDesc + ":" + minuteDesc
    }
    func getRepeatDescription(_ repeatMask: Int) -> String {
        switch repeatMask {
        case 0:
            return ""
        case 127:
            return "每天"
        case 96:
            return "周末"
        case 31:
            return "工作日"
        default:
            var repeatDescription = ""
            let weekDaySymbol = ["周一","周二","周三","周四","周五","周六","周日"]
            for bit in 0 ... 6 {
                if (1 << bit) & repeatMask > 0 {
                    repeatDescription += (weekDaySymbol[bit] + " ")
                }
            }
            return repeatDescription
        }
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !roundCorner {
            return
        }
        //cell.layer.masksToBounds = true
        let cornerSize: CGFloat = 5.0
        
        let margin = CGFloat(5.0)
        let originX = cell.bounds.origin.x + margin
        let width = cell.bounds.width - margin * 2.0
        let cellBounds = CGRect(x: originX, y: cell.bounds.origin.y, width: width, height: cell.bounds.height)
        let maskPath: UIBezierPath
        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            
            maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerSize, height: cornerSize))
        } else if indexPath.row == 0 {
            
            maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerSize, height: cornerSize))
        } else  if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerSize, height: cornerSize))
        } else {
            maskPath = UIBezierPath(rect: cellBounds)
        }
        let shape = CAShapeLayer()
        shape.frame = cell.contentView.bounds
        shape.path = maskPath.cgPath
        cell.layer.mask = shape
    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let scheduledCount = self.tableView.numberOfRows(inSection: 1)
            if scheduledCount >= 6 {
                let alert = UIAlertController(title: "JustDrink", message: "最多只能设置6个提醒，请根据所需，合理分配和利用提醒设置。", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "好的", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                self.tableView.deselectRow(at: indexPath, animated: false)
            } else {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let presented = sb.instantiateViewController(withIdentifier: "ReminderNewViewController") as! ReminderNewViewController
                if self.transitionDelegateForNew == nil {
                    self.transitionDelegateForNew = TransitioningDelegateForReminderNew()
                }
                presented.modalPresentationStyle = .custom
                presented.transitioningDelegate = self.transitionDelegateForNew
                presented.SaveDataDelegate = self
                self.present(presented, animated: true, completion: nil)
            }
        }
    }
    func refreshCellMask() {
        let cellCount = self.reminders.count
        guard cellCount > 0 && self.roundCorner else { return }
        let cornerSize: CGFloat = 5.0
        let margin: CGFloat = 5.0
        
        for row in 0 ..< self.reminders.count {
            let indexPath = IndexPath(row: row, section: 1)
            let cell = self.tableView.cellForRow(at: indexPath)!
            let originX = cell.bounds.origin.x + margin
            let width = cell.bounds.width - margin * 2.0
            let cellBounds = CGRect(x: originX, y: cell.bounds.origin.y, width: width, height: cell.bounds.height)
            let maskPath: UIBezierPath
            if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerSize, height: cornerSize))
            } else if indexPath.row == 0 {
                
                maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerSize, height: cornerSize))
            } else  if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerSize, height: cornerSize))
            } else {
                maskPath = UIBezierPath(rect: cellBounds)
            }
            let shape = CAShapeLayer()
            shape.frame = cell.contentView.bounds
            shape.path = maskPath.cgPath
            cell.layer.mask = shape
        }
    }
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)!
        self.tmpMaskLayer = cell.layer.mask
        cell.layer.mask = nil
    }
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let cell = self.tableView.cellForRow(at: indexPath!) {
            cell.layer.mask = self.tmpMaskLayer
        } else if indexPath?.row != 0 {
            let theIndexPath = IndexPath(row: (indexPath?.row)! - 1, section: (indexPath?.section)!)
            if let theCell = self.tableView.cellForRow(at: theIndexPath) {
                theCell.layer.mask = self.tmpMaskLayer
            }
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reminder = self.reminders[indexPath.row]
            if reminder.enable {
                removeReminderSchedule(reminder)
            }
            self.reminders.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)
        }
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .normal, title: "delete") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                let reminder = self.reminders[indexPath.row]
                if reminder.enable {
                    self.removeReminderSchedule(reminder)
                }
                self.reminders.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .none)
                self.saveReminderSetting()
                self.refreshCellMask()
            }
            deleteAction.backgroundColor = UIColor(white: 0.5, alpha: 0.0)
            return [deleteAction]
        }
        return nil
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let presented = segue.destination as? ReminderNewViewController {
            if self.transitionDelegateForNew == nil {
                self.transitionDelegateForNew = TransitioningDelegateForReminderNew()
            }
            presented.modalPresentationStyle = .custom
            presented.transitioningDelegate = self.transitionDelegateForNew
            presented.SaveDataDelegate = self
            if let cell = sender as? UITableViewCell {
                if let reminderCell = cell as? ReminderTableViewCell {
                    if let index = self.tableView.indexPath(for: cell) {
                        presented.reminder = (reminderCell.reminder, index.row)
                    }
                }
            }
        }
        //saveReminderSetting()
        //segue.
    }
    @objc func reminderEnableSwitchChange(_ sender: UISwitch) {
        let curNoificationSettings = UIApplication.shared.currentUserNotificationSettings!
        if curNoificationSettings.types == UIUserNotificationType() {
            let alert = UIAlertController(title: "提醒", message: "如果需要使用定时提醒功能，请先允许此应用发送通知。在设置中找到本应用并更改允许发送通知的设置", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            sender.isOn = false
            return
        }
        if let settings = self.settingsDataSource {
            settings.reminderEnable = sender.isOn
        }
        let rowsCount = self.tableView.numberOfRows(inSection: 1)
        if sender.isOn {
            self.resetAllNotifications()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
        if rowsCount > 0 {
            for row in 0 ... rowsCount-1 {
                let index = IndexPath(row: row, section: 1)
                if let cell = self.tableView.cellForRow(at: index) {
                    cell.isHidden = !sender.isOn
                }
            }
        }
        let index = IndexPath(row: 0, section: 2)
        if let cell = self.tableView.cellForRow(at: index) {
            cell.isHidden = !sender.isOn
        }
    }
    func isAsendingOrderFor(_ first: Reminder, second: Reminder) -> Bool {
        return first.theHour * 100 + first.theMinute < second.theHour * 100 + second.theMinute
    }
    func addReminder(_ reminder: Reminder) {
        var row = 0
        for index in 0 ..< self.reminders.count {
            let tmpReminder = self.reminders[index]
            if isAsendingOrderFor(reminder, second: tmpReminder) {
                break
            }
            row += 1
        }
        self.reminders.insert(reminder, at: row)
        //let section = NSIndexSet(index: 1)
        //self.tableView.reloadSections(section, withRowAnimation: .None)
        let indexPath = IndexPath(row: row, section: 1)
        self.tableView.insertRows(at: [indexPath], with: .none)
        self.refreshCellMask()
        
        saveReminderSetting()
        addReminderSchedule(reminder)
    }
    func modifyReminder(_ atRow: Int) {
        let reminder = self.reminders[atRow]
        var toRow = 0
        for index in 0 ..< self.reminders.count {
            if index == atRow {
                continue
            }
            let tmpReminder = self.reminders[index]
            if isAsendingOrderFor(reminder, second: tmpReminder) {
                break
            }
            toRow += 1
        }
        let atIndexPath = IndexPath(row: atRow, section: 1)
        if toRow != atRow {
            self.reminders.remove(at: atRow)
            self.tableView.deleteRows(at: [atIndexPath], with: .none)
            //self.reminders.sortInPlace({r1, r2 in r1.theHour * 100 + r2.theMinute < r2.theHour * 100 + r2.theMinute})
            self.reminders.insert(reminder, at: toRow)
            let toIndexPath = IndexPath(row: toRow, section: 1)
            self.tableView.insertRows(at: [toIndexPath], with: .none)
            self.refreshCellMask()
            /*
            if toRow == 0 {
                let tmpIndexPath = NSIndexPath(forRow: 1, inSection: 1)
                self.tableView.reloadRowsAtIndexPaths([tmpIndexPath], withRowAnimation: .None)
            } else if toRow == self.reminders.count - 1 {
                let tmpIndexPath = NSIndexPath(forRow: toRow - 1, inSection: 1)
                self.tableView.reloadRowsAtIndexPaths([tmpIndexPath], withRowAnimation: .None)
            }
            */
        } else {
            self.tableView.reloadRows(at: [atIndexPath], with: .none)
        }
        saveReminderSetting()
        modifyReminderSchedule(reminder)
    }
    @objc func cellEnableSwitchChange(_ sender: UISwitch) {
        if let view = sender.superview?.superview?.superview {
            if let cell = view as? ReminderTableViewCell {
                if sender.isOn {
                    //let tmpCell = self.tableView.dequeueReusableCellWithIdentifier("ReminderAddCell")!
                    cell.backgroundColor =  UIColor.white
                    cell.timeLabel.textColor = UIColor.black
                    cell.alertTitleLabel.textColor = UIColor.black
                } else {
                    let tmpCell = self.tableView.dequeueReusableCell(withIdentifier: "ReminderColorCell")!
                    cell.backgroundColor =  tmpCell.backgroundColor!
                    cell.timeLabel.textColor = UIColor.lightGray
                    cell.alertTitleLabel.textColor = UIColor.lightGray
                }
                let reminder = cell.reminder
                reminder?.enable = sender.isOn
                //let indexPath = tableView.indexPathForCell(cell)!
                //self.reminders[indexPath.row] = reminder
                saveReminderSetting()
                //resetAllNotifications()
                if sender.isOn {
                    if reminder?.repeatMask == 0 { //刷新一下fireDate
                        let calendar = Calendar.current
                        let now = Date()
                        let fireDate = (calendar as NSCalendar).date(bySettingHour: (reminder?.theHour)!, minute: (reminder?.theMinute)!, second: 0, of: now, options: .matchFirst)!
                        if (calendar as NSCalendar).compare(fireDate, to: now, toUnitGranularity: .minute) != .orderedDescending {
                            reminder?.fireDate = Date(timeInterval: TimeInterval(24 * 3600), since: fireDate)
                        }
                    }
                    addReminderSchedule(reminder!)
                } else {
                    removeReminderSchedule(reminder!)
                }
            }
        }
    }
    func resetAllNotifications() {
        var notifications = [UILocalNotification]()
        for reminder in self.reminders {
            if reminder.enable == true {
                notifications += createReminderSchedules(reminder)
            }
        }
        UIApplication.shared.cancelAllLocalNotifications()
        if notifications.count > 0 {
            UIApplication.shared.scheduledLocalNotifications = notifications
        }
    }
    func modifyReminderSchedule(_ reminder: Reminder) {
        if reminder.enable {
            addReminderSchedule(reminder)
        } else {
            removeReminderSchedule(reminder)
        }
    }
    func removeReminderSchedule(_ reminder: Reminder) {
        if let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications {
            for notification in scheduledNotifications {
                if notification.userInfo != nil {
                    let dict = notification.userInfo! as NSDictionary
                    let identifier = dict.value(forKey: "identifier")! as! String
                    if identifier == reminder.identifier {
                        UIApplication.shared.cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
    func addReminderSchedule(_ reminder: Reminder) {
        let newNotifications = createReminderSchedules(reminder)
        for notification in newNotifications {
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    func createReminderSchedules(_ reminder: Reminder) -> [UILocalNotification] {
        //let (_, alertTitle, _, repeatDateMask, theHour, theMinute, _) = reminder
        let alertTitle = reminder.alertTitle
        let repeatMask = reminder.repeatMask
        let theHour = reminder.theHour
        let theMinute = reminder.theMinute
        let identifier = reminder.identifier
        let calendar = Calendar.current
        let now = Date()
        let curComp = (calendar as NSCalendar).components([.weekday, .hour, .minute], from: now)
        let curHour = curComp.hour
        let curMinute = curComp.minute
        let curWeekday = curComp.weekday! == 1 ? 7 : curComp.weekday! - 1
        let curTime = curHour! * 100 + curMinute!
        let theTime = theHour * 100 + theMinute
        if repeatMask == 0 || repeatMask == 127 {
            var fireDate = (calendar as NSCalendar).date(bySettingHour: theHour, minute: theMinute, second: 0, of: now, options: .matchStrictly)!
            if theTime <= curTime {
                fireDate = Date(timeInterval: TimeInterval(24 * 3600), since: fireDate)
            }
            let notification = UILocalNotification()
            notification.fireDate = fireDate
            notification.alertBody = alertTitle
            notification.alertTitle = "喝水提醒"
            notification.alertAction = "好的"
            notification.soundName = UILocalNotificationDefaultSoundName
            let dict = NSDictionary(object: identifier, forKey: "identifier" as NSCopying)
            notification.userInfo = dict as? [AnyHashable: Any]
            notification.applicationIconBadgeNumber = 1
            if repeatMask == 127 {
                notification.repeatInterval = .day
            }
            return [notification]
        } else {
            var notifications = [UILocalNotification]()
            for index in 0 ... 6 {
                let mask = (1 << index) & repeatMask
                if mask == 0 {
                    continue
                }
                var weekday = index + 1
                if weekday < curWeekday || (weekday == curWeekday && theTime <= curTime) {
                    weekday += 7
                }
                let tmpDate = (calendar as NSCalendar).date(bySettingHour: theHour, minute: theMinute, second: 0, of: now, options: .matchStrictly)!
                let fireDate = Date(timeInterval: TimeInterval((weekday - curWeekday) * 24 * 3600), since: tmpDate)
                let notification = UILocalNotification()
                notification.fireDate = fireDate
                notification.alertBody = alertTitle
                notification.alertTitle = "喝水提醒"
                notification.alertAction = "好的"
                notification.soundName = UILocalNotificationDefaultSoundName
                let dict = NSDictionary(object: identifier, forKey: "identifier" as NSCopying)
                notification.userInfo = dict as? [AnyHashable: Any]
                notification.applicationIconBadgeNumber = 1
                notification.repeatInterval = .weekday
                notifications.append(notification)
            }
            return notifications
        }
    }
}
