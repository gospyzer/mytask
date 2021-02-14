//
//  NotificationsVC.swift
//  TaskManager
//
//  Created by Hima on 17/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit


/**
This controller is written to check Notifications

- Author: Hima Seta
- Date: January 17, 2020
*/

class NotificationsVC: UIViewController {

    // MARK: - UI properties
    
    ///CustomHeaderView is UIView to add header
    @IBOutlet var viewHeader : CustomHeaderView!
    
    ///NotificationListModel local variable
    var objcNotiListModel = NotificationListModel()
    
    ///UITableView to show Noti
    @IBOutlet var tableView: UITableView!
    
    /// Array of Tasks
    var arrNotifications = [TaskModel]()

    // MARK: - Life Cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHeader?.lblTitle?.text = "Notifications"
        viewHeader?.setCeneterTitle()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        reloadTable()
    }
    
    func reloadTable()
    {
        self.tableView.delegate = self.objcNotiListModel
        self.tableView.dataSource = self.objcNotiListModel
                   
                  
        let allTaskWithProgress  = DBManager.sharedInstance.selectMeetingReminderFromTable()
        arrNotifications = allTaskWithProgress
        
        self.objcNotiListModel.reloadNotiList(arrList: arrNotifications, tableView: self.tableView)
        
    }

   
}
