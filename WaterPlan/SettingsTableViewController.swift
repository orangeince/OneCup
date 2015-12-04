//
//  SettingsTableViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/30.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var reminderEnableLabel: UILabel!
    @IBOutlet weak var shortcutCupCountLabel: UILabel!
    var settings = NSMutableDictionary()
    var needSave = false
    var dailyGoal = 2000 {
        didSet {
            self.dailyGoalLabel.text = String(self.dailyGoal) + " ml"
            self.settings.setValue(dailyGoal, forKey: "DailyGoal")
        }
    }
    var reminderEnable = false {
        didSet {
            self.reminderEnableLabel.text = reminderEnable ? "开启":"关闭"
            self.settings.setValue(reminderEnable, forKey: "ReminderEnable")
            if needSave {
                self.saveSettings()
            }
        }
    }
    var shortcutCupCount = 4 {
        didSet {
            self.shortcutCupCountLabel.text = String(shortcutCupCount)
            self.settings.setValue(shortcutCupCount, forKey: "ShortcutCupCount")
        }
    }
    var reminderArray = NSMutableArray() {
        didSet {
            self.settings.setValue(reminderArray, forKey: "Reminders")
            if needSave {
                self.saveSettings()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        //UITableViewCell.appearance().backgroundColor
        loadSettings()
        self.needSave = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: animated)
        }
    }
    func loadSettings() {
        if self.settings.count == 0 {
            let rootPath = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0]
            var plistPath = rootPath.stringByAppendingString("Settings.plist")
            if !NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
                plistPath = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")!
            }
            let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath)
            //if let settings = NSPropertyListSerialization.propertyListFromData(plistXML!, mutabilityOption: .MutableContainersAndLeaves, format: nil, errorDescription: nil) {
            do {
                if let settings = try NSPropertyListSerialization.propertyListWithData(plistXML!, options: .MutableContainersAndLeaves, format: nil) as? NSDictionary {
                    self.settings.setDictionary(settings as [NSObject : AnyObject])
                    //--logpoint
                    print("load plist success")
                    
                    if let dailyGoal = settings.valueForKey("DailyGoal") as? NSNumber {
                        self.dailyGoal = Int(dailyGoal)
                    }
                    if let reminderEnable = settings.valueForKey("ReminderEnable") as? Bool {
                        self.reminderEnable = reminderEnable
                    }
                    if let shortcutCupCount = settings.valueForKey("ShortcutCupCount") as? NSNumber {
                        self.shortcutCupCount = Int(shortcutCupCount)
                    }
                    if let reminders = settings.valueForKey("Reminders") as? NSArray {
                        self.reminderArray = NSMutableArray(array: reminders)
                    }
                }
            } catch {
                //--logpoint
                print("load plist failed")
            }    
        }
    }
    /*
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //saveSettings()
    }
*/
    func saveSettings() {
        let rootPath = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0]
        let plistPath = rootPath.stringByAppendingString("Settings.plist")
        do {
            let plistData = try NSPropertyListSerialization.dataWithPropertyList(self.settings, format: .XMLFormat_v1_0, options: 0)
            plistData.writeToFile(plistPath, atomically: true)
            //--logpoint
            print("save success")
        } catch {
            //--logpoint
            print("save failed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 1
        }
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //cell.frame = CGRectMake(5.0, cell.frame.origin.y, cell.frame.width - 10.0, cell.frame.height)
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
        //cell.layer.cornerRadius = 5.0
        //cell.frame = cell.frame.insetBy(dx: 10, dy: 0)
        let shape = CAShapeLayer()
        shape.frame = cell.bounds
        //shape.frame = CGRectMake(cell.bounds.origin.x + CGFloat(10.0), cell.bounds.origin.y, cell.bounds.width - 40.0, cell.bounds.height)
        shape.path = maskPath.CGPath
        cell.layer.mask = shape
        //cell.layer.borderWidth = 1.0
        //cell.layer.borderColor = UIColor(white: 0.0, alpha: 0.0).CGColor
        
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
        if let toVC = segue.destinationViewController as? DailyGoalTableViewController {
            toVC.settingsDataSource = self
        } else if let toVC = segue.destinationViewController as? ReminderTableViewController {
            toVC.settingsDataSource = self
        }
    }
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        //
        print("hello")
    }
    @IBAction func unwindToSettings(unwindSegue: UIStoryboardSegue ) {
        //
    }

}
