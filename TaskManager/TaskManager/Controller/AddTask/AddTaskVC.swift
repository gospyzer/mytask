//
//  AddTaskVC.swift
//  TaskManager
//
//  Created by Hima on 24/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit

class AddTaskVC: UIViewController,UITextFieldDelegate {

    ///UIView to add header
    @IBOutlet var viewHeader : CustomHeaderView!
    
    ///TaskTypeEnum for current Task
    var currentTaskType : TaskTypeEnum = .Task
    
    ///Int which holds Task ID
    var taskID : Int = 0
    
    ///Bool to check task type Add/Edit
    var isForEdit : Bool = false
    
    ///TaskModel for details
    var taskDetailObj : TaskModel = TaskModel()
    
    ///UIView timepicker
    @IBOutlet weak var viewTime : UIView!
    
    ///UILabel start time
    @IBOutlet weak var lblStartTime : UILabel!
    
    ///UILabel End time
    @IBOutlet weak var lblEndTime : UILabel!
    
    ///UITextField title text
    @IBOutlet weak var txtFTitle : UITextField!
    
    ///UITextField Project name text
    @IBOutlet weak var txtFProjName : UITextField!
    
    ///UITextField description text
    @IBOutlet weak var txtVDecription : UITextView!
    
    ///UITextField date text
    @IBOutlet weak var txtFDate : UITextField!
    
    ///UITextField start time text
    @IBOutlet weak var txtFStartTime : UITextField!
    
    ///UITextField end time text
    @IBOutlet weak var txtFEndTime : UITextField!
    
    ///NSLayoutConstraint title height to remove end time
    @IBOutlet weak var constViewTimeHeight : NSLayoutConstraint!
    
    ///NSLayoutConstraint project name height
    @IBOutlet weak var constViewProjNameHeight : NSLayoutConstraint!
    
    ///UIButton save button
    @IBOutlet weak var btnSave : UIButton!
    
    ///UIButton Delete button
    @IBOutlet weak var btnDelete : UIButton!

    //MARK: - view load methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("currentTaskType \(currentTaskType)")
        btnDelete.isHidden = true
        
