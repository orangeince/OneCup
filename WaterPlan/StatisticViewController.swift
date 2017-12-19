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
    var barDatas = [(Int, Int)](repeating: (0, 0), count: 7)
    var clockDatas: [(Int, Int, Int)]? //= [(Int, Int, Int)]()
    var otherClockDatas: [(Int, Int, Int)]?
    var firstRecord: RecordDaily?
    var firstRecordDate: Date!
    var rightNow = Date()
    var curDate = Date()
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
        case previous
        case next
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
        //self.dismissBtn.layer.cornerRadius = self.dismissBtn.frame.height / 2.0
        //self.dismissBtn.layer.masksToBounds = true
        //self.dismissBtn.layer.borderWidth = 1.0
        self.dismissBtn.layer.borderColor = self.dismissBtn.tintColor.cgColor
        
        initializeData()
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        let startViewController = ChartViewControllerAtIndex(0)!
        pageViewController!.setViewControllers([startViewController], direction: .forward, animated: false, completion: nil)
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        let marginTop = self.separateView.frame.origin.y + self.separateView.frame.height//
        let marginBottom = CGFloat(self.dismissBtn.frame.height + 10.0)
        self.pageViewController!.view.frame = CGRect(x: 0, y: marginTop, width: self.view.bounds.width, height: self.view.bounds.height - marginTop - marginBottom)
        //self.pageViewController!.view.frame = CGRectOffset(CGRectInset(pageViewRect, 0, (marginTop + marginBottom) / 2.0), 0, marginBottom / 2.0)
        self.pageViewController!.didMove(toParentViewController: self)
        
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        self.volumeChart = startViewController.dailyVolumeView
        self.clockView = startViewController.clockView
        
    }
    func initializeData() {
        let firstRecordRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordDaily")
        let sortDate = NSSortDescriptor(key: "date", ascending: true)
        firstRecordRequest.sortDescriptors = [sortDate]
        firstRecordRequest.fetchLimit = 1
        do {
            let firstRecord = try self.managedObjectContext.fetch(firstRecordRequest) as! [RecordDaily]
            if firstRecord.count == 0 { //没有一条记录
                self.dataStore = [([], [], "本周")]
                self.loadedAllDatas = true
                return
            }
            self.firstRecord = firstRecord[0]
            let firstRecordDate = self.firstRecord!.date!
            
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            
            //var beginningOfWeek: Date?
            //(calendar as NSCalendar).range(of: .weekOfYear, start: beginningOfWeek as! NSDate, interval: nil, for: firstRecordDate)
            // self.firstRecordDate = beginningOfWeek
            // FIXME if wrong
            self.firstRecordDate = firstRecordDate //解决error时新增一行
            
            var curWeekDatas = self.loadDataForTheWeek(self.curDate)
            curWeekDatas.2 = "本周"
            self.dataStore.append(curWeekDatas)
            prepareForPreviousWeekDatas()
            if self.dataStore.count > 1 {
                self.previousBtn.isEnabled = true
            }
            
        } catch {
            fatalError("Failed to initailize firstRecord: \(error)")
        }
    }
    func getTwoDigitNumber(_ num: Int) -> String {
        return num < 10 ? "0" + String(num) : String(num)
    }
    func prepareForPreviousWeekDatas() {
        self.curDate = Date(timeInterval: TimeInterval(-7 * 24 * 3600), since: self.curDate)
        let calendar = Calendar.current
        
        let comparison = (calendar as NSCalendar).compare(self.curDate,to: firstRecordDate, toUnitGranularity: .day)
        if comparison == .orderedAscending {
            self.loadedAllDatas = true
        } else {
            let datas = loadDataForTheWeek(self.curDate)
            self.dataStore.append(datas)
        }
    }
    func loadDataForTheWeek(_ theDay: Date) -> ([(Int, Int)],[(Int, Int, Int)], String) {
        var dailyDatas = [(Int, Int)](repeating: (0, 0), count: 7)
        var detailDatas = [(Int, Int, Int)]()
        var dataTitle = ""
        
        var startDate: Date?
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        //(calendar as NSCalendar).range(of: .weekOfYear, start: startDate as! NSDate, interval: nil, for: theDay)
        // FIXME if wrong
        startDate = theDay //解决error时新增一行
        let endDate = Date(timeInterval: TimeInterval(7 * 24 * 3600 - 1), since: startDate!)
        let startComp = (calendar as NSCalendar).components([.month, .day], from: startDate!)
        let endComp = (calendar as NSCalendar).components([.month, .day], from: endDate)
        dataTitle = getTwoDigitNumber(startComp.month!) + "." + getTwoDigitNumber(startComp.day!) + " - " + getTwoDigitNumber(endComp.month!) + "." + getTwoDigitNumber(endComp.day!)
        
        let dailyRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordDaily")
        dailyRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate! as CVarArg, endDate as CVarArg)
        
        do {
            let recordDailys = try self.managedObjectContext.fetch(dailyRequest) as! [RecordDaily]
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
    func random() -> Int {
        return Int(arc4random())
    }
    func initializeDatas(_ animatied: Bool) {
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
    func clearDatas(_ animated: Bool) {
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
    @IBAction func dismisBtnTap(_ sender: UIButton) {
        if let presenting = self.presentingViewController {
            sender.isEnabled = false
            UIView.animate(
                withDuration: 0.5,
                //delay: durationHalf,
                //options: UIViewAnimationOptions.CurveLinear,
                animations: {
                    () -> Void in
                    self.clearDatas(true)
                    sender.alpha = 0.0
                },
                completion: {
                    (finished: Bool) -> Void in
                    presenting.dismiss(animated: true, completion: nil)
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
    func ChartViewControllerAtIndex(_ index: Int) -> ChartViewController? {
        if index >= self.dataStore.count {
            return nil
        } else if index == self.dataStore.count - 1 && !self.loadedAllDatas {
            prepareForPreviousWeekDatas()
        }
        let chartViewController = self.storyboard!.instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        chartViewController.dataIndex = index
        chartViewController.setChartDatas(self.dataStore[index])
        return chartViewController
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ChartViewController
        let index = VC.dataIndex - 1
        if index < 0 {
            return nil
        }
        
        return self.ChartViewControllerAtIndex(index)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ChartViewController
        let index = VC.dataIndex + 1
        
        return self.ChartViewControllerAtIndex(index)
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let curVC = pageViewController.viewControllers![0] as? ChartViewController {
                self.curWeekLabel.text = curVC.topTitle
                let curIndex = curVC.dataIndex
                if curIndex == 0 {
                    nextBtn.isEnabled = false
                } else {
                    nextBtn.isEnabled = true
                }
                if curIndex == self.dataStore.count - 1 {
                    self.previousBtn.isEnabled = false
                } else {
                    self.previousBtn.isEnabled = true
                }
                self.volumeChart = curVC.dailyVolumeView
                self.clockView = curVC.clockView
            }
        }
    }

    @IBAction func previousBtnTap(_ sender: UIButton) {
        turnTheChartTo(.previous)
    }
    @IBAction func nextBtnTap(_ sender: UIButton) {
        turnTheChartTo(.next)
    }
    func turnTheChartTo(_ to: TurnDirection) {
        if let curChart = self.pageViewController!.viewControllers![0] as? ChartViewController {
            var index = curChart.dataIndex
            let direction: UIPageViewControllerNavigationDirection
            switch to {
            case .previous:
                index += 1
                direction = .reverse
            case .next:
                index -= 1
                direction = .forward
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
                                self.nextBtn.isEnabled = false
                            } else {
                                self.nextBtn.isEnabled = true
                            }
                            if index == self.dataStore.count - 1 {
                                self.previousBtn.isEnabled = false
                            } else {
                                self.previousBtn.isEnabled = true
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
