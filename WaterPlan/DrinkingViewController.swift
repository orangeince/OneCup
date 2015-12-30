//
//  DrinkingViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/2.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit
import CoreData

class DrinkingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, NSFetchedResultsControllerDelegate {
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
    
    //var records = [DrinkingRecord]()
    var drinkedTotalVolume = 0
    var pickedVolume = 0
    var targetVolume = 2000 {
        didSet {
            self.targetLable.text = String(targetVolume)
        }
    }
    var digitalWheelLabel: DigitalWheelLabel?
    var cupTransfrom = false
    //var volumesView: UIView?
    var transitioningDelegateForWVVC = TransitioningDelegateForWaterVolume()
    var transitioningDelegateForSettings: TransitioningDelegateForSettings?
    var transitioningDelegateForStatistic: TransitioningDelegateForStatistic?
    var fetchedResultsController: NSFetchedResultsController!
    var mangedObjectContext: NSManagedObjectContext!
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    var curDay = NSDate()
    var recordDaily: RecordDaily?
    
    var _fetchedResultsController: NSFetchedResultsController?
    

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
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let dailyGoal = userDefaults.integerForKey("DailyGoal")
        if dailyGoal == 0 {
            self.targetVolume = 2000
        } else {
            self.targetVolume = dailyGoal
        }
        
