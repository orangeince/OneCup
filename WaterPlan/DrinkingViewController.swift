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
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var mangedObjectContext: NSManagedObjectContext!
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    var curDay = Date()
    var recordDaily: RecordDaily?
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    

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
        drinkedTotalLabel.isHidden = true
        
        settingBtn.layer.cornerRadius = settingBtn.frame.width / 2.0
        settingBtn.layer.masksToBounds = true
        
        statisticBtn.layer.cornerRadius = settingBtn.frame.width / 2.0
        statisticBtn.layer.masksToBounds = true
        
        let userDefaults = UserDefaults.standard
        let dailyGoal = userDefaults.integer(forKey: "DailyGoal")
        if dailyGoal == 0 {
            self.targetVolume = 2000
        } else {
            self.targetVolume = dailyGoal
        }
        
        //self.targetLable.text = String(self.targetVolume)
        
        
        initializeFetchedResultsController()
        if recordDaily != nil {
            drinkedTotalVolume = Int(truncating: recordDaily!.totalVolume!)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshRecords()
        DrinkingWater(0)
    }
    func DrinkingWater(_ volume: Int) {
        drinkedTotalVolume += volume
        drinkedTotalLabel.text = String(drinkedTotalVolume)
        var ratio = CGFloat(drinkedTotalVolume) / CGFloat(targetVolume)
        ratio = ratio > 1 ? 1: ratio
        let height = self.view.frame.height * ratio
        waterViewTopConstraint.constant = -height
        UIView.animate(withDuration: 1.5, animations: {
            self.waterView.superview!.layoutIfNeeded()
            //self.view.layoutIfNeeded()
        })
        digitalWheelLabel!.number = drinkedTotalVolume
    }
    func saveDrinkedVolume() {
        waterViewTopConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        var offsetY = self.view.bounds.height - self.drinkingCup.frame.origin.y 
        self.drinkingCup.transform = self.drinkingCup.transform.translatedBy(x: 0, y: offsetY)
        //self.drinkingCup.transform = CGAffineTransformRotate(self.drinkingCup.transform, CGFloat(M_PI))
        
        //offsetY = self.volumeStackView.frame.origin.y + self.volumeStackView.frame.height
        //self.volumeStackView.transform = CGAffineTransformTranslate(self.volumeStackView.transform, 0, -offsetY)
        offsetY = self.goalBackgroudView.frame.origin.y + self.goalBackgroudView.frame.height
        self.goalBackgroudView.transform = self.goalBackgroudView.transform.translatedBy(x: 0, y: -offsetY)
        
        self.drinkedTableView.alpha = 0.0
        self.settingBtn.alpha = 0.0
        self.statisticBtn.alpha = 0.0
    }
    func restoreDrinkedVolume() {
        DrinkingWater(0)
        self.drinkingCup.transform = CGAffineTransform.identity
        self.goalBackgroudView.transform = CGAffineTransform.identity
        self.drinkedTableView.alpha = 1.0
        self.settingBtn.alpha = 1.0
        self.statisticBtn.alpha = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: delegation
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        //return self.fetchedResultsController.sections!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return records.count
        //return self.fetchedResultsController
        if let sections = self.fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = drinkedTableView.dequeueReusableCell(withIdentifier: "drinkedCell", for: indexPath) as! drinkedCell
        //let record = records[indexPath.row]
        //cell.timeLabel.text = record.drinkingTime
        //cell.volumeLabel.text = String(record.drinkingVolume)
        self.configureCell(cell, indexPath: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //let volume = records[indexPath.row].drinkingVolume
            //records.removeAtIndex(indexPath.row)
            //drinkedTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            let record = self.fetchedResultsController.object(at: indexPath) as! RecordDetail
            let volume = Int(truncating: record.volume!)
            let context = self.mangedObjectContext
            context?.delete(record)
            recordDaily!.totalVolume! = (Int(truncating: recordDaily!.totalVolume!) - volume) as NSNumber
            do {
                try context?.save()
            } catch {
                fatalError("Failure to save context:\(error)")
            }
            DrinkingWater(-volume)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "delete") { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let record = self.fetchedResultsController.object(at: indexPath) as! RecordDetail
            let volume = Int(truncating: record.volume!)
            let context = self.mangedObjectContext
            context?.delete(record)
            self.recordDaily!.totalVolume! = (Int(truncating: self.recordDaily!.totalVolume!) - volume) as NSNumber
            do {
                try context?.save()
            } catch {
                fatalError("Failure to save context:\(error)")
            }
            self.DrinkingWater(-volume)
        }
        deleteAction.backgroundColor = UIColor(white: 0.5, alpha: 0.0)
        return [deleteAction]
    }
    
    // MARK: presentation
    @IBAction func drinkingBtnTap(_ sender: UIButton) {
        
        let presentedVC = WaterVolumeViewController()
        presentedVC.transitioningDelegate = self.transitioningDelegateForWVVC
        presentedVC.modalPresentationStyle = .custom
        present(presentedVC, animated: true, completion: nil)
    }
    func getTwoDigitNumber(_ num: Int) -> String {
        return num < 10 ? "0" + String(num) : String(num)
    }
    func dismissWaterVolumeViewController(_ drinkedVolume: Int) {
        self.drinkingCup.alpha = 0.0
        dismiss(animated: true, completion:{() -> Void in self.drinkingCup.alpha = 1.0 } )
        
        guard drinkedVolume > 0 else { return }
        if drinkedVolume == 10 {
            resetAllTestData()
            refreshRecords(force: true)
            return
        }
        refreshRecords()
        
        let now = Date()
        let calendar = Calendar.current
        //calendar.
        let components = (calendar as NSCalendar).components([.hour, .minute, .weekday], from: now)
        let drinkingTime = getTwoDigitNumber(components.hour!) + ":" + getTwoDigitNumber(components.minute!)
        
        //let addingContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        //addingContext.parentContext = self.fetchedResultsController.managedObjectContext
        let addingContext = self.mangedObjectContext
        
        if let daily = recordDaily {
            drinkedTotalVolume = Int(truncating: daily.totalVolume!)
            daily.totalVolume = drinkedTotalVolume + drinkedVolume as NSNumber
        } else {
            recordDaily = NSEntityDescription.insertNewObject(forEntityName: "RecordDaily", into: addingContext!) as? RecordDaily
            recordDaily!.date = now
            recordDaily!.totalVolume = drinkedVolume as NSNumber
            var weekDay = components.weekday
            if weekDay == 1 {
                weekDay = 7
            } else {
                weekDay = weekDay! - 1
            }
            recordDaily!.weekDay = weekDay! as NSNumber
        }
        
        let detail = NSEntityDescription.insertNewObject(forEntityName: "RecordDetail", into: addingContext!) as! RecordDetail
        detail.time = drinkingTime as NSString
        detail.theHour = components.hour! as NSNumber
        detail.theMinute = components.minute! as NSNumber
        detail.date = now
        detail.volume = drinkedVolume as NSNumber
        detail.theDay = recordDaily
        
        recordDaily!.mutableSetValue(forKey: "details").add(detail)
        do {
            try addingContext?.save()
        } catch {
            fatalError("Failure to save context:\(error)")
        }
        DrinkingWater(drinkedVolume)
    }
    
    //MARK: segue and unsegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = segue.destination as? UINavigationController {
            toVC.view.layer.cornerRadius = 8
            toVC.view.layer.masksToBounds = true
            
            if self.transitioningDelegateForSettings == nil {
                self.transitioningDelegateForSettings = TransitioningDelegateForSettings()
            }
            toVC.transitioningDelegate = self.transitioningDelegateForSettings
            if let settingVC = toVC.viewControllers.first as? SettingsTableViewController {
                settingVC.manageRecordsDelegate = self
            }
        }
        
        if let toVC = segue.destination as? StatisticViewController {
            if self.transitioningDelegateForStatistic == nil {
                self.transitioningDelegateForStatistic = TransitioningDelegateForStatistic()
            }
            toVC.transitioningDelegate = self.transitioningDelegateForStatistic
            toVC.managedObjectContext = self.mangedObjectContext
        }
    }
    @IBAction func unwindToSegue(_ unwindSegue: UIStoryboardSegue) {
        //
        let userDefaults = UserDefaults.standard
        self.targetVolume = userDefaults.integer(forKey: "DailyGoal")
        self.DrinkingWater(0)
        //self.targetLable.text
    }
    func initializeFetchedResultsController() {
        loadRecords()
    }
    
    func refreshRecords(force: Bool = false) {
        let calendar = Calendar.current
        guard force || !calendar.isDateInToday(curDay) else {
            return
        }
        curDay = Date()
        DrinkingWater(-drinkedTotalVolume)
        loadRecords()
        drinkedTableView.reloadData()
        if recordDaily != nil {
            drinkedTotalVolume = Int(truncating: recordDaily!.totalVolume!)
        }
    }
    
    func loadRecords() {
        
        let date = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        let detailRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordDetail")
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        detailRequest.sortDescriptors = [dateSort]
        detailRequest.predicate = NSPredicate(format: "date >= %@", today as CVarArg)
        
        let dailyRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordDaily")
        dailyRequest.predicate = NSPredicate(format: "date >= %@", today as CVarArg)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: detailRequest, managedObjectContext: self.mangedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
            let recordDailys = try self.mangedObjectContext.fetch(dailyRequest) as! [RecordDaily]
            if recordDailys.count != 0 {
                self.recordDaily = recordDailys[0]
            } else {
                self.recordDaily = nil
            }
        } catch {
            fatalError("Failed to initailize FetchedResultController: \(error)")
        }
        
    }
    func configureCell(_ cell: drinkedCell, indexPath: IndexPath) {
        let record = self.fetchedResultsController.object(at: indexPath) as! RecordDetail
        cell.timeLabel.text = record.time! as String
        cell.volumeLabel.text = String(describing: record.volume!)
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        drinkedTableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            drinkedTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            drinkedTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(self.drinkedTableView.cellForRow(at: indexPath!)! as! drinkedCell, indexPath: indexPath!)
        case .move:
            drinkedTableView.deleteRows(at: [indexPath!], with: .fade)
            drinkedTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.drinkedTableView.endUpdates()
    }
    func resetAllTestData() {
        
        let context = self.mangedObjectContext
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordDaily")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context!)
            fetchRequest = NSFetchRequest(entityName: "RecordDetail")
            deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try persistentStoreCoordinator.execute(deleteRequest, with: context!)
        } catch {
            fatalError("delete records error: \(error)")
        }
        
        let calendar = Calendar.current
        
        for dayIdx in 1 ... 30 {
            var theDate = Date(timeInterval: -TimeInterval(dayIdx * 24 * 3600), since: Date())
            theDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: theDate) ?? theDate
            let components = (calendar as NSCalendar).components([.hour, .minute, .weekday], from: theDate)
         
            let recordDaily = NSEntityDescription.insertNewObject(forEntityName: "RecordDaily", into: context!) as! RecordDaily
            recordDaily.date = theDate
            recordDaily.totalVolume = 0
            var weekDay = components.weekday
            if weekDay == 1 {
                weekDay = 7
            } else {
                weekDay = weekDay! - 1
            }
            recordDaily.weekDay = weekDay! as NSNumber
            for _ in 0 ... 5 {
                let detail = NSEntityDescription.insertNewObject(forEntityName: "RecordDetail", into: context!) as! RecordDetail
                let drinkedVolume = arc4random() % 600
                let hour = Int(arc4random() % 24)
                let minute = Int(arc4random() % 60)
                let drinkingTime = getTwoDigitNumber(hour) + ":" + getTwoDigitNumber(minute)
                detail.time = drinkingTime as NSString
                detail.theHour = hour as NSNumber
                detail.theMinute = minute as NSNumber
                detail.date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: theDate) ?? theDate
                detail.volume = drinkedVolume as NSNumber
                detail.theDay = recordDaily
                recordDaily.totalVolume = (Int(truncating: recordDaily.totalVolume!) + Int(drinkedVolume)) as NSNumber
                
                recordDaily.mutableSetValue(forKey: "details").add(detail)
            }
        }
        do {
            try context?.save()
        } catch {
            fatalError("Failure to save context:\(error)")
        }
    }
    func clearAllRecords() -> Bool {
        let context = self.mangedObjectContext
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordDaily")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context!)
            fetchRequest = NSFetchRequest(entityName: "RecordDetail")
            deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try persistentStoreCoordinator.execute(deleteRequest, with: context!)
            try context?.save()
            refreshRecords(force: true)
            return true
        } catch {
            return false
        }
    }
}
