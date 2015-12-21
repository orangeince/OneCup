//
//  ChartViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/20.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    
    @IBOutlet weak var dailyVolumeView: OIBarChartView!
    @IBOutlet weak var clockView: OIClockView!
    
    enum RecordsLoadState {
        case Previous
        case Current
        case Next
    }
    var loadState:RecordsLoadState = .Current
    var dataIndex: Int = 0
    
    var datas:([(Int, Int)], [(Int, Int, Int)]) = ([], [])
    override func viewDidLoad() {
        super.viewDidLoad()
        dailyVolumeView.setData(datas.0)
        clockView.setData(datas.1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setChartDatas(datas: ([(Int, Int)], [(Int, Int, Int)])) {
        self.dailyVolumeView.setData(datas.0)
        self.clockView.setData(datas.1)
    }

}
