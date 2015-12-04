//
//  ReminderTableViewCell.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/10/23.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    
    var reminder = ("", "", "", 0, 0, 0, true)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
class ReminderContorlCell: UITableViewCell {
    
    @IBOutlet weak var reminderEnableSwitch: UISwitch!
    
}
