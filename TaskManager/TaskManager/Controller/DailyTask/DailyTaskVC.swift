//
//  DailyTaskVC.swift
//  TaskManager
//
//  Created by Hima on 17/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//


import UIKit
import GoogleMobileAds

/**
This controller is written to check Daily Task

- Author: Hima Seta
- Date: January 17, 2020
*/


class DailyTaskVC: UIViewController,UITextFieldDelegate {

    // MARK: - UI properties
    
    ///UIView to add header
    @IBOutlet var viewHeader : UIView!

    ///UILabel to show no task
    @IBOutlet var lblDailyStatus: UILabel!

    ///UILabel to show no task
    @IBOutlet var lblNoTask: UILabel!
    
    ///UITableView to show Today's Task
    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var progressBarViewDone: ProgressBarView!
    @IBOutlet weak var progressBarViewTodo: ProgressBarView!
    @IBOutlet weak var progressBarViewInProgress: ProgressBarView!
    
    ///CircularProgressBar to show progress of status
    //@IBOutlet weak var progressBarDone: CircularProgressBar!
    
    ///CircularProgressBar to show progress of status
    //@IBOutlet weak var progressBarTodo: CircularProgressBar!
    
    ///CircularProgressBar to show progress of status
    //@IBOutlet weak var progressBarInProgress: CircularProgressBar!
    
    ///NSLayoutConstraint to set table height upto content size
    @IBOutlet weak var constraintTableViewHeight : NSLayoutConstraint!
    
    ///UIView inside scroll view
    @IBOutlet weak var viewInsideScroll : UIView!
    
    ///UIScrollView main scroll view
    @IBOutlet weak var scrollViewMain  : UIScrollView!
    
    ///UIView Floating menu view meeting
    @IBOutlet weak var viewFloatingMeeting : UIView!
    
    ///UIView Floating menu view Reminder
    @IBOutlet weak var viewFloatingReminder : UIView!
    
    ///UIView Floating menu view Task
    @IBOutlet weak var viewFloatingTask : UIView!
    
    ///UIView Floating BlurBG
    @IBOutlet weak var viewFloatingBlurBG : UIView!
    
    ///Completed Hours main view
    @IBOutlet weak var viewCompletedHours : UIView!
    
    ///Completed Hours sub view
    @IBOutlet weak var viewCompletedHoursIn : UIView!
    
    var taskDetailForCompletedHR = TaskModel()
    
    
    ///NSLayoutConstraint to set view bottom
    @IBOutlet weak var constraintViewFloatingMeetingBottom : NSLayoutConstraint!
    @IBOutlet weak var constraintViewFloatingReminderBottom : NSLayoutConstraint!
    @IBOutlet weak var constraintViewFloatingTaskBottom : NSLayoutConstraint!
    
    ///DailyTaskListModel local variable
    var objcDailyTaskListModel = DailyTaskListModel()
    
    /// Array of Tasks
    var arrTasks = [TaskModel]()
    
    var floatPending : Float = 0.0
    var floatInProgress: Float = 0.0
    var floatDone: Float = 0.0
    
    @IBOutlet weak var lblTotalTask: UILabel!
    
    @IBOutlet weak var lblDoneTasks: UILabel!
    @IBOutlet weak var lblPendingTasks: UILabel!
    @IBOutlet weak var lblInProgressTasks: UILabel!
    
    ///UIButoon buttonMenu
    @IBOutlet weak var viewFloating : UIView!
    
    @IBOutlet weak var txtFTotalHours : UITextField!
    
    /// Google banner ad
    var bannerView: GADBannerView!
    @IBOutlet var vwGoogleAd: UIView!

    /// Timer to load full screen advertiesment
    var adsTimer = Timer()

    //MARK: - view load methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBlurBG(_:)))
        viewFloatingBlurBG.addGestureRecognizer(tap)
        
        let tapCompleted = UITapGestureRecognizer(target: self, action: #selector(self.handleTapCompletedHours(_:)))
               viewCompletedHours.addGestureRecognizer(tapCompleted)

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProgress), name: NSNotification.Name(rawValue: "ProgressViewReload"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(completedHoursClick(_:)), name: NSNotification.Name(rawValue: "completedHoursClick"), object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        viewFloatingInitialPositions()
        reloadApps()
        initialization()

        if AppDelegate.sharedInstance.isPurchased {
            vwGoogleAd.isHidden = true
        } else {
            vwGoogleAd.isHidden = false
            setupGAD()
        }
    }

