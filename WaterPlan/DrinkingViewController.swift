//
//  DrinkingViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/2.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class DrinkingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var drinkedTotalLabel: UILabel!
    @IBOutlet weak var targetLable: UILabel!
    @IBOutlet weak var drinkedTableView: UITableView!
    @IBOutlet weak var waterView: UIView!
    @IBOutlet weak var waterViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var drinkedStack: UIStackView!
    @IBOutlet weak var drinkingCup: OICupButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var statisticBtn: UIButton!
    @IBOutlet weak var volumeStackView: UIStackView!
    @IBOutlet weak var goalBackgroudView: UIView!
    
    var records = [DrinkingRecord]()
    var drinkedTotalVolume = 0
    var targetVolume = 2000
    var digitalWheelLabel: DigitalWheelLabel?
    var cupTransfrom = false
    var volumesView: UIView?
    var transitioningDelegateForWVVC = TransitioningDelegateForWaterVolume()
    var transitioningDelegateForSettings: TransitioningDelegateForSettings?
    var transitioningDelegateForStatistic: TransitioningDelegateForStatistic?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
        
        self.goalBackgroudView.layer.cornerRadius = 10.0
        self.goalBackgroudView.layer.masksToBounds = true

        drinkedTotalLabel.text = "0"
        self.view.layoutIfNeeded()
        drinkedTableView.delegate = self
        drinkedTableView.dataSource = self
        
        digitalWheelLabel = DigitalWheelLabel(label:drinkedTotalLabel , number: 0)
        drinkedStack.addArrangedSubview(digitalWheelLabel!)
        drinkedTotalLabel.hidden = true
        
        settingBtn.layer.cornerRadius = settingBtn.frame.width / 2.0
        settingBtn.layer.masksToBounds = true
        
        statisticBtn.layer.cornerRadius = settingBtn.frame.width / 2.0
        statisticBtn.layer.masksToBounds = true
        
        DrinkingWater(drinkedTotalVolume)
    }
    func DrinkingWater(volume: Int) {
        drinkedTotalVolume += volume
        drinkedTotalLabel.text = String(drinkedTotalVolume)
        var ratio = CGFloat(drinkedTotalVolume) / CGFloat(targetVolume)
        ratio = ratio > 1 ? 1: ratio
        let height = self.view.frame.height * ratio
        waterViewTopConstraint.constant = -height
        UIView.animateWithDuration(1.5, animations: {
            self.waterView.superview!.layoutIfNeeded()
            //self.view.layoutIfNeeded()
        })
        digitalWheelLabel!.number = drinkedTotalVolume
    }
    func saveDrinkedVolume() {
        waterViewTopConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        var offsetY = self.view.bounds.height - self.drinkingCup.frame.origin.y 
        self.drinkingCup.transform = CGAffineTransformTranslate(self.drinkingCup.transform, 0, offsetY)
        //self.drinkingCup.transform = CGAffineTransformRotate(self.drinkingCup.transform, CGFloat(M_PI))
        
        offsetY = self.volumeStackView.frame.origin.y + self.volumeStackView.frame.height
        self.volumeStackView.transform = CGAffineTransformTranslate(self.volumeStackView.transform, 0, -offsetY)
        
        self.drinkedTableView.alpha = 0.0
        self.settingBtn.alpha = 0.0
        self.statisticBtn.alpha = 0.0
    }
    func restoreDrinkedVolume() {
        DrinkingWater(0)
        self.drinkingCup.transform = CGAffineTransformIdentity
        self.volumeStackView.transform = CGAffineTransformIdentity
        self.drinkedTableView.alpha = 1.0
        self.settingBtn.alpha = 1.0
        self.statisticBtn.alpha = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: delegation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = drinkedTableView.dequeueReusableCellWithIdentifier("drinkedCell", forIndexPath: indexPath) as! drinkedCell
        let record = records[indexPath.row]
        cell.timeLabel.text = record.drinkingTime
        cell.volumeLabel.text = String(record.drinkingVolume) + ""
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let volume = records[indexPath.row].drinkingVolume
            records.removeAtIndex(indexPath.row)
            drinkedTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            DrinkingWater(-volume)
        }
    }
    
    // MARK: presentation
    @IBAction func drinkingBtnTap(sender: UIButton) {
        
        let presentedVC = WaterVolumeViewController()
        presentedVC.transitioningDelegate = self.transitioningDelegateForWVVC
        presentedVC.modalPresentationStyle = .Custom
        presentViewController(presentedVC, animated: true, completion: nil)
    }
    func dismissWaterVolumeViewController(drinkedVolume: Int) {
        self.drinkingCup.alpha = 0.0
        dismissViewControllerAnimated(true, completion:{() -> Void in self.drinkingCup.alpha = 1.0 } )
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: NSDate())
        let drinkingTime = String(components.hour) + ":" + String(components.minute)
        let record = DrinkingRecord(drinkingTime: drinkingTime, drinkingVolume: drinkedVolume)
        records = [record] + records
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        drinkedTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        DrinkingWater(drinkedVolume)
    }
    
    //MARK: segue and unsegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let toVC = segue.destinationViewController as? UINavigationController {
            toVC.view.layer.cornerRadius = 8
            toVC.view.layer.masksToBounds = true
            
            if self.transitioningDelegateForSettings == nil {
                self.transitioningDelegateForSettings = TransitioningDelegateForSettings()
            }
            toVC.transitioningDelegate = self.transitioningDelegateForSettings
        }
        
        if let toVC = segue.destinationViewController as? StatisticViewController {
            if self.transitioningDelegateForStatistic == nil {
                self.transitioningDelegateForStatistic = TransitioningDelegateForStatistic()
            }
            toVC.transitioningDelegate = self.transitioningDelegateForStatistic
        }
    }
    @IBAction func unwindToSegue(unwindSegue: UIStoryboardSegue) {
        //
    }
}
