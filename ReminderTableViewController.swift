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
    var fireDate: NSDate
    var identifier: String
    
    init(alertTitle: String, theHour: Int, theMinute: Int, fireDate: NSDate, repeatMask: Int, identifier: String, enable: Bool) {
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
                        alertTitle = reminder.valueForKey("AlertTitle") as? String,
                        repeatMask = reminder.valueForKey("RepeatMask") as? NSNumber,
                        theHour = reminder.valueForKey("TheHour") as? NSNumber,
                        theMinute = reminder.valueForKey("TheMinute") as? NSNumber,
                        enable = reminder.valueForKey("Enable") as? Bool,
                        fireDate = reminder.valueForKey("FireDate") as? NSDate,
                        identifier = reminder.valueForKey("Identifier") as? String
                    else {
                        continue
                    }
                    //self.reminders.append(Reminder(time: time, alertTitle: alertTitle, repeatDate: repeatDate))
                    //let theReminder = (time, alertTitle, repeatDate, Int(repeatDateMask), Int(theHour), Int(theMinute), enable)
                    let theReminder = Reminder(
                        alertTitle: alertTitle,
                        theHour: Int(theHour),
                        theMinute: Int(theMinute),
                        fireDate: fireDate,
                        repeatMask: Int(repeatMask),
                        identifier: identifier,
                        enable: enable
                    )
                    if repeatMask == 0 && enable {
                        if NSCalendar.currentCalendar().compareDate(fireDate, toDate: NSDate(), toUnitGranularity: .Minute) != .OrderedDescending {
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
        self.reminders.sortInPlace({r1, r2 in r1.theHour * 100 + r2.theMinute < r2.theHour * 100 + r2.theMinute})
        //self.reminders.i
        //resetReminderSetting()
    }
    override func viewWillAppear(animated: Bool) {
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
                    NSNumber(integer: reminder.theHour),
                    NSNumber(integer: reminder.theMinute),
                    NSNumber(integer: reminder.repeatMask),
                    NSString(string: reminder.identifier),
                    reminder.fireDate,
                    reminder.enable
                ]
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
                reminderArray.addObject(reminderDict)
            }
            settings.reminderArray = reminderArray
        }
    }
    func resetReminderSetting() {
        //let reminder = Reminder(time: "00:00", alertTitle: "该喝水啦!! >_<!", repeatDate: "每天")
        reminders.removeAll()
        //var reminder = ("08:00", "记得喝水哦,o(^_^)o", "每天", 127, 8, 0, true)
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let fireDate = calendar.dateBySettingHour(8, minute: 0, second: 0, ofDate: now, options: .MatchFirst)!
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderControlCell", forIndexPath: indexPath) as! ReminderContorlCell
            self.reminderEnableSwitch = cell.reminderEnableSwitch
            cell.reminderEnableSwitch.addTarget(self, action: "reminderEnableSwitchChange:", forControlEvents: .ValueChanged)
            self.reminderEnableSwitch!.on = self.reminderEnable
            return cell
            
        } else if indexPath.section == 1 {
            let cellIdentifier = "ReminderTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ReminderTableViewCell
            let reminder = reminders[indexPath.row]
            cell.reminder = reminder
            cell.timeLabel.text = getTimeDescription(reminder.theHour, minute: reminder.theMinute)
            cell.alertTitleLabel.text = reminder.alertTitle
            cell.enableSwitch.on = reminder.enable
            cell.enableSwitch.addTarget(self, action: "cellEnableSwitchChange:", forControlEvents: .ValueChanged)
            
            if !reminder.enable {
                let tmpCell = self.tableView.dequeueReusableCellWithIdentifier("ReminderColorCell")!
                cell.backgroundColor =  tmpCell.backgroundColor!
                cell.timeLabel.textColor = UIColor.lightGrayColor()
                cell.alertTitleLabel.textColor = UIColor.lightGrayColor()
            } else {
                cell.backgroundColor = UIColor.whiteColor()
                cell.timeLabel.textColor = UIColor.blackColor()
                cell.alertTitleLabel.textColor = UIColor.lightGrayColor()
            }
            
            if reminder.repeatMask > 0 {
                cell.alertTitleLabel.text! += ("，" + getRepeatDescription(reminder.repeatMask))
            }
            
            if !self.reminderEnable {
                cell.hidden = true
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderAddCell", forIndexPath: indexPath)
            if !self.reminderEnable {
                cell.hidden = true
            }
            return cell
        }
    }
    func getTimeDescription(hour: Int, minute: Int) -> String {
        let hourDesc = hour < 10 ? "0" + String(hour) : String(hour)
        let minuteDesc = minute < 10 ? "0" + String(minute) : String(minute)
        return hourDesc + ":" + minuteDesc
    }
    func getRepeatDescription(repeatMask: Int) -> String {
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
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !roundCorner {
            return
        }
        //cell.layer.masksToBounds = true
        let cornerSize: CGFloat = 5.0
        
        let margin = CGFloat(5.0)
        let originX = cell.bounds.origin.x + margin
        let width = cell.bounds.width - margin * 2.0
        let cellBounds = CGRectMake(originX, cell.bounds.origin.y, width, CGRectGetHeight(cell.bounds))
        let maskPath: UIBezierPath
        if indexPath.row == 0 && indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
            
            maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.TopLeft, .TopRight, .BottomLeft, .BottomRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
        } else if indexPath.row == 0 {
            
            maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
        } else  if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
            maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
        } else {
            maskPath = UIBezierPath(rect: cellBounds)
        }
        let shape = CAShapeLayer()
        shape.frame = cell.contentView.bounds
        shape.path = maskPath.CGPath
        cell.layer.mask = shape
    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
