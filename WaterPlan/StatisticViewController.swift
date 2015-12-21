//
//  StatisticViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/5.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit
import CoreData
class StatisticViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var clockView: OIClockView!
    @IBOutlet weak var volumeChart: OIBarChartView!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var curWeekLabel: UILabel!
    @IBOutlet weak var preWeekLabel: UILabel!
    @IBOutlet weak var nextWeekLabel: UILabel!
    @IBOutlet weak var separateView: UIView!
    
    struct RecordDailyOfWeekDates {
        var curWeek: ([(Int, Int)], [(Int, Int, Int)])
        var preWeek: ([(Int, Int)], [(Int, Int, Int)])?
        var nextWeek: ([(Int, Int)], [(Int, Int, Int)])?
    }
    
    enum PreLoadOption {
        case Previous
        case Next
    }
    
    var managedObjectContext: NSManagedObjectContext!
    var referenceIndex = 0
    var barDatas = [(Int, Int)](count: 7, repeatedValue: (0, 0))
    var clockDatas: [(Int, Int, Int)]? //= [(Int, Int, Int)]()
    var otherClockDatas: [(Int, Int, Int)]?
    var firstRecord: RecordDaily?
    var firstRecordDate: NSDate!
    var rightNow = NSDate()
    var curDate = NSDate()
    var distanceForLabel = CGFloat(0.0)
    var preWeekVolumeChart = OIBarChartView()
    var nextWeekVolumeChart = OIBarChartView()
    var preWeekClockChart = OIClockView()
    var nextWeekClockChart = OIClockView()
    
    var weeksDates = RecordDailyOfWeekDates(curWeek: ([(Int, Int)](count: 7, repeatedValue: (0,0)), []), preWeek: nil, nextWeek: nil)
    var pageViewController: UIPageViewController?
    var curChartViewController: ChartViewController!
    var otherChartViewController: ChartViewController?
    
    var curIndex:Int = 0
    var dataStore = [([(Int, Int)], [(Int, Int, Int)])]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.curChartViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ChartViewController") as! ChartViewController
        pageViewController!.setViewControllers([self.curChartViewController], direction: .Forward, animated: false, completion: nil)
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        let pageViewRect = self.view.bounds
        let margeTop = self.separateView.frame.origin.y + self.separateView.frame.height//
        //self.pageViewController!.view.frame = CGRectOffset(CGRectInset(pageViewRect, 0, margeTop), 0, margeTop)
        self.pageViewController!.view.frame = CGRectInset(pageViewRect, 0, margeTop)
        self.pageViewController!.didMoveToParentViewController(self)
        
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        
        distanceForLabel = (curWeekLabel.layer.position.x - previousBtn.layer.position.x) / 2.0
        
        preWeekLabel.alpha = 0.0
        preWeekLabel.text = "上周无数据"
        nextWeekLabel.alpha = 0.0
        nextWeekLabel.text = "下周无数据"
        
        
        //let gesture = UIPanGestureRecognizer(target: self, action: "draggingToNextRecord:")
        //gesture.maximumNumberOfTouches = 1
        //self.view.addGestureRecognizer(gesture)
        initializeData()
        
        self.curChartViewController.setChartDatas(weeksDates.curWeek)
        dataStore.append(weeksDates.curWeek)
        curIndex = 0
    }
    func initializeData() {
        let firstRecordRequest = NSFetchRequest(entityName: "RecordDaily")
        let sortDate = NSSortDescriptor(key: "date", ascending: true)
        firstRecordRequest.sortDescriptors = [sortDate]
        firstRecordRequest.fetchLimit = 1
        do {
            let firstRecord = try self.managedObjectContext.executeFetchRequest(firstRecordRequest) as! [RecordDaily]
            if firstRecord.count == 0 { //没有一条记录
                return
            }
            self.firstRecord = firstRecord[0]
            firstRecordDate = self.firstRecord!.date!
            loadDataForWeeks(self.curDate, preLoad: .Previous)
        } catch {
            fatalError("Failed to initailize firstRecord: \(error)")
        }
    }
    func getTwoDigitNumber(num: Int) -> String {
        return num < 10 ? "0" + String(num) : String(num)
    }
    func loadDataForWeeks(curDate: NSDate, preLoad: PreLoadOption) {
        let secondsPerDay = 24 * 60 * 60
        let calendar = NSCalendar.currentCalendar()
        let today = calendar.startOfDayForDate(curDate)
        let curComponents = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: curDate)
        var weekDay = curComponents.weekday
        if weekDay == 1 {
            weekDay = 7
        } else {
            weekDay--
        }
        
        let firstDateOfCurWeek = NSDate(timeInterval: -NSTimeInterval((weekDay - 1) * secondsPerDay), sinceDate: today)
        let endDateOfCurWeek = NSDate(timeInterval: NSTimeInterval((8 - weekDay) * secondsPerDay - 1), sinceDate: today)
        
        
        if preLoad == .Previous {
            if weeksDates.preWeek != nil {
                self.weeksDates.curWeek = weeksDates.preWeek!
                self.weeksDates.preWeek = nil
            } else {
                weeksDates.curWeek = loadDate(firstDateOfCurWeek, endDate: endDateOfCurWeek)
            }
            let comparison = calendar.compareDate(firstRecordDate, toDate: firstDateOfCurWeek, toUnitGranularity: .Day)
            if comparison == .OrderedAscending {
                previousBtn.enabled = true
                let interval = NSTimeInterval(7 * secondsPerDay)
                let startDate = NSDate(timeInterval: -NSTimeInterval(interval), sinceDate: firstDateOfCurWeek)
                let endDate = NSDate(timeInterval: -NSTimeInterval(interval), sinceDate: endDateOfCurWeek)
                weeksDates.preWeek = loadDate(startDate, endDate: endDate)
                let startComp = calendar.components([.Month, .Day], fromDate: startDate)
                let endComp = calendar.components([.Month, .Day], fromDate: endDate)
                preWeekLabel.text = getTwoDigitNumber(startComp.month) + "." + getTwoDigitNumber(startComp.day) + " - " + getTwoDigitNumber(endComp.month) + "." + getTwoDigitNumber(endComp.day)
            } else {
                previousBtn.enabled = false
                preWeekLabel.text = "无记录"
            }
        } else {
            if weeksDates.nextWeek != nil {
                self.weeksDates.curWeek = self.weeksDates.nextWeek!
                self.weeksDates.nextWeek = nil
            } else {
                weeksDates.curWeek = loadDate(firstDateOfCurWeek, endDate: endDateOfCurWeek)
            }
            if calendar.isDateInToday(curDate) {
                nextBtn.enabled = false
                nextWeekLabel.text = "无记录"
            } else {
                let interval = NSTimeInterval(7 * secondsPerDay)
                let startDate = NSDate(timeInterval: NSTimeInterval(interval), sinceDate: firstDateOfCurWeek)
                let endDate = NSDate(timeInterval: NSTimeInterval(interval), sinceDate: endDateOfCurWeek)
                weeksDates.nextWeek = loadDate(startDate, endDate: endDate)
                let startComp = calendar.components([.Month, .Day], fromDate: startDate)
                let endComp = calendar.components([.Month, .Day], fromDate: endDate)
                nextWeekLabel.text = getTwoDigitNumber(startComp.month) + "." + getTwoDigitNumber(startComp.day) + " - " + getTwoDigitNumber(endComp.month) + "." + getTwoDigitNumber(endComp.day)
            }
        }
    
    }
    func loadDate(startDate: NSDate, endDate: NSDate) -> ([(Int, Int)],[(Int, Int, Int)]) {
        
        var dailyDatas = [(Int, Int)](count: 7, repeatedValue: (0, 0))
        var detailDatas = [(Int, Int, Int)]()
        let dailyRequest = NSFetchRequest(entityName: "RecordDaily")
        dailyRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate, endDate)
        
        do {
            let recordDailys = try self.managedObjectContext.executeFetchRequest(dailyRequest) as! [RecordDaily]
            for daily in recordDailys {
                let day = Int(daily.weekDay!)
                let volume = Int(daily.totalVolume!)
                let details = daily.details!.allObjects as! [RecordDetail]
                for index in 0 ..< details.count {
                    let detail = details[index]
                    let detailVolume = Int(detail.volume!)
                    let theHour = Int(detail.theHour!)
                    let theMinute = Int(detail.theMinute!)
                    detailDatas.append((theHour, theMinute, detailVolume))
                }
                dailyDatas[day - 1] = (volume, day)
            }
            return (dailyDatas, detailDatas)
        } catch {
            fatalError("Failed to initailize FetchedResultController: \(error)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initializeDatas(animatied: Bool) {
        let barDatas = [
                            (random() % 3000, 1),
                            (random() % 3000, 1),
                            (random() % 3000, 1),
                            (random() % 1000, 1),
                            (random() % 3000, 1),
                            (random() % 3000, 1),
                            (random() % 3000, 1)
                        ]
        volumeChart.setData(barDatas)
        let datas = [
                        (9, 0, 200),
                        (12, 40, 300),
                        (2, 0, 50),
                        (18, 20, 500),
                        (1, 0, 250),
                        (14, 40, 380),
                        (22, 0, 420),
                        (17, 20, 530)
                    ]
        clockView.setData(datas)
        if animatied {
            volumeChart.setData(self.weeksDates.curWeek.0)
            clockView.setData(self.weeksDates.curWeek.1)
            volumeChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
            clockView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        }
    }
    func clearDatas(animated: Bool) {
        if animated {
            volumeChart.animateReversal(0.5)
            clockView.animateReversal(0.5)
        }
        //volumeChart.setData([])
        //clockView.setData([])
    }
    
    func draggingToNextRecord(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            gesture.setTranslation(CGPointMake(0, 0), inView: self.view)
        case .Changed:
            let translation = gesture.translationInView(self.view)
            let percentage = translation.x / CGRectGetWidth(self.view.bounds)
            self.volumeChart.dataReduceWithRatio(fabs(percentage))
            if percentage > 0 {
                preWeekLabel.layer.position.x = previousBtn.layer.position.x + percentage * distanceForLabel
                preWeekLabel.alpha = 1.0 * percentage
            } else {
                nextWeekLabel.center.x = nextBtn.center.x + percentage * distanceForLabel
                nextWeekLabel.alpha = 1.0 * fabs(percentage)
            }
            let scale = 1.0 - fabs(percentage)
            curWeekLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale)
            curWeekLabel.alpha = 1.0 - fabs(percentage)
            
        case .Ended:
            let translation = gesture.translationInView(self.view)
            let percentage = translation.x / CGRectGetWidth(self.view.bounds)
            let intervalOfWeek = NSTimeInterval(24 * 3600 * 7)
            if percentage > 0.5 && self.previousBtn.enabled == true {
                
                preWeekLabel.layer.position.x = previousBtn.layer.position.x + percentage * distanceForLabel
                self.curDate = NSDate(timeInterval: -intervalOfWeek, sinceDate: self.curDate)
                self.weeksDates.nextWeek = self.weeksDates.curWeek
                loadDataForWeeks(curDate, preLoad: .Previous)
                self.volumeChart.animateReversal(0.5)
                
                self.volumeChart.setDataWithAnimation(self.weeksDates.curWeek.0, animationDurtion: 1.0, delay: 0.5)
                self.clockView.setData(self.weeksDates.curWeek.1)
                self.clockView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                
                UIView.animateWithDuration(
                    1,
                    animations: { () -> Void in
                        self.preWeekLabel.layer.position.x = self.curWeekLabel.layer.position.x
                        self.preWeekLabel.alpha = 1.0
                        self.curWeekLabel.alpha = 0.0
                        self.curWeekLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
                    },
                    completion: {
                        (finished: Bool) -> Void in
                        self.nextWeekLabel.text = self.curWeekLabel.text
                        self.curWeekLabel.text = self.preWeekLabel.text
                        self.curWeekLabel.transform = CGAffineTransformIdentity
                        self.curWeekLabel.alpha = 1.0
                        self.preWeekLabel.alpha = 0.0
                        self.preWeekLabel.layer.position.x = self.previousBtn.layer.position.x
                        self.nextBtn.enabled = true
                    }
                )
            } else if percentage < -0.5 && self.nextBtn.enabled == true {
                nextWeekLabel.center.x = nextBtn.center.x + percentage * distanceForLabel
                self.curDate = NSDate(timeInterval: intervalOfWeek, sinceDate: self.curDate)
                self.weeksDates.preWeek = self.weeksDates.curWeek
                loadDataForWeeks(curDate, preLoad: .Next)
                self.volumeChart.animateReversal(0.5)
                
                self.volumeChart.setDataWithAnimation(self.weeksDates.curWeek.0, animationDurtion: 1.0, delay: 0.5)
                self.clockView.setData(self.weeksDates.curWeek.1)
                self.clockView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                UIView.animateWithDuration(
                    1,
                    animations: { () -> Void in
                        self.nextWeekLabel.layer.position.x = self.curWeekLabel.layer.position.x
                        self.nextWeekLabel.alpha = 1.0
                        self.curWeekLabel.alpha = 0.0
                        self.curWeekLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
                    },
                    completion: {
                        (finished: Bool) -> Void in
                        self.preWeekLabel.text = self.curWeekLabel.text
                        self.curWeekLabel.text = self.nextWeekLabel.text
                        self.curWeekLabel.transform = CGAffineTransformIdentity
                        self.curWeekLabel.alpha = 1.0
                        self.nextWeekLabel.alpha = 0.0
                        self.nextWeekLabel.layer.position.x = self.nextBtn.layer.position.x
                        self.previousBtn.enabled = true
                    }
                )
            } else {
                self.volumeChart.animate(0.5)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.preWeekLabel.layer.position.x = self.previousBtn.layer.position.x
                    self.preWeekLabel.alpha = 0.0
                    self.nextWeekLabel.layer.position.x = self.nextBtn.layer.position.x
                    self.nextWeekLabel.alpha = 0.0
                    self.curWeekLabel.transform = CGAffineTransformIdentity
                    self.curWeekLabel.alpha = 1.0
                })
            }
        default:
            break
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getRandomDataForVolumeChart() -> [(Int, Int)] {
        let barDatas = [
            (random() % 3000, 1),
            (random() % 3000, 1),
            (random() % 3000, 1),
            (random() % 1000, 1),
            (random() % 3000, 1),
            (random() % 3000, 1),
            (random() % 2000, 1)
        ]
        return barDatas
    }
    @IBAction func dismisBtnTap(sender: UIButton) {
        if let presenting = self.presentingViewController {
            sender.enabled = false
            UIView.animateWithDuration(
                0.5,
                //delay: durationHalf,
                //options: UIViewAnimationOptions.CurveLinear,
                animations: {
                    () -> Void in
                    self.clearDatas(true)
                    sender.alpha = 0.0
                },
                completion: {
                    (finished: Bool) -> Void in
                    presenting.dismissViewControllerAnimated(true, completion: nil)
                }
            )
        } else {
            //initializeDatas(false)
            //clearDatas(true)
            let barDatas = getRandomDataForVolumeChart()
            //volumeChart.setData(barDatas)
            volumeChart.setDateWithAnimation(barDatas, animationDurtion: 1.0)
        }
    }
    // MARK: datasource and delegate
    func ChartViewControllerAtIndex(index: Int) -> ChartViewController? {
        if index >= self.dataStore.count {
            return nil
        }
        let chartViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ChartViewController") as! ChartViewController
        chartViewController.dataIndex = index
        chartViewController.setChartDatas(self.dataStore[index])
        return chartViewController
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ChartViewController
        let index = VC.dataIndex - 1
        
        return self.ChartViewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ChartViewController
        let index = VC.dataIndex - 1
        if index < 0 {
            return nil
        }
        
        return self.ChartViewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        /*
        if completed {
            let tempVC = self.curChartViewController
            let intervalOfWeek = NSTimeInterval(24 * 3600 * 7)
            if self.otherChartViewController!.loadState == .Previous {
                self.curDate = NSDate(timeInterval: -intervalOfWeek, sinceDate: self.curDate)
                self.weeksDates.nextWeek = self.weeksDates.curWeek
                loadDataForWeeks(curDate, preLoad: .Previous)
                self.curChartViewController = self.otherChartViewController!
                self.otherChartViewController = tempVC
            } else if self.otherChartViewController!.loadState == .Next {
                self.curDate = NSDate(timeInterval: intervalOfWeek, sinceDate: self.curDate)
                self.weeksDates.preWeek = self.weeksDates.curWeek
                loadDataForWeeks(curDate, preLoad: .Next)
                self.curChartViewController = self.otherChartViewController!
                self.otherChartViewController = tempVC
            }
        }
        */
    }

}
