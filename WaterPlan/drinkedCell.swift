//
//  drinkedCell.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/2.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class drinkedCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