*/
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            let scheduledCount = self.tableView.numberOfRowsInSection(1)
            if scheduledCount >= 6 {
                let alert = UIAlertController(title: "JustDrink", message: "最多只能设置6个提醒，请根据所需，合理分配和利用提醒设置。", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            } else {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let presented = sb.instantiateViewControllerWithIdentifier("ReminderNewViewController") as! ReminderNewViewController
                if self.transitionDelegateForNew == nil {
                    self.transitionDelegateForNew = TransitioningDelegateForReminderNew()
                }
                presented.modalPresentationStyle = .Custom
                presented.transitioningDelegate = self.transitionDelegateForNew
                presented.SaveDataDelegate = self
                self.presentViewController(presented, animated: true, completion: nil)
            }
        }
    }
    func refreshCellMask() {
        let cellCount = self.reminders.count
        guard cellCount > 0 && self.roundCorner else { return }
        let cornerSize: CGFloat = 5.0
        let margin: CGFloat = 5.0
        
        for row in 0 ..< self.reminders.count {
            let indexPath = NSIndexPath(forRow: row, inSection: 1)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
            let originX = cell.bounds.origin.x + margin
            let width = cell.bounds.width - margin * 2.0
            let cellBounds = CGRectMake(originX, cell.bounds.origin.y, width, cell.bounds.height)
            let maskPath: UIBezierPath
            if indexPath.row == 0 && indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
                maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.TopLeft, .TopRight, .BottomLeft, .BottomRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
            } else if indexPath.row == 0 {
                
                maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
            } else  if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
                maskPath = UIBezierPath(roundedRect: cellBounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
            } else {
                maskPath = UIBezierPath(rect: cellBounds)
            }
            let shape = CAShapeLayer()
            shape.frame = cell.contentView.bounds
            shape.path = maskPath.CGPath
            cell.layer.mask = shape
        }
    }
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        self.tmpMaskLayer = cell.layer.mask
        cell.layer.mask = nil
    }
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
            cell.layer.mask = self.tmpMaskLayer
        } else if indexPath.row != 0 {
            let theIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            if let theCell = self.tableView.cellForRowAtIndexPath(theIndexPath) {
                theCell.layer.mask = self.tmpMaskLayer
            }
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let reminder = self.reminders[indexPath.row]
            if reminder.enable {
                removeReminderSchedule(reminder)
            }
            self.reminders.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .Normal, title: "delete") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
                let reminder = self.reminders[indexPath.row]
                if reminder.enable {
                    self.removeReminderSchedule(reminder)
                }
                self.reminders.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let presented = segue.destinationViewController as? ReminderNewViewController {
            if self.transitionDelegateForNew == nil {
                self.transitionDelegateForNew = TransitioningDelegateForReminderNew()
            }
            presented.modalPresentationStyle = .Custom
            presented.transitioningDelegate = self.transitionDelegateForNew
            presented.SaveDataDelegate = self
            if let cell = sender as? UITableViewCell {
                if let reminderCell = cell as? ReminderTableViewCell {
                    if let index = self.tableView.indexPathForCell(cell) {
                        presented.reminder = (reminderCell.reminder, index.row)
                    }
                }
            }
        }
        //saveReminderSetting()
        //segue.
    }
    func reminderEnableSwitchChange(sender: UISwitch) {
        let curNoificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        if curNoificationSettings.types == .None {
            let alert = UIAlertController(title: "提醒", message: "如果需要使用定时提醒功能，请先允许此应用发送通知。在设置中找到本应用并更改允许发送通知的设置", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            sender.on = false
            return
        }
        if let settings = self.settingsDataSource {
            settings.reminderEnable = sender.on
        }
        let rowsCount = self.tableView.numberOfRowsInSection(1)
        if sender.on {
            self.resetAllNotifications()
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        if rowsCount > 0 {
            for row in 0 ... rowsCount-1 {
                let index = NSIndexPath(forRow: row, inSection: 1)
                if let cell = self.tableView.cellForRowAtIndexPath(index) {
                    cell.hidden = !sender.on
                }
            }
        }
        let index = NSIndexPath(forRow: 0, inSection: 2)
        if let cell = self.tableView.cellForRowAtIndexPath(index) {
            cell.hidden = !sender.on
        }
    }
    func isAsendingOrderFor(first: Reminder, second: Reminder) -> Bool {
        return first.theHour * 100 + first.theMinute < second.theHour * 100 + second.theMinute
    }
    func addReminder(reminder: Reminder) {
        var row = 0
        for index in 0 ..< self.reminders.count {
            let tmpReminder = self.reminders[index]
            if isAsendingOrderFor(reminder, second: tmpReminder) {
                break
            }
            row++
        }
        self.reminders.insert(reminder, atIndex: row)
        //let section = NSIndexSet(index: 1)
        //self.tableView.reloadSections(section, withRowAnimation: .None)
        let indexPath = NSIndexPath(forRow: row, inSection: 1)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        self.refreshCellMask()
        
        saveReminderSetting()
        addReminderSchedule(reminder)
    }
    func modifyReminder(atRow: Int) {
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
            toRow++
        }
        let atIndexPath = NSIndexPath(forRow: atRow, inSection: 1)
        if toRow != atRow {
            self.reminders.removeAtIndex(atRow)
            self.tableView.deleteRowsAtIndexPaths([atIndexPath], withRowAnimation: .None)
            //self.reminders.sortInPlace({r1, r2 in r1.theHour * 100 + r2.theMinute < r2.theHour * 100 + r2.theMinute})
            self.reminders.insert(reminder, atIndex: toRow)
            let toIndexPath = NSIndexPath(forRow: toRow, inSection: 1)
            self.tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: .None)
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
            self.tableView.reloadRowsAtIndexPaths([atIndexPath], withRowAnimation: .None)
        }
        saveReminderSetting()
        modifyReminderSchedule(reminder)
    }
    func cellEnableSwitchChange(sender: UISwitch) {
        if let view = sender.superview?.superview?.superview {
            if let cell = view as? ReminderTableViewCell {
                if sender.on {
                    //let tmpCell = self.tableView.dequeueReusableCellWithIdentifier("ReminderAddCell")!
                    cell.backgroundColor =  UIColor.whiteColor()
                    cell.timeLabel.textColor = UIColor.blackColor()
                    cell.alertTitleLabel.textColor = UIColor.blackColor()
                } else {
                    let tmpCell = self.tableView.dequeueReusableCellWithIdentifier("ReminderColorCell")!
                    cell.backgroundColor =  tmpCell.backgroundColor!
                    cell.timeLabel.textColor = UIColor.lightGrayColor()
                    cell.alertTitleLabel.textColor = UIColor.lightGrayColor()
                }
                let reminder = cell.reminder
                reminder.enable = sender.on
                //let indexPath = tableView.indexPathForCell(cell)!
                //self.reminders[indexPath.row] = reminder
                saveReminderSetting()
                //resetAllNotifications()
                if sender.on {
                    if reminder.repeatMask == 0 { //刷新一下fireDate
                        let calendar = NSCalendar.currentCalendar()
                        let now = NSDate()
                        let fireDate = calendar.dateBySettingHour(reminder.theHour, minute: reminder.theMinute, second: 0, ofDate: now, options: .MatchFirst)!
                        if calendar.compareDate(fireDate, toDate: now, toUnitGranularity: .Minute) != .OrderedDescending {
                            reminder.fireDate = NSDate(timeInterval: NSTimeInterval(24 * 3600), sinceDate: fireDate)
                        }
                    }
                    addReminderSchedule(reminder)
                } else {
                    removeReminderSchedule(reminder)
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
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        if notifications.count > 0 {
            UIApplication.sharedApplication().scheduledLocalNotifications = notifications
        }
    }
    func modifyReminderSchedule(reminder: Reminder) {
        if reminder.enable {
            addReminderSchedule(reminder)
        } else {
            removeReminderSchedule(reminder)
        }
    }
    func removeReminderSchedule(reminder: Reminder) {
        if let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in scheduledNotifications {
                if notification.userInfo != nil {
                    let dict = notification.userInfo! as NSDictionary
                    let identifier = dict.valueForKey("identifier")! as! String
                    if identifier == reminder.identifier {
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
    func addReminderSchedule(reminder: Reminder) {
        let newNotifications = createReminderSchedules(reminder)
        for notification in newNotifications {
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    func createReminderSchedules(reminder: Reminder) -> [UILocalNotification] {
        //let (_, alertTitle, _, repeatDateMask, theHour, theMinute, _) = reminder
        let alertTitle = reminder.alertTitle
        let repeatMask = reminder.repeatMask
        let theHour = reminder.theHour
        let theMinute = reminder.theMinute
        let identifier = reminder.identifier
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let curComp = calendar.components([.Weekday, .Hour, .Minute], fromDate: now)
        let curHour = curComp.hour
        let curMinute = curComp.minute
        let curWeekday = curComp.weekday == 1 ? 7 : curComp.weekday - 1
        let curTime = curHour * 100 + curMinute
        let theTime = theHour * 100 + theMinute
        if repeatMask == 0 || repeatMask == 127 {
            var fireDate = calendar.dateBySettingHour(theHour, minute: theMinute, second: 0, ofDate: now, options: .MatchStrictly)!
            if theTime <= curTime {
                fireDate = NSDate(timeInterval: NSTimeInterval(24 * 3600), sinceDate: fireDate)
            }
            let notification = UILocalNotification()
            notification.fireDate = fireDate
            notification.alertBody = alertTitle
            notification.alertTitle = "喝水提醒"
            notification.alertAction = "好的"
            notification.soundName = UILocalNotificationDefaultSoundName
            let dict = NSDictionary(object: identifier, forKey: "identifier")
            notification.userInfo = dict as [NSObject : AnyObject]
            notification.applicationIconBadgeNumber = 1
            if repeatMask == 127 {
                notification.repeatInterval = .Day
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
                let tmpDate = calendar.dateBySettingHour(theHour, minute: theMinute, second: 0, ofDate: now, options: .MatchStrictly)!
                let fireDate = NSDate(timeInterval: NSTimeInterval((weekday - curWeekday) * 24 * 3600), sinceDate: tmpDate)
                let notification = UILocalNotification()
                notification.fireDate = fireDate
                notification.alertBody = alertTitle
                notification.alertTitle = "喝水提醒"
                notification.alertAction = "好的"
                notification.soundName = UILocalNotificationDefaultSoundName
                let dict = NSDictionary(object: identifier, forKey: "identifier")
                notification.userInfo = dict as [NSObject : AnyObject]
                notification.applicationIconBadgeNumber = 1
                notification.repeatInterval = .Weekday
                notifications.append(notification)
            }
            return notifications
        }
    }
}
