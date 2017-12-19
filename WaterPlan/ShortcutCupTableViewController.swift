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
    var lastOtherIndexPath: IndexPath?
    var pickerView: UIPickerView!
    var needSave = false
    var settingsDataSource: SettingsTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        for item in settingsDataSource.shortcutCupArray {
            if let cup = item as? NSDictionary,
                let volume = cup.value(forKey: "Volume") as? NSNumber {
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.shortcutCups.count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 104.0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            let width = cell.frame.width - 12.0
            let height = cell.frame.height
            let bounds = CGRect(x: 6.0, y: 30.0, width: width, height: height)
            let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0)
            let mask = CAShapeLayer()
            mask.frame = view.bounds
            mask.path = maskPath.cgPath
            view.layer.mask = mask
            
            let leftLebal = UILabel()
            leftLebal.text = "快捷容量个数"
            leftLebal.frame.origin.x = 20.0
            leftLebal.frame.origin.y = 30.0
            let lebalHeight = leftLebal.font.lineHeight
            var attrs = [String: AnyObject]()
            attrs[NSFontAttributeName] = leftLebal.font
            let lebalWidth = leftLebal.text!.size(attributes: attrs).width
            let orginY = 30.0 + (height - lebalHeight) / 2.0
            leftLebal.frame = CGRect(x: 20.0, y: orginY, width: lebalWidth, height: lebalHeight)
            view.addSubview(leftLebal)
            
            let pickerView = UIPickerView()
            pickerView.frame = CGRect(x: width - 54.0, y: 30.0, width: 40.0, height: height)
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
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //self.pickerView.selectRow(self.pickedCount + 1, inComponent: 0, animated: false)
        //self.pickerView.sele
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
        let shape = CAShapeLayer()
        shape.frame = cell.bounds
        shape.path = maskPath.cgPath
        cell.layer.mask = shape
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShortcutCupCell", for: indexPath) as! ShortcutCupCell
        let cup = shortcutCups[indexPath.row]
        cell.volume = cup.volume
        cell.showsReorderControl = true
        return cell
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let theCup = self.shortcutCups[sourceIndexPath.row]
        self.shortcutCups.remove(at: sourceIndexPath.row)
        self.shortcutCups.insert(theCup, at: destinationIndexPath.row)
        self.lastOtherIndexPath = nil
        
        let cupArray = NSMutableArray()
        
        for cup in self.shortcutCups {
            let values = [
                NSNumber(value: cup.volume as Int),
                NSString(string: cup.imageName)
            ]
            let keys = [
                NSString(string: "Volume"),
                NSString(string: "ImageName")
            ]
            let cupDict = NSDictionary(objects: values, forKeys: keys)
            cupArray.add(cupDict)
        }
        self.settingsDataSource.shortcutCupArray = cupArray
    }
    func swipeCellMask(_ firstIndex: IndexPath, secondIndex: IndexPath) {
        let firstCell = self.tableView.cellForRow(at: firstIndex)!
        let secondCell = self.tableView.cellForRow(at: secondIndex)!
        let firstMask = firstCell.layer.mask
        firstCell.layer.mask = secondCell.layer.mask
        secondCell.layer.mask = firstMask
    }
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.row != proposedDestinationIndexPath.row {
            swipeCellMask(sourceIndexPath, secondIndex: proposedDestinationIndexPath)
        } else {
            swipeCellMask(sourceIndexPath, secondIndex: self.lastOtherIndexPath!)
        }
        self.lastOtherIndexPath = proposedDestinationIndexPath
        return proposedDestinationIndexPath
    }
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.shortcutCups.count + 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 40.0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