        txtFStartTime.addInputViewDatePicker(target: self, selector: #selector(startTimeDoneClicked), mode: .time, isFromPDFView: false)
        txtFEndTime.addInputViewDatePicker(target: self, selector: #selector(endTimeDoneClicked), mode: .time, isFromPDFView: false)
        
        txtFDate.addInputViewDatePicker(target: self, selector: #selector(dateDoneClicked), mode: .date, isFromPDFView: false)
        
        self.txtFStartTime.delegate = self
        self.txtFEndTime.delegate = self
        self.txtFDate.delegate = self
        
//        let textfieldsTask : [UITextField] = [txtFTitle, txtFProjName, txtFDate, txtFStartTime,txtFEndTime]
//        let textfieldsMeeting : [UITextField] = [txtFTitle, txtFDate, txtFStartTime,txtFEndTime]
//        let textfieldsReminder : [UITextField] = [txtFTitle, txtFDate, txtFStartTime]
//
//        for textfield in textfieldsTask {
//            textfield.addTarget(self, action: Selector(("textFieldDidChange:")), for: .editingChanged)
//        }
//        for textfield in textfieldsMeeting {
//            textfield.addTarget(self, action: Selector(("textFieldDidChange:")), for: .editingChanged)
//        }
//        for textfield in textfieldsReminder {
//            textfield.addTarget(self, action: Selector(("textFieldDidChange:")), for: .editingChanged)
//        }
        
        if(isForEdit)
        {
            loadTaskToEdit()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeUIAsCurrentTask()
    }
    
    func changeUIAsCurrentTask()
    {
        switch currentTaskType {
            
        case .Task:
            
            screenUITask()
            
            break
            
        case .Meeting:
            
            screenUIMeeting()

            break

        case .Reminder:
            
            screenUIReminder()
            
            break
        default:
            screenUITask()
            break
            
        }
    }
    
    
    func screenUIReminder()
    {
        lblStartTime.text = "Set Time :"
        lblEndTime.isHidden = true
        txtFEndTime.isHidden = true
        if(isForEdit)
        {
            self.viewHeader.lblTitle.text = "Update Reminder"
        }
        else{
            self.viewHeader.lblTitle.text = "Add Reminder"
        }
        constViewProjNameHeight.constant = 0
        
    }
    func screenUIMeeting()
    {
        if(isForEdit)
        {
            self.viewHeader.lblTitle.text = "Update Meeting"
        }
        else{
            self.viewHeader.lblTitle.text = "Add Meeting"
        }
        constViewProjNameHeight.constant = 0
    }
    func screenUITask()
    {
        if(isForEdit)
        {
            self.viewHeader.lblTitle.text = "Update Task"
        }
        else{
            self.viewHeader.lblTitle.text = "Add Task"
        }
        
        constViewTimeHeight.constant = 100
    }
    
    
    /* This function written show data in all fields to edit
     - Author: Hima Seta
     - Date: January 31, 2020
     */
    
    func loadTaskToEdit()
    {
        btnDelete.isHidden = false
        let datePickerDateTime : UIDatePicker = txtFDate.inputView as! UIDatePicker
        datePickerDateTime.setDate(from: taskDetailObj.Task_Date as String, format: DDBSmallDateFormat)
        
        let datePickerStartTime : UIDatePicker = txtFStartTime.inputView as! UIDatePicker
        datePickerStartTime.setDate(from: taskDetailObj.Start_Time as String, format: DFullTimeFormat)
        
        let datePickerEndTime : UIDatePicker = txtFEndTime.inputView as! UIDatePicker
        datePickerEndTime.setDate(from: taskDetailObj.End_Time as String, format: DFullTimeFormat)
        
        txtFTitle.text = taskDetailObj.Title as String
        txtFProjName.text = taskDetailObj.Project_Name as String
        txtVDecription.text = taskDetailObj.Description as String
        txtFDate.text = taskDetailObj.Task_Date as String
        txtFStartTime.text = taskDetailObj.Start_Time as String
        txtFEndTime.text = taskDetailObj.End_Time as String
        
        btnSave.setTitle("Update", for: .normal)

    }
    
    /* This function written to set local notification of reminder
     - Author: Hima Seta
     - Date: February 20, 2020
     */
    
    func setReminderNotification()
    {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let arrReminders = DBManager.sharedInstance.selectReminderListFromTable()
        for item in arrReminders {
            // 1
            let content = UNMutableNotificationContent()
            content.title = item.Title as String
            content.body = item.Description as String
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "remind.aiff"))

            let strDate = String().getDateFromString(dateFormat: DDBSmallDateFormat, dateStr: item.Task_Date as String)

            var time: String = String().getTimeFromString(timeFormat: DFullTimeFormat, timeStr: item.Start_Time as String)
            
            if(item.Task_Type as String == TaskTypeEnum.Meeting.rawValue)
            {
                var tempDate = String().convertDateFormatter(dateStr: item.Start_Time as String, timeFormat: DFullTimeFormat)
                tempDate.addTimeInterval(TimeInterval(-15.0 * 60.0))
                let timeTemp = tempDate.toString(dateFormat: DFullTimeFormat)
                
                time = String().getTimeFromString(timeFormat: DFullTimeFormat, timeStr: timeTemp)
            }
            
            let morningOfChristmasComponents = NSDateComponents()
            morningOfChristmasComponents.day = Int(strDate.components(separatedBy: "-")[2])!
            morningOfChristmasComponents.month = Int(strDate.components(separatedBy: "-")[1])!
            morningOfChristmasComponents.year = Int(strDate.components(separatedBy: "-")[0])!
            morningOfChristmasComponents.hour = Int(time.components(separatedBy: ":")[0])!
            morningOfChristmasComponents.minute = Int(time.components(separatedBy: ":")[1])!
            morningOfChristmasComponents.second = 0

            let morningOfChristmas = NSCalendar.current.date(from: morningOfChristmasComponents as DateComponents)

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: morningOfChristmas!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: "\(item.ID)", content: content, trigger: trigger)

            // 4
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    
    
    /* This function written to Delete selected task
     - Author: Hima Seta
     - Date: February 20, 2020
     */
    func deleteThisTask()
    {
        DBManager.sharedInstance.deleteThisTask(Id: "\(taskID)")
        if(currentTaskType == TaskTypeEnum.Reminder)
        {
            removeNoificationOfDeletedReminder()
        }
    }
    
    /* This function written to remove local notification of reminder
     - Author: Hima Seta
     - Date: February 20, 2020
     */
    func removeNoificationOfDeletedReminder()
    {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(taskID)"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(taskID)"])
        
    }
    // MARK: - Validate TextField
    
