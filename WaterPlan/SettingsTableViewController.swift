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
    var manageRecordsDelegate: DrinkingViewController?
    var settings = NSMutableDictionary()
    var needSave = false
    var roundCorner = true
    var dailyGoal = 2000 {
        didSet {
            self.dailyGoalLabel.text = String(self.dailyGoal) + " ml"
            //self.settings.setValue(dailyGoal, forKey: "DailyGoal")
            if needSave {
                let userDefaults = UserDefaults.standard
                userDefaults.set(dailyGoal, forKey: "DailyGoal")
                userDefaults.synchronize()
            }
        }
    }
    var reminderEnable = false {
        didSet {
            self.reminderEnableLabel.text = reminderEnable ? "开启":"关闭"
            self.settings.setValue(reminderEnable, forKey: "ReminderEnable")
            if needSave {
                //self.saveSettings()
                let userDefaults = UserDefaults.standard
                userDefaults.set(reminderEnable, forKey: "ReminderEnable")
                userDefaults.synchronize()
            }
        }
    }
    var shortcutCupCount = 4 {
        didSet {
            self.shortcutCupCountLabel.text = String(shortcutCupCount)
            //self.settings.setValue(shortcutCupCount, forKey: "ShortcutCupCount")
            if needSave {
                let userDefaults = UserDefaults.standard
                userDefaults.set(shortcutCupCount, forKey: "ShortcutCupShowCount")
                userDefaults.synchronize()
            }
        }
    }
    var shortcutCupArray = NSMutableArray() {
        didSet {
            if needSave {
                let userDefaults = UserDefaults.standard
                userDefaults.set(shortcutCupArray, forKey: "ShortcutCups")
                userDefaults.synchronize()
            }
        }
    }
    var reminderArray = NSMutableArray() {
        didSet {
            //self.settings.setValue(reminderArray, forKey: "Reminders")
            if needSave {
                let userDefaults = UserDefaults.standard
                userDefaults.set(reminderArray, forKey: "Reminders")
                userDefaults.synchronize()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController!.navigationBar.tintColor = UIColor.white
        //UITableViewCell.appearance().backgroundColor
        loadSettings()
        self.needSave = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
    func loadSettings() {
        /*
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
        */
        if self.settings.count == 0 {
            let userDefaults = UserDefaults.standard
            self.dailyGoal = userDefaults.integer(forKey: "DailyGoal")
            self.reminderEnable = userDefaults.bool(forKey: "ReminderEnable")
            self.shortcutCupCount = userDefaults.integer(forKey: "ShortcutCupShowCount")
            let originObject = userDefaults.object(forKey: "Reminders")
            if let reminders = originObject as? NSArray {
                self.reminderArray = NSMutableArray(array: reminders)
            }
            let cupObject = userDefaults.object(forKey: "ShortcutCups")
            if let cups = cupObject as? NSArray {
                self.shortcutCupArray = NSMutableArray(array: cups)
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
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)[0]
        let plistPath = rootPath + "Settings.plist"
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: self.settings, format: .xml, options: 0)
            try? plistData.write(to: URL(fileURLWithPath: plistPath), options: [.atomic])
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.frame = CGRectMake(5.0, cell.frame.origin.y, cell.frame.width - 10.0, cell.frame.height)
        
        if !roundCorner {
            return
        }
        
        cell.layer.masksToBounds = true
        
        let cornerSize: CGFloat = 5.0
        
        let margin = CGFloat(6.0)
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
        //cell.layer.cornerRadius = 5.0
        //cell.frame = cell.frame.insetBy(dx: 10, dy: 0)
        let shape = CAShapeLayer()
        shape.frame = cell.bounds
        //shape.frame = CGRectMake(cell.bounds.origin.x + CGFloat(10.0), cell.bounds.origin.y, cell.bounds.width - 40.0, cell.bounds.height)
        shape.path = maskPath.cgPath
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let toVC = segue.destination as? DailyGoalTableViewController {
            toVC.settingsDataSource = self
        } else if let toVC = segue.destination as? ReminderTableViewController {
            toVC.settingsDataSource = self
        } else if let toVC = segue.destination as? ShortcutCupTableViewController {
            toVC.settingsDataSource = self
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch indexPath.section {
        case 1:
            break
        case 2:
            break
        case 3:
            if row == 0 {
                let alert = UIAlertController(title: "抹掉所有数据", message: "确定要抹掉所有数据吗，抹掉之后数据将无法找回", preferredStyle: .alert)
                let clearRecordsAction = UIAlertAction(
                    title: "抹掉",
                    style: .default,
                    handler: {
                        (action: UIAlertAction) -> Void in
                        if let delegate = self.manageRecordsDelegate {
                            let successed = delegate.clearAllRecords()
                            if !successed {
                                let failedAlert = UIAlertController(title: "Sorry", message: "哎呀，不好意思，抹除数据失败啦。>_<``", preferredStyle: .alert)
                                self.present(failedAlert, animated: true, completion: nil)
                            }
                        }
                    })
                let defaultAction = UIAlertAction(title: "取消", style: .default, handler: nil)
                alert.addAction(clearRecordsAction)
                alert.addAction(defaultAction)
                //self.presentViewController(alert, animated: true, completion: )
                self.present(alert, animated: true, completion: { () -> Void in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                })
            }
        default:
            break
        }
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        //
    }
    @IBAction func unwindToSettings(_ unwindSegue: UIStoryboardSegue ) {
        //
    }

}