        //self.targetLable.text = String(self.targetVolume)
        
        
        initializeFetchedResultsController()
        if recordDaily != nil {
            drinkedTotalVolume = Int(recordDaily!.totalVolume!)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshRecords()
        DrinkingWater(0)
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
        
        //offsetY = self.volumeStackView.frame.origin.y + self.volumeStackView.frame.height
        //self.volumeStackView.transform = CGAffineTransformTranslate(self.volumeStackView.transform, 0, -offsetY)
        offsetY = self.goalBackgroudView.frame.origin.y + self.goalBackgroudView.frame.height
        self.goalBackgroudView.transform = CGAffineTransformTranslate(self.goalBackgroudView.transform, 0, -offsetY)
        
        self.drinkedTableView.alpha = 0.0
        self.settingBtn.alpha = 0.0
        self.statisticBtn.alpha = 0.0
    }
    func restoreDrinkedVolume() {
        DrinkingWater(0)
        self.drinkingCup.transform = CGAffineTransformIdentity
        self.goalBackgroudView.transform = CGAffineTransformIdentity
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
        //return self.fetchedResultsController.sections!.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return records.count
        //return self.fetchedResultsController
        if let sections = self.fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = drinkedTableView.dequeueReusableCellWithIdentifier("drinkedCell", forIndexPath: indexPath) as! drinkedCell
        //let record = records[indexPath.row]
        //cell.timeLabel.text = record.drinkingTime
        //cell.volumeLabel.text = String(record.drinkingVolume)
        self.configureCell(cell, indexPath: indexPath)
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //let volume = records[indexPath.row].drinkingVolume
            //records.removeAtIndex(indexPath.row)
            //drinkedTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            let record = self.fetchedResultsController.objectAtIndexPath(indexPath) as! RecordDetail
            let volume = Int(record.volume!)
            let context = self.mangedObjectContext
            context.deleteObject(record)
            recordDaily!.totalVolume! = Int(recordDaily!.totalVolume!) - volume
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context:\(error)")
            }
            DrinkingWater(-volume)
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Normal, title: "delete") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            let record = self.fetchedResultsController.objectAtIndexPath(indexPath) as! RecordDetail
            let volume = Int(record.volume!)
            let context = self.mangedObjectContext
            context.deleteObject(record)
            self.recordDaily!.totalVolume! = Int(self.recordDaily!.totalVolume!) - volume
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context:\(error)")
            }
            self.DrinkingWater(-volume)
        }
        deleteAction.backgroundColor = UIColor(white: 0.5, alpha: 0.0)
        return [deleteAction]
    }
    
    // MARK: presentation
    @IBAction func drinkingBtnTap(sender: UIButton) {
        
        let presentedVC = WaterVolumeViewController()
        presentedVC.transitioningDelegate = self.transitioningDelegateForWVVC
        presentedVC.modalPresentationStyle = .Custom
        presentViewController(presentedVC, animated: true, completion: nil)
    }
    func getTwoDigitNumber(num: Int) -> String {
        return num < 10 ? "0" + String(num) : String(num)
    }
    func dismissWaterVolumeViewController(drinkedVolume: Int) {
        self.drinkingCup.alpha = 0.0
        dismissViewControllerAnimated(true, completion:{() -> Void in self.drinkingCup.alpha = 1.0 } )
        
        if drinkedVolume == 10 {
            resetAllTestData()
            refreshRecords()
            return
        }
        refreshRecords()
        
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        //calendar.
        let components = calendar.components([.Hour, .Minute, .Weekday], fromDate: now)
        let drinkingTime = getTwoDigitNumber(components.hour) + ":" + getTwoDigitNumber(components.minute)
        
        //let addingContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        //addingContext.parentContext = self.fetchedResultsController.managedObjectContext
        let addingContext = self.mangedObjectContext
        
        if let daily = recordDaily {
            drinkedTotalVolume = Int(daily.totalVolume!)
            daily.totalVolume = drinkedTotalVolume + drinkedVolume
        } else {
            recordDaily = NSEntityDescription.insertNewObjectForEntityForName("RecordDaily", inManagedObjectContext: addingContext) as? RecordDaily
            recordDaily!.date = now
            recordDaily!.totalVolume = drinkedVolume
            var weekDay = components.weekday
            if weekDay == 1 {
                weekDay = 7
            } else {
                weekDay = weekDay - 1
            }
            recordDaily!.weekDay = weekDay
        }
        
        let detail = NSEntityDescription.insertNewObjectForEntityForName("RecordDetail", inManagedObjectContext: addingContext) as! RecordDetail
        detail.time = drinkingTime
        detail.theHour = components.hour
        detail.theMinute = components.minute
        detail.date = now
        detail.volume = drinkedVolume
        detail.theDay = recordDaily
        
        recordDaily!.mutableSetValueForKey("details").addObject(detail)
        do {
            try addingContext.save()
        } catch {
            fatalError("Failure to save context:\(error)")
        }
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
            toVC.managedObjectContext = self.mangedObjectContext
        }
    }
    @IBAction func unwindToSegue(unwindSegue: UIStoryboardSegue) {
        //
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.targetVolume = userDefaults.integerForKey("DailyGoal")
        self.DrinkingWater(0)
        //self.targetLable.text
    }
    func initializeFetchedResultsController() {
        loadRecords()
    }
    
    func refreshRecords() {
        let calendar = NSCalendar.currentCalendar()
        if calendar.isDateInToday(curDay) {
            return
        }
        curDay = NSDate()
        drinkedTotalVolume = 0
        loadRecords()
        drinkedTableView.reloadData()
        if recordDaily != nil {
            drinkedTotalVolume = Int(recordDaily!.totalVolume!)
        }
    }
    
    func loadRecords() {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let today = calendar.startOfDayForDate(date)
        
        let detailRequest = NSFetchRequest(entityName: "RecordDetail")
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        detailRequest.sortDescriptors = [dateSort]
        detailRequest.predicate = NSPredicate(format: "date >= %@", today)
        
        let dailyRequest = NSFetchRequest(entityName: "RecordDaily")
        dailyRequest.predicate = NSPredicate(format: "date >= %@", today)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: detailRequest, managedObjectContext: self.mangedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
            let recordDailys = try self.mangedObjectContext.executeFetchRequest(dailyRequest) as! [RecordDaily]
            if recordDailys.count != 0 {
                self.recordDaily = recordDailys[0]
            } else {
                self.recordDaily = nil
            }
        } catch {
            fatalError("Failed to initailize FetchedResultController: \(error)")
        }
        
    }
    func configureCell(cell: drinkedCell, indexPath: NSIndexPath) {
        let record = self.fetchedResultsController.objectAtIndexPath(indexPath) as! RecordDetail
        cell.timeLabel.text = record.time! as String
        cell.volumeLabel.text = String(record.volume!)
    }
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        drinkedTableView.beginUpdates()
    }
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            drinkedTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            drinkedTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(self.drinkedTableView.cellForRowAtIndexPath(indexPath!)! as! drinkedCell, indexPath: indexPath!)
        case .Move:
            drinkedTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            drinkedTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.drinkedTableView.endUpdates()
    }
    func resetAllTestData() {
        
        let context = self.mangedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "RecordDaily")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: context)
            fetchRequest = NSFetchRequest(entityName: "RecordDetail")
            deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: context)
        } catch {
            fatalError("delete records error: \(error)")
        }
        
        let calendar = NSCalendar.currentCalendar()
        
        for dayIdx in 1 ... 30 {
            let now = NSDate(timeInterval: -NSTimeInterval(dayIdx * 24 * 3600), sinceDate: NSDate())
            let components = calendar.components([.Hour, .Minute, .Weekday], fromDate: now)
         
            let recordDaily = NSEntityDescription.insertNewObjectForEntityForName("RecordDaily", inManagedObjectContext: context) as! RecordDaily
            recordDaily.date = now
            recordDaily.totalVolume = 0
            var weekDay = components.weekday
            if weekDay == 1 {
                weekDay = 7
            } else {
                weekDay = weekDay - 1
            }
            recordDaily.weekDay = weekDay
            for _ in 0 ... 5 {
                let detail = NSEntityDescription.insertNewObjectForEntityForName("RecordDetail", inManagedObjectContext: context) as! RecordDetail
                let drinkedVolume = random() % 600
                let hour = random() % 24
                let minute = random() % 60
                let drinkingTime = getTwoDigitNumber(hour) + ":" + getTwoDigitNumber(minute)
                detail.time = drinkingTime
                detail.theHour = hour
                detail.theMinute = minute
                detail.date = now
                detail.volume = drinkedVolume
                detail.theDay = recordDaily
                recordDaily.totalVolume = Int(recordDaily.totalVolume!) + drinkedVolume
                
                recordDaily.mutableSetValueForKey("details").addObject(detail)
            }
        }
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context:\(error)")
        }
    }
    func clearAllRecords() -> Bool {
        let context = self.mangedObjectContext
        var fetchRequest = NSFetchRequest(entityName: "RecordDaily")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: context)
            fetchRequest = NSFetchRequest(entityName: "RecordDetail")
            deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: context)
            return true
        } catch {
            return false
            //fatalError("delete records error: \(error)")
        }
    }
}