    func validateTextFields() -> Bool {
        var valid:Bool = true
        
        if txtFTitle.text!.isEmpty {
            //Change the placeholder color to red for textfield email if
            txtFTitle.attributedPlaceholder = NSAttributedString(string: "Please enter Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFTitle.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if (txtFProjName.text!.isEmpty && currentTaskType == .Task)
        {
            //Change the placeholder color to red for textfield email if
            txtFProjName.attributedPlaceholder = NSAttributedString(string: "Please enter Project name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFProjName.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if txtFDate.text!.isEmpty {
            //Change the placeholder color to red for textfield email if
            txtFDate.attributedPlaceholder = NSAttributedString(string: "Please enter Date", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFDate.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if txtFStartTime.text!.isEmpty && currentTaskType != .Task {
            //Change the placeholder color to red for textfield email if
            txtFStartTime.attributedPlaceholder = NSAttributedString(string: "Please enter Time", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFStartTime.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if txtFEndTime.text!.isEmpty && currentTaskType == .Meeting {
            //Change the placeholder color to red for textfield email if
            txtFEndTime.attributedPlaceholder = NSAttributedString(string: "Please enter Time", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFEndTime.AnimationShakeTextField(textField: txtFTitle)
        }
        
        return valid
    }
    // MARK: - UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }

    
    // MARK: - Button Clicks
    
       // MARK: - Button Clicks
    
    @objc func startTimeDoneClicked() {
        if let  datePicker = txtFStartTime.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let time = Date().getStringTimeFromDate(date: datePicker.date)
            if(currentTaskType.rawValue == TaskTypeEnum.Reminder.rawValue)
            {
                txtFStartTime.text = Date().getStringTimeFromDate(date: datePicker.date)
            }
            else{
                let isValid = DBManager.sharedInstance.checkValidStartEndTime(strStartTime: time, strEndTime: "", strDate: txtFDate.text!, isStartTime: true,taskId: taskID)
                if isValid {
                    txtFStartTime.text = Date().getStringTimeFromDate(date: datePicker.date)
                }
                else {
                    CommonFunctions.showMessage(Title: "", message: "Please select valid time.")
                }
            }
            
        }
        txtFStartTime.resignFirstResponder()
    }
    
    @objc func endTimeDoneClicked() {
        if let  datePicker = txtFEndTime.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            //txtFEndTime.text = Date().getStringTimeFromDate(date: datePicker.date)

            let startTime = txtFStartTime.text?.convertDateFormatter(dateStr: txtFStartTime.text!, timeFormat: DFullTimeFormat)
            let endTime = Date().getStringTimeFromDate(date: datePicker.date)

            let isGreater = self.checkEndTimeGreater(startTime: txtFStartTime.text!, endTime: endTime)

            if isGreater {
                let isValid = DBManager.sharedInstance.checkValidStartEndTime(strStartTime: txtFStartTime.text!, strEndTime: endTime, strDate: txtFDate.text!, isStartTime: false,taskId: taskID)
                if isValid {
                    txtFEndTime.text = Date().getStringTimeFromDate(date: datePicker.date)
                }
                else {
                    CommonFunctions.showMessage(Title: "", message: "Please select valid time.")
                }
            }
        }
        txtFEndTime.resignFirstResponder()
    }

    func checkEndTimeGreater(startTime: String, endTime: String) -> Bool {
        var isGreater = true

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateIn = formatter.date(from: startTime)
        let dateOut = formatter.date(from: endTime)

        let result: ComparisonResult = (dateIn?.compare(dateOut!))!
        if result == .orderedDescending || result == .orderedSame {
            print("date2 is later than date1")
            CommonFunctions.showMessage(Title: "", message: "End time must be greater than Start time!")
            isGreater = false
        }
        return isGreater
    }
    
    @objc func dateDoneClicked() {
        if let  datePicker = txtFDate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            txtFDate.text = datePicker.date.toString(dateFormat: DDBSmallDateFormat)
        }
        txtFDate.resignFirstResponder()
    }
    @IBAction func btnSaveClicked()
    {
        let isNotEmpty : Bool = validateTextFields()
        if(isNotEmpty)
        {
            let taskModel : TaskModel = TaskModel()
            taskModel.Title = txtFTitle.text as NSString? ?? "" as NSString
            taskModel.Description = txtVDecription.text as NSString? ?? "" as NSString
            taskModel.Task_Type = NSString(string: currentTaskType.rawValue)
            taskModel.Task_Date = String().getDateFromString(dateFormat: DDBSmallDateFormat, dateStr: (txtFDate.text as NSString? ?? "" as NSString) as String) as NSString
           
            taskModel.Project_Name = txtFProjName.text as NSString? ?? "" as NSString
            taskModel.Date_Created = Date().toString(dateFormat: DTaskdateFormat) as NSString
            taskModel.Start_Time = txtFStartTime.text as NSString? ?? "" as NSString
//            if(currentTaskType == .Task)
//            {
//                taskModel.Start_Time = Date().toString(dateFormat: DFullTimeFormat) as NSString
//            }

            taskModel.End_Time = txtFEndTime.text as NSString? ?? "" as NSString
            taskModel.UserId = "1"
            taskModel.TotalTaskHours = "-"

            if(isForEdit)
            {
                taskModel.Task_Status = taskDetailObj.Task_Status as NSString? ?? "" as NSString
                taskModel.TotalTaskHours = taskModel.TotalTaskHours as NSString? ?? "" as NSString
                
                DBManager.sharedInstance.UpdateTaskOfID(taskDetail: taskModel, taskID: taskID)
            }
            else
            {
                taskModel.Task_Status = NSString(string: TaskStatusEnum.const_Pending.rawValue)
                DBManager.sharedInstance.AddTask(taskDetail: taskModel)
            }
            
            setReminderNotification()

            self.navigationController?.popViewController(animated: true)
            
        }
    }
    @IBAction func btnDeleteClicked()
    {
        
        let alert = UIAlertController(title: "Delete \(currentTaskType.rawValue)", message: "Are you sure you want to delete this?", preferredStyle: .alert)

        let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.deleteThisTask()
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
    }
}
