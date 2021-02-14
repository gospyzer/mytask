//
//  DateCalendarVC.swift
//  TaskManager
//
//  Created by Hima on 17/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit
import FSCalendar
//import EMTNeumorphicView
import GoogleMobileAds

/**
 This controller is written to select date from Calendar controller
 */

class DateCalendarVC: UIViewController {

    // MARK: - UI properties

    ///Header view
    @IBOutlet var viewHeader: UIView!
    
    ///UIView inside scroll view
    @IBOutlet weak var viewInsideScroll : UIView!

    ///UIScrollView main scroll view
    @IBOutlet weak var scrollViewMain  : UIScrollView!

    ///UILabel to show no task
    @IBOutlet var lblNoTask: UILabel!

    ///UILabel to display title
    @IBOutlet var lblTitle: UILabel!

    /// Calendar button on top view
    @IBOutlet weak var btnCalendar: UIButton!
    
    ///UITableView to show Today's Task
    @IBOutlet var tableView: UITableView!
    
    ///NSLayoutConstraint to set table height upto content size
    @IBOutlet weak var constraintTableViewHeight : NSLayoutConstraint!
    
    /// FSCalendar to set Calendar control
    @IBOutlet var calendar: FSCalendar!
    
    var arrAllAddedTasksInDB = [TaskModel]()
    
    
    ///DailyTaskListModel local variable
    var objcHistoryTaskListModel = DailyTaskListModel()
    
    var floatPending : Float = 0.0
    var floatInProgress: Float = 0.0
    var floatDone: Float = 0.0
    
    var arrTasks = [TaskModel]()
    
    var strSelectedDateCalendar : String = Date().toString(dateFormat: DDBSmallDateFormat)

    ///Calendar view height constraint
    @IBOutlet weak var vwCalendarHeightConstraint : NSLayoutConstraint!

    /// Google banner ad
    var bannerView: GADBannerView!
    @IBOutlet var vwGoogleAd: UIView!
    

    //MARK: - view load methods
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = Date().toString(dateFormat: DTaskdateFormatFull)

        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProgress), name: NSNotification.Name(rawValue: "ProgressViewReload"), object: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        /// Default setting for calendar view
        btnCalendar.tag = 0
        vwCalendarHeightConstraint.constant = 273.0
        calendar.scope = .month

        reloadApps()

        if AppDelegate.sharedInstance.isPurchased {
            vwGoogleAd.isHidden = true
        } else {
            vwGoogleAd.isHidden = false
            setupGAD()
        }
    }
    
    func reloadApps() {

        self.tableView.delegate = self.objcHistoryTaskListModel
        self.tableView.dataSource = self.objcHistoryTaskListModel

        arrAllAddedTasksInDB = DBManager.sharedInstance.selectAllTasksFromTable()
        
        let allTaskWithProgress  = DBManager.sharedInstance.selectTaskListOfSelectedDate(sortBy: 0, strDate:strSelectedDateCalendar)

        arrTasks = allTaskWithProgress.0

        floatPending = Float(allTaskWithProgress.1)
        floatDone = Float(allTaskWithProgress.2)
        floatInProgress = Float(allTaskWithProgress.3)

        self.objcHistoryTaskListModel.reloadList(arrList: arrTasks, tableView: self.tableView, footerHeight: 0.0)

        calendar.reloadData()

        checkNoTask()
    }

    func checkNoTask() {
        if arrTasks.count == 0 {
            lblNoTask.isHidden = false
        }
        else {
            lblNoTask.isHidden = true
        }
    }
    
    @objc func reloadProgress()
    {
        reloadApps()
    }

    // MARK: - Setup ADMob full ad

    func setupGAD() {
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = bannerAdID
        bannerView.rootViewController = self
        bannerView.delegate = self
        vwGoogleAd.addSubview(bannerView)
        bannerView.load(GADRequest())
    }

    @IBAction func goCalendar(_ sender: UIButton) {
        if btnCalendar.tag == 0 {
            btnCalendar.tag = 1
            vwCalendarHeightConstraint.constant = 130.0
            calendar.scope = .week
            calendar.layoutIfNeeded()
        }
        else{
            btnCalendar.tag = 0
            vwCalendarHeightConstraint.constant = 273.0
            calendar.scope = .month
        }
    }

    //MARK:- TableView Observer Method

    /* This function written to set table height according to content
     - Author: Hima Seta
     - Date: January 23, 2020
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let obj = object as? UITableView {

            if obj == self.tableView && keyPath == "contentSize" {

                constraintTableViewHeight.constant = tableView.contentSize.height

                self.tableView.layoutIfNeeded()
                self.view.layoutIfNeeded()

            }
        }
    }
}

extension DateCalendarVC: FSCalendarDataSource, FSCalendarDelegate
{
    // MARK: Calander Delegate and DataSource Method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        strSelectedDateCalendar = date.toString(dateFormat: DDBSmallDateFormat)
        lblTitle.text = date.toString(dateFormat: DTaskdateFormatFull)
        reloadApps()
    }
    
    func calendar(_: FSCalendar, numberOfEventsFor date: Date) -> Int
    {
        let items = arrAllAddedTasksInDB.filter { $0.Task_Date.isEqual(to: date.toString(dateFormat: DDBSmallDateFormat))
            
            // taskObj.Task_Type as String == TaskTypeEnum.Meeting.rawValue
        }
        //        let eventsNum = items.filter { (taskObj) -> Bool in
        //             taskObj.Task_Type as String == TaskTypeEnum.Meeting.rawValue
        //
        //        }

        print(date.toString(dateFormat: DTaskdateFormat), items.count )
        return items.count
    }
}

extension DateCalendarVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_: GADBannerView) {
        print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_: GADBannerView) {
        print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_: GADBannerView) {
        print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_: GADBannerView) {
        print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
