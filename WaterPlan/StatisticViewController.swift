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

    weak var clockView: OIClockView!
    weak var volumeChart: OIBarChartView!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var curWeekLabel: UILabel!
    @IBOutlet weak var separateView: UIView!
    @IBOutlet weak var dismissBtn: UIButton!
    
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
    
    var pageViewController: UIPageViewController?
    
    var dataStore = [([(Int, Int)], [(Int, Int, Int)], String)]()
    var dataTitles = [String]()
    var loadedAllDatas = false
    
    enum TurnDirection {
        case Previous
        case Next
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
        //self.dismissBtn.layer.cornerRadius = self.dismissBtn.frame.height / 2.0
        //self.dismissBtn.layer.masksToBounds = true
        //self.dismissBtn.layer.borderWidth = 1.0
        self.dismissBtn.layer.borderColor = self.dismissBtn.tintColor.CGColor
        
        initializeData()
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        let startViewController = ChartViewControllerAtIndex(0)!
        pageViewController!.setViewControllers([startViewController], direction: .Forward, animated: false, completion: nil)
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        let marginTop = self.separateView.frame.origin.y + self.separateView.frame.height//
        let marginBottom = CGFloat(self.dismissBtn.frame.height + 10.0)
        self.pageViewController!.view.frame = CGRectMake(0, marginTop, self.view.bounds.width, self.view.bounds.height - marginTop - marginBottom)
        //self.pageViewController!.view.frame = CGRectOffset(CGRectInset(pageViewRect, 0, (marginTop + marginBottom) / 2.0), 0, marginBottom / 2.0)
        self.pageViewController!.didMoveToParentViewController(self)
        
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        self.volumeChart = startViewController.dailyVolumeView
        self.clockView = startViewController.clockView
        
    }
    func initializeData() {
        let firstRecordRequest = NSFetchRequest(entityName: "RecordDaily")
        let sortDate = NSSortDescriptor(key: "date", ascending: true)
        firstRecordRequest.sortDescriptors = [sortDate]
        firstRecordRequest.fetchLimit = 1
        do {
            let firstRecord = try self.managedObjectContext.executeFetchRequest(firstRecordRequest) as! [RecordDaily]
            if firstRecord.count == 0 { //没有一条记录
                self.dataStore = [([], [], "本周")]
                self.loadedAllDatas = true
                return
            }
            self.firstRecord = firstRecord[0]
            let firstRecordDate = self.firstRecord!.date!
            
            let calendar = NSCalendar.currentCalendar()
            calendar.firstWeekday = 2
            var beginningOfWeek: NSDate?
            calendar.rangeOfUnit(.WeekOfYear, startDate: &beginningOfWeek, interval: nil, forDate: firstRecordDate)
            self.firstRecordDate = beginningOfWeek
            
            var curWeekDatas = self.loadDataForTheWeek(self.curDate)
            curWeekDatas.2 = "本周"
            self.dataStore.append(curWeekDatas)
            prepareForPreviousWeekDatas()
            if self.dataStore.count > 1 {
                self.previousBtn.enabled = true
            }
            
        } catch {
            fatalError("Failed to initailize firstRecord: \(error)")
        }
    }
    func getTwoDigitNumber(num: Int) -> String {
        return num < 10 ? "0" + String(num) : String(num)
    }
    func prepareForPreviousWeekDatas() {
        self.curDate = NSDate(timeInterval: NSTimeInterval(-7 * 24 * 3600), sinceDate: self.curDate)
        let calendar = NSCalendar.currentCalendar()
        
        let comparison = calendar.compareDate(self.curDate,toDate: firstRecordDate, toUnitGranularity: .Day)
        if comparison == .OrderedAscending {
            self.loadedAllDatas = true
        } else {
            let datas = loadDataForTheWeek(self.curDate)
            self.dataStore.append(datas)
        }
    }
    func loadDataForTheWeek(theDay: NSDate) -> ([(Int, Int)],[(Int, Int, Int)], String) {
        var dailyDatas = [(Int, Int)](count: 7, repeatedValue: (0, 0))
        var detailDatas = [(Int, Int, Int)]()
        var dataTitle = ""
        
        var startDate: NSDate?
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = 2
        calendar.rangeOfUnit(.WeekOfYear, startDate: &startDate, interval: nil, forDate: theDay)
        let endDate = NSDate(timeInterval: NSTimeInterval(7 * 24 * 3600 - 1), sinceDate: startDate!)
        let startComp = calendar.components([.Month, .Day], fromDate: startDate!)
        let endComp = calendar.components([.Month, .Day], fromDate: endDate)
        dataTitle = getTwoDigitNumber(startComp.month) + "." + getTwoDigitNumber(startComp.day) + " - " + getTwoDigitNumber(endComp.month) + "." + getTwoDigitNumber(endComp.day)
        
        let dailyRequest = NSFetchRequest(entityName: "RecordDaily")
        dailyRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate!, endDate)
        
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
            return (dailyDatas, detailDatas, dataTitle)
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
            let datas = self.dataStore[0]
            
            volumeChart.setData(datas.0)
            clockView.setData(datas.1)
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
        } else if index == self.dataStore.count - 1 && !self.loadedAllDatas {
            prepareForPreviousWeekDatas()
        }
        let chartViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ChartViewController") as! ChartViewController
        chartViewController.dataIndex = index
        chartViewController.setChartDatas(self.dataStore[index])
        return chartViewController
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ChartViewController
        let index = VC.dataIndex - 1
        if index < 0 {
            return nil
        }
        
        return self.ChartViewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ChartViewController
        let index = VC.dataIndex + 1
        
        return self.ChartViewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let curVC = pageViewController.viewControllers![0] as? ChartViewController {
                self.curWeekLabel.text = curVC.topTitle
                let curIndex = curVC.dataIndex
                if curIndex == 0 {
                    nextBtn.enabled = false
                } else {
                    nextBtn.enabled = true
                }
                if curIndex == self.dataStore.count - 1 {
                    self.previousBtn.enabled = false
                } else {
                    self.previousBtn.enabled = true
                }
                self.volumeChart = curVC.dailyVolumeView
                self.clockView = curVC.clockView
            }
        }
    }

    @IBAction func previousBtnTap(sender: UIButton) {
        turnTheChartTo(.Previous)
    }
    @IBAction func nextBtnTap(sender: UIButton) {
        turnTheChartTo(.Next)
    }
    func turnTheChartTo(to: TurnDirection) {
        if let curChart = self.pageViewController!.viewControllers![0] as? ChartViewController {
            var index = curChart.dataIndex
            let direction: UIPageViewControllerNavigationDirection
            switch to {
            case .Previous:
                index += 1
                direction = .Reverse
            case .Next:
                index -= 1
                direction = .Forward
            }
            if index < 0 {
                return
            }
            if let theChart = self.ChartViewControllerAtIndex(index) {
                self.pageViewController!.setViewControllers(
                    [theChart],
                    direction: direction,
                    animated: true,
                    completion: {
                        (finished: Bool) -> Void in
                        if finished {
                            self.curWeekLabel.text = theChart.topTitle
                            if index == 0 {
                                self.nextBtn.enabled = false
                            } else {
                                self.nextBtn.enabled = true
                            }
                            if index == self.dataStore.count - 1 {
                                self.previousBtn.enabled = false
                            } else {
                                self.previousBtn.enabled = true
                            }
                            self.volumeChart = theChart.dailyVolumeView
                            self.clockView = theChart.clockView
                        }
                    }
                )
            }
            //self.pageViewController!.navigationController!.
        }
    }
}
