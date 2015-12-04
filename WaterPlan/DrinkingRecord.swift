//
//  DrinkingRecord.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/10/25.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class DrinkingRecord {
    var drinkingTime: String
    var drinkingVolume: Int
    //var bottleImage: UIImage
    
    init(drinkingTime: String, drinkingVolume: Int) {
        self.drinkingTime = drinkingTime
        self.drinkingVolume = drinkingVolume
        //self.bottleImage = bottleImage
    }
}