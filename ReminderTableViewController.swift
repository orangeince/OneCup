//
//  ReminderTableViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/10/23.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class ReminderTableViewController: UITableViewController {
    //MARK: Properties
    //var reminders = [Reminder]()
    var reminders = [(String, String, String, Int, Int, Int, Bool)]()
    var settingsDataSource: SettingsTableViewController?
    var reminderEnable = false
    var reminderEnableSwitch: UISwitch?
    var transitionDelegateForNew: TransitioningDelegateForReminderNew?
    var tableHasBeenLoaded = false
    var needSave = false

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
                        time = reminder.valueForKey("AlertTime") as? String,
                        alertTitle = reminder.valueForKey("AlertTitle") as? String,
                        repeatDate = reminder.valueForKey("RepeatDate") as? String,
                        repeatDateMask = reminder.valueForKey("RepeatDateMask") as? NSNumber,
                        theHour = reminder.valueForKey("TheHour") as? NSNumber,
                        theMinute = reminder.valueForKey("TheMinute") as? NSNumber,
                        enable = reminder.valueForKey("Enable") as? Bool
                    else {
                        continue
                    }
                    //self.reminders.append(Reminder(time: time, alertTitle: alertTitle, repeatDate: repeatDate))
                    self.reminders.append((time, alertTitle, repeatDate, Int(repeatDateMask), Int(theHour), Int(theMinute), enable))
                }
            }
            self.reminderEnable = settings.reminderEnable
        }
        resetReminderSetting()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    func saveReminderSetting() {
        if let settings = self.settingsDataSource {
            let reminderArray = NSMutableArray()
            for reminder in self.reminders {
                let (alertTime, alertTitle, repeatDate, repeatDateMask, theHour, theMinute, enable) = reminder
                let values = [
                    NSString(string: alertTime),
                    NSString(string: alertTitle),
                    NSString(string: repeatDate),
                    NSNumber(integer: repeatDateMask),
                    NSNumber(integer: theHour),
                    NSNumber(integer: theMinute),
                    enable
                ]
                let keys = [
                    NSString(string: "AlertTime"),
                    NSString(string: "AlertTitle"),
                    NSString(string: "RepeatDate"),
                    NSString(string: "RepeatDateMask"),
                    NSString(string: "TheHour"),
                    NSString(string: "TheMinute"),
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
        var reminder = ("08:00", "记得喝水哦,o(^_^)o", "每天", 127, 8, 0, true)
        reminders += [reminder]
        
        reminder = ("09:30", "主人主人请喝水！", "工作日", 31, 9, 30, true)
        reminders += [reminder]
        
        reminder = ("14:59", "该喝水啦!! >_<!", "周末", 96, 14, 59, false)
        reminders += [reminder]
        
        saveReminderSetting()
        
        /*
        if let settings = self.settingsDataSource {
            //let reminderDict = ["Time":"00:00", "AlertTitle":"", "RepeatDate":"每天"]
            let values = [NSString(string: "00:00"), NSString(string: "该喝水啦!! >_<!"), NSString(string: "每天")]
            let keys = [NSString(string: "Time"), NSString(string: "AlertTitle"), NSString(string: "RepeatDate")]
            let reminderDict = NSDictionary(objects: values, forKeys: keys)
            settings.reminderArray.addObject(reminderDict)
        }
*/
        //reminder = Reminder(time: "10:00", alertTitle: "该喝水啦!! >_<!", repeatDate: "工作日")
        //reminders += [reminder]
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
            return 66.0
        default:
            return 44.0
            //return self.tableView.
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReminderControlCell", forIndexPath: indexPath) as! ReminderContorlCell
            //let cell = UITableViewCell()
            self.reminderEnableSwitch = cell.reminderEnableSwitch
            cell.reminderEnableSwitch.addTarget(self, action: "reminderEnableSwitchChange:", forControlEvents: .ValueChanged)
            self.reminderEnableSwitch!.on = self.reminderEnable
            return cell
            
        } else if indexPath.section == 1 {
            let cellIdentifier = "ReminderTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ReminderTableViewCell
            let reminder = reminders[indexPath.row]
            cell.reminder = reminder
            let (time, alertTitle, repeatDate, repeatDateMask, _, _, enable) = reminder
            cell.timeLabel.text = time
            cell.alertTitleLabel.text = alertTitle
            cell.enableSwitch.on = enable
            //cell.selectionStyle = .None
            //cell.enableSwitch.setValue(cell, forKey: "tempCellRef")
            cell.enableSwitch.addTarget(self, action: "cellEnableSwitchChange:", forControlEvents: .ValueChanged)
            
            if !enable {
                let tmpCell = self.tableView.dequeueReusableCellWithIdentifier("ReminderColorCell")!
                cell.backgroundColor =  tmpCell.backgroundColor!
                cell.timeLabel.textColor = UIColor.darkGrayColor()
                cell.alertTitleLabel.textColor = UIColor.darkGrayColor()
            }
            
            if repeatDateMask > 0 {
                cell.alertTitleLabel.text! += ("，" + repeatDate)
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
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.bounds = cell.bounds.insetBy(dx: 5.0, dy: 0.0)
        cell.layer.masksToBounds = true
        
        let cornerSize: CGFloat = 5.0
        
        let maskPath: UIBezierPath
        if indexPath.row == 0 && indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
            
            maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.TopLeft, .TopRight, .BottomLeft, .BottomRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
        } else if indexPath.row == 0 {
            
            maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
        } else  if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
            maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSizeMake(cornerSize, cornerSize))
        } else {
            maskPath = UIBezierPath(rect: cell.bounds)
        }
        let shape = CAShapeLayer()
        shape.frame = cell.bounds
        shape.path = maskPath.CGPath
        cell.layer.mask = shape
    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        <#code#>
    }
*/
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.reminders.removeAtIndex(indexPath.row)
        }
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .Normal, title: "delete") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
                //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            deleteAction.backgroundColor = UIColor.grayColor()
            deleteAction.backgroundEffect = UIBlurEffect(style: .Dark)
            let editAction = UITableViewRowAction(style: .Default, title: "edit", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
                //
            })
            editAction.backgroundColor = UIColor.purpleColor()
            return [deleteAction,editAction]
        }
        return nil
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
        if let settings = self.settingsDataSource {
            settings.reminderEnable = sender.on
        }
        let rowsCount = self.tableView.numberOfRowsInSection(1)
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
    func addReminder(reminder: (String, String, String, Int, Int, Int, Bool)) {
        self.reminders.append(reminder)
        let row = self.tableView.numberOfRowsInSection(1)
        let indexPath = NSIndexPath(forRow: row, inSection: 1)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        saveReminderSetting()
    }
    func modifyReminder(reminder: (String, String, String, Int, Int, Int, Bool), atRow: Int) {
        self.reminders[atRow] = reminder
        let indexPath = NSIndexPath(forRow: atRow, inSection: 1)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        saveReminderSetting()
    }
    func cellEnableSwitchChange(sender: UISwitch) {
        if let view = sender.superview?.superview?.superview {
            if let cell = view as? ReminderTableViewCell {
                if sender.on {
                    let tmpCell = self.tableView.dequeueReusableCellWithIdentifier("ReminderAddCell")!
                    cell.backgroundColor =  tmpCell.backgroundColor!
                    cell.timeLabel.textColor = UIColor.whiteColor()
                    cell.alertTitleLabel.textColor = UIColor.whiteColor()
                } else {
                    let tmpCell = self.tableView.dequeueReusableCellWithIdentifier("ReminderColorCell")!
                    cell.backgroundColor =  tmpCell.backgroundColor!
                    cell.timeLabel.textColor = UIColor.darkGrayColor()
                    cell.alertTitleLabel.textColor = UIColor.darkGrayColor()
                }
                var reminder = cell.reminder
                reminder.6 = sender.on
                let indexPath = tableView.indexPathForCell(cell)!
                self.reminders[indexPath.row] = reminder
                saveReminderSetting()
            }
        }
    }
}
