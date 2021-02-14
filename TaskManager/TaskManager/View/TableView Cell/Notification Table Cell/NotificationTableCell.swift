//
//  NotificationTableCell.swift
//  TaskManager
//
//  Created by Hima on R 2/02/07.
//  Copyright © Reiwa 2 Hima. All rights reserved.
//

import UIKit

class NotificationTableCell: UITableViewCell {

    ///UILabel show  Time
    @IBOutlet var lblTime: UILabel!

    ///UILabel show  Title
    @IBOutlet var lblTitle: UILabel!

    ///Description label
    @IBOutlet var lblDesc: UILabel!

    ///Task type title label
    @IBOutlet var lblTaskType: UILabel!

    /// Line UIView
    @IBOutlet var vwLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