    func initialization() {
        //UIColor(red: 240.0/255.0, green: 243.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        progressBarViewDone.setProgressColor(color: UIColor.MyTheme.progressDoneColor)
        progressBarViewDone.setBackColor(color: UIColor(red: 240.0/255.0, green: 243.0/255.0, blue: 249.0/255.0, alpha: 1.0))

        progressBarViewTodo.setProgressColor(color: UIColor.MyTheme.progressPendingColor)
        progressBarViewTodo.setBackColor(color: UIColor(red: 240.0/255.0, green: 243.0/255.0, blue: 249.0/255.0, alpha: 1.0))

        progressBarViewInProgress.setProgressColor(color: UIColor.MyTheme.progressInProgressColor)
        progressBarViewInProgress.setBackColor(color: UIColor(red: 240.0/255.0, green: 243.0/255.0, blue: 249.0/255.0, alpha: 1.0))

        lblDailyStatus.text = Date().toString(dateFormat: DTaskdateFormatFull)

        txtFTotalHours.delegate = self
        txtFTotalHours.addInputViewDatePicker(target: self, selector: #selector(TotalTimeDoneClicked), mode: .countDownTimer, isFromPDFView: false)
        
       
        
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
    
    // MARK: - Reload Contact list tableview
    func reloadApps() {
        
        self.tableView.delegate = self.objcDailyTaskListModel
        self.tableView.dataSource = self.objcDailyTaskListModel
        
        let allTaskWithProgress  = DBManager.sharedInstance.selectTodaysTaskList(sortBy: 0)
        arrTasks = allTaskWithProgress.0
        
        floatPending = Float(allTaskWithProgress.1)
        floatDone = Float(allTaskWithProgress.2)
        floatInProgress = Float(allTaskWithProgress.3)
        
        // let largest : Float = max(floatPending, floatDone, floatInProgress)
        let largest : Float = Float(arrTasks.count)
        print(largest)

        perform(#selector(startLoadingCircle), with: NSNumber.init(value: largest), afterDelay: 1.0)
        self.objcDailyTaskListModel.reloadList(arrList: arrTasks, tableView: self.tableView, footerHeight: 10.0)
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

    @objc func reloadProgress() {
        reloadApps()
    }
    
    @objc func completedHoursClick(_ notification: NSNotification) {
        
        if let taskDetail = notification.userInfo?["Task"] as? TaskModel {
        
            self.taskDetailForCompletedHR = taskDetail
        }
        
        txtFTotalHours.text = CommonFunctions.getDifferenceTotalTimeInMinutes(from: String().convertDateFormatter(dateStr: (taskDetailForCompletedHR.Start_Time as String), timeFormat: DFullTimeFormat), EndTime: String().convertDateFormatter(dateStr: (taskDetailForCompletedHR.End_Time as String), timeFormat: DFullTimeFormat))
        
        let datePickerTotalTime : UIDatePicker = txtFTotalHours.inputView as! UIDatePicker
        datePickerTotalTime.setDate(from: txtFTotalHours.text!,format: DFullTimeFormat)
        
         self.showViewCompletedHours(isHide: false)
        
       }
    
    //MARK: - Start Loading
    @objc func startLoadingCircle(num : NSNumber) {

        let totalValue = floatInProgress+floatPending+floatDone
        lblTotalTask.text = "\(Int(totalValue))"

        if(Int(totalValue) > 0)
        {
            let percentage = 100 / Int(num)
            /*lblDoneTasks.text =  String(format: "%.2f", (floatDone * 100)/num.floatValue) + "%"
            lblInProgressTasks.text =  String(format: "%.2f", (floatInProgress * 100)/num.floatValue) + "%"
            lblPendingTasks.text =  String(format: "%.2f", (floatPending * 100)/num.floatValue) + "%"*/

            lblDoneTasks.text =  "\(Int(floatDone))"
            lblInProgressTasks.text =  "\(Int(floatInProgress))"
            lblPendingTasks.text =  "\(Int(floatPending))"

            if(floatInProgress > 0.0) {
                let floatInProgressVal = Double(floatInProgress * 100.0/Float(Int(num)))

                progressBarViewInProgress.setProgressValue(currentValue: CGFloat(floatInProgressVal))
            } else {
                progressBarViewInProgress.setProgressValue(currentValue: 0.0)
            }

            if(floatPending > 0.0) {
                let floatPendingVal = Double(floatPending * 100.0/Float(Int(num)))
                progressBarViewTodo.setProgressValue(currentValue: CGFloat(floatPendingVal))
            } else {
                progressBarViewTodo.setProgressValue(currentValue: 0.0)
            }

            if(floatDone > 0.0) {
                let floatDoneVal = Double(floatDone * 100.0/Float(Int(num)))
                progressBarViewDone.setProgressValue(currentValue: CGFloat(floatDoneVal))
            } else {
                progressBarViewDone.setProgressValue(currentValue: 0.0)
            }
        }
        else{
            lblDoneTasks.text =  "\(Int(0))" + "%"
            lblInProgressTasks.text =  "\(Int(0))" + "%"
            lblPendingTasks.text =  "\(Int(0))" + "%"

            progressBarViewTodo.setProgressValue(currentValue: 0.0)
            progressBarViewDone.setProgressValue(currentValue: 0.0)
            progressBarViewInProgress.setProgressValue(currentValue: 0.0)
        }
    }
    
    // MARK: - UIView Animations for Floating Button
    
    func viewFloatingInitialPositions() {
        viewFloatingBlurBG.isHidden = true
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewFloatingBlurBG.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewFloatingBlurBG.insertSubview(blurEffectView, at: 0)
        
        constraintViewFloatingTaskBottom.constant = -40
        constraintViewFloatingMeetingBottom.constant = -40
        constraintViewFloatingReminderBottom.constant = -40
        self.viewFloating.transform = CGAffineTransform(rotationAngle: 0.0)
        
    }
    
    
    func showFloatingView(isShow: Bool) {
        if isShow {
            UIView.animate(withDuration: 0.3, animations: {
                //self.viewFloating.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2/2))
                self.viewFloatingBlurBG.alpha = 1.0
            }, completion: { (_) -> Void in

            })
            
            constraintViewFloatingTaskBottom.constant = 20
            constraintViewFloatingMeetingBottom.constant = 20
            constraintViewFloatingReminderBottom.constant = 20

           

            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {

                self.viewFloatingBlurBG.layoutIfNeeded()
            }) { _ in

            }
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
               //self.viewFloating.transform = CGAffineTransform(rotationAngle: 0.0)
                self.viewFloatingBlurBG.alpha = 0.0
            }, completion: { (_) -> Void in
                self.viewFloatingBlurBG.isHidden = true
            })

            constraintViewFloatingTaskBottom.constant = -40
                       constraintViewFloatingMeetingBottom.constant = -40
                       constraintViewFloatingReminderBottom.constant = -40

            UIView.animate(withDuration: 0.5, animations: {
                self.viewFloatingBlurBG.layoutIfNeeded()
            }, completion: { (_) -> Void in
            })
        }
    }
    
    func showViewCompletedHours(isHide: Bool)
    {
        viewCompletedHours.isHidden = isHide
        if(isHide)
        {
            viewFloating.isHidden = false
        }
        else
        {
            viewFloating.isHidden = true
        }
//        UIView.animate(withDuration: 1) {
//            if(isShow)
//            {self.viewCompletedHours.isHidden = isShow
//              //  self.viewCompletedHours.alpha = 1.0
//            }
//            else
//            {
//               // self.viewCompletedHours.alpha = 0
//            }
       // }
    }
    
   
    // MARK: - Button Clicks
    
    @IBAction func btnFloatingClicked()
    {
       if(viewFloatingBlurBG.isHidden)
      {
          viewFloatingBlurBG.isHidden = false
          viewFloatingBlurBG.alpha = 0.0
          showFloatingView(isShow: true)
         // viewFloatingOpenPositions()
      }
      else
      {
          viewFloatingBlurBG.alpha = 1.0
          showFloatingView(isShow: false)
      }
    }
    @IBAction func btnAddTaskClicked()
    {
        redirectAddTaskClass(type: .Task)
    }

    @IBAction func btnMeetingClicked()
    {
        redirectAddTaskClass(type: .Meeting)
    }

    @IBAction func btnReminderClicked()
    {
        redirectAddTaskClass(type: .Reminder)
    }

    func redirectAddTaskClass(type : TaskTypeEnum)
    {
        let vc = UIStoryboard(name: "AddTaskVC", bundle: nil).instantiateViewController(withIdentifier: "AddTaskVC") as? AddTaskVC

        vc?.currentTaskType = type

        AppDelegate.sharedInstance.navigationController?.pushViewController(vc!, animated: true)
    }
       
    @objc func handleTapBlurBG(_ sender: UITapGestureRecognizer? = nil) {

        viewFloatingBlurBG.alpha = 1.0
        showFloatingView(isShow: false)
    }
    
    @objc func handleTapCompletedHours(_ sender: UITapGestureRecognizer? = nil) {

           showViewCompletedHours(isHide: true)
       }
    
    @IBAction func btnCloseCompletedTotalHoursView()
    {
        showViewCompletedHours(isHide: true)
    }
    
    @IBAction func btnAddCompletedTotalHours()
    {
        let totalHours = txtFTotalHours.text!
        self.taskDetailForCompletedHR.TotalTaskHours = totalHours as NSString
        
        DBManager.sharedInstance.UpdateTaskOfID(taskDetail: self.taskDetailForCompletedHR, taskID: self.taskDetailForCompletedHR.ID)
        
        reloadApps()
        showViewCompletedHours(isHide: true)
        reloadProgress()
    }
    
    @objc func TotalTimeDoneClicked() {
        if let  datePicker = txtFTotalHours.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let time = Date().getStringTimeFromDate(date: datePicker.date)
           
            txtFTotalHours.text = time
        }
        txtFTotalHours.resignFirstResponder()
    }

    // MARK: - UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
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
extension DailyTaskVC: GADBannerViewDelegate {
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
