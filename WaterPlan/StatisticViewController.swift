//
//  StatisticViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/5.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController {

    @IBOutlet weak var clockView: OIClockView!
    @IBOutlet weak var volumeChart: OIBarChartView!
    var referenceIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
        
        self.volumeChart.layer.cornerRadius = 8
        self.volumeChart.layer.masksToBounds = true
        self.volumeChart.fillColor = self.volumeChart.tintColor!
        self.volumeChart.strokeColor = UIColor.blackColor()
        self.volumeChart.barLabelColor = UIColor.blackColor()
        self.clockView.dataFillColor = self.clockView.tintColor!
        self.clockView.fillColor = UIColor.whiteColor()
        self.clockView.strokeColor = UIColor.blackColor()
        self.clockView.scaleColor = UIColor.blackColor()
        //self.volumeChart.ba
        //self.volumeChart.
        let barLabels = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        volumeChart.setBarLabels(barLabels)
        
        let gesture = UIPanGestureRecognizer(target: self, action: "draggingToNextRecord:")
        gesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(gesture)
        initializeDatas(false)
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
        case .Ended:
            let translation = gesture.translationInView(self.view)
            let percentage = translation.x / CGRectGetWidth(self.view.bounds)
            if percentage > 0.5 {
                self.volumeChart.animateReversal(0.5)
                let newData = getRandomDataForVolumeChart()
                self.volumeChart.setDataWithAnimation(newData, animationDurtion: 1.0, delay: 0.5)
            } else {
                self.volumeChart.animate(0.5)
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

}
