//
//  RecordModel.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/16.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit
import CoreData
//import Foundation

class RecordDetail: NSManagedObject {
    @NSManaged var date: NSDate?
    @NSManaged var volume: NSNumber?
    @NSManaged var time: NSString?
    @NSManaged var theHour: NSNumber?
    @NSManaged var theMinute: NSNumber?
    @NSManaged var theDay: RecordDaily?
}
class RecordDaily: NSManagedObject {
    @NSManaged var date: NSDate?
    @NSManaged var totalVolume: NSNumber?
    @NSManaged var weekDay: NSNumber?
    @NSManaged var details: NSSet?
}
