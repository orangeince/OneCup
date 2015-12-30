//
//  ShortcutCupTableViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/1.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class ShortcutCupCell: UITableViewCell {
    
    @IBOutlet weak var volumeLabel: UILabel!
    var volume:Int = 0 {
        didSet {
            self.volumeLabel.text = String(volume) + "ml"
        }
    }
}


class CountPickCell: UITableViewCell {
    
    @IBOutlet weak var pickedCountLabel: UILabel!
    var pickedCount:Int = 3 {
        didSet {
            self.pickedCountLabel.text = String(pickedCount)
        }
    }
    
}

class ShortcutCup {
    var volume: Int = 0
    var imageName: String = ""
    init(volume: Int, imageName: String) {
        self.volume = volume
        self.imageName = imageName
    }
    convenience init(volume: Int) {
        self.init(volume: volume, imageName: "")
    }
}

class ShortcutCupTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var shortcutCups = [ShortcutCup]()
    var lastOtherIndexPath: NSIndexPath?
    var pickerView: UIPickerView!
    var needSave = false
    var settingsDataSource: SettingsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        for item in settingsDataSource.shortcutCupArray {
            if let cup = item as? NSDictionary,
                volume = cup.valueForKey("Volume") as? NSNumber {
                let shortcutCup = ShortcutCup(volume: Int(volume))
                self.shortcutCups.append(shortcutCup)
            }
        }
        self.tableView.setEditing(true, animated: false)

        self.needSave = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.shortcutCups.count
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 104.0
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
            let width = cell.frame.width - 12.0
            let height = cell.frame.height
            let bounds = CGRectMake(6.0, 30.0, width, height)
            let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0)
            let mask = CAShapeLayer()
            mask.frame = view.bounds
            mask.path = maskPath.CGPath
            view.layer.mask = mask
            
            let leftLebal = UILabel()
            leftLebal.text = "快捷容量个数"
            leftLebal.frame.origin.x = 20.0
            leftLebal.frame.origin.y = 30.0
            let lebalHeight = leftLebal.font.lineHeight
            var attrs = [String: AnyObject]()
            attrs[NSFontAttributeName] = leftLebal.font
            let lebalWidth = leftLebal.text!.sizeWithAttributes(attrs).width
            let orginY = 30.0 + (height - lebalHeight) / 2.0
            leftLebal.frame = CGRectMake(20.0, orginY, lebalWidth, lebalHeight)
            view.addSubview(leftLebal)
            
            let pickerView = UIPickerView()
            pickerView.frame = CGRectMake(width - 54.0, 30.0, 40.0, height)
            pickerView.dataSource = self
            pickerView.delegate = self
            pickerView.selectRow(self.settingsDataSource.shortcutCupCount, inComponent: 0, animated: false)
            self.pickerView = pickerView
            
            view.addSubview(pickerView)
            
            view.layer.masksToBounds = true
            return view
        }
        return nil
    }
    //override func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        //self.pickerView.selectRow(self.pickedCount, inComponent: 0, animated: false)
    //}
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //self.pickerView.selectRow(self.pickedCount + 1, inComponent: 0, animated: false)
        //self.pickerView.sele
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.masksToBounds = true
        
        let cornerSize: CGFloat = 5.0
        
        let margin = CGFloat(6.0)
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
        shape.frame = cell.bounds
        shape.path = maskPath.CGPath
        cell.layer.mask = shape
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShortcutCupCell", forIndexPath: indexPath) as! ShortcutCupCell
        let cup = shortcutCups[indexPath.row]
        cell.volume = cup.volume
        cell.showsReorderControl = true
        return cell
    }
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let theCup = self.shortcutCups[sourceIndexPath.row]
        self.shortcutCups.removeAtIndex(sourceIndexPath.row)
        self.shortcutCups.insert(theCup, atIndex: destinationIndexPath.row)
        self.lastOtherIndexPath = nil
        
        let cupArray = NSMutableArray()
        
        for cup in self.shortcutCups {
            let values = [
                NSNumber(integer: cup.volume),
                NSString(string: cup.imageName)
            ]
            let keys = [
                NSString(string: "Volume"),
                NSString(string: "ImageName")
            ]
            let cupDict = NSDictionary(objects: values, forKeys: keys)
            cupArray.addObject(cupDict)
        }
        self.settingsDataSource.shortcutCupArray = cupArray
    }
    func swipeCellMask(firstIndex: NSIndexPath, secondIndex: NSIndexPath) {
        let firstCell = self.tableView.cellForRowAtIndexPath(firstIndex)!
        let secondCell = self.tableView.cellForRowAtIndexPath(secondIndex)!
        let firstMask = firstCell.layer.mask
        firstCell.layer.mask = secondCell.layer.mask
        secondCell.layer.mask = firstMask
    }
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if sourceIndexPath.row != proposedDestinationIndexPath.row {
            swipeCellMask(sourceIndexPath, secondIndex: proposedDestinationIndexPath)
        } else {
            swipeCellMask(sourceIndexPath, secondIndex: self.lastOtherIndexPath!)
        }
        self.lastOtherIndexPath = proposedDestinationIndexPath
        return proposedDestinationIndexPath
    }
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.shortcutCups.count + 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 40.0
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //self.pickedCount = row
        self.settingsDataSource.shortcutCupCount = row
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
