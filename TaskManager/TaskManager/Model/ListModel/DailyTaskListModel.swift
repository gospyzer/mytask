//
//  DailyTaskListModel.swift
//  TaskManager
//
//  Created by Hima on 28/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit

class DailyTaskListModel: NSObject {

    
    var arrItems: [TaskModel] = []
    //var delegate: OurAppListModelDelegate?
    var footerheight: CGFloat = 0.0
    var tblView: UITableView!
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    func reloadList(arrList : [TaskModel], tableView : UITableView, footerHeight: CGFloat) {
        arrItems = arrList
        footerheight = footerHeight
        tblView = tableView
        tableView.reloadData()
    }
    
}

extension DailyTaskListModel: UITableViewDataSource, UITableViewDelegate
{
    //  let cellReuseIdentifier = "DailyCell"
    
    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : TaskTableCell! = tableView.dequeueReusableCell(withIdentifier: "DailyCell") as? TaskTableCell

        if cell == nil {
            tableView.register(UINib(nibName: "TaskTableCell", bundle: nil), forCellReuseIdentifier: "DailyCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell") as? TaskTableCell
        }
        cell.imgViewLeftDash.backgroundColor = UIColor(patternImage: UIImage(named: "SingleDashedLine")!)

        //cell.lblProjName.text = arrItems[indexPath.row].Project_Name as String
        cell.lblTitle.text = arrItems[indexPath.row].Title as String
        cell.lblDescription.text = arrItems[indexPath.row].Description as String

        let anEnumType = TaskTypeEnum(rawValue: (arrItems[indexPath.row].Task_Type as String))!
        cell.btnTaskType?.setTitle("  "+"\(anEnumType.rawValue)"+"  ", for: .normal)


        let anEnumStatus = TaskStatusEnum(rawValue: (arrItems[indexPath.row].Task_Status as String))!
        //cell.lblTaskStatus.text = "  "+"\(anEnumStatus.rawValue)"+"  "

        let time = arrItems[indexPath.row].Start_Time as String
        cell.lblTime.text = time.convertTimeFormat(inputFormat: DFullTimeFormat, outFormat: DTaskTimeFormat, time: time)

        let index = TaskStatusEnum.index(of: TaskStatusEnum(rawValue: String(self.arrItems[indexPath.row].Task_Status))!)

        cell.vwTaskBG.backgroundColor = arrColors[indexPath.row%15]
//        switch anEnumStatus.rawValue {
//        case TaskStatusEnum.const_Completed.rawValue://Done
//            //cell.vwTaskStatus.backgroundColor = UIColor.TaskTypeStatus.progressDoneColor
//            //cell.lblTaskStatus.textColor = UIColor.MyTheme.progressDoneColor
//            cell.vwTaskBG.backgroundColor = UIColor.MyTheme.progressDoneColor
//            break
//        case TaskStatusEnum.const_Pending.rawValue://Pending
//            //cell.vwTaskStatus.backgroundColor = UIColor.TaskTypeStatus.progressPendingColor
//            //cell.lblTaskStatus.textColor = UIColor.MyTheme.progressPendingColor
//            cell.vwTaskBG.backgroundColor = UIColor.MyTheme.progressPendingColor
//            break
//        case TaskStatusEnum.const_InProgress.rawValue://InProgress
//            //cell.vwTaskStatus.backgroundColor = UIColor.TaskTypeStatus.progressInProgressColor
//            //cell.lblTaskStatus.textColor = UIColor.MyTheme.progressInProgressColor
//            cell.vwTaskBG.backgroundColor = UIColor.MyTheme.progressInProgressColor
//            break
//        default:
//            //cell.vwTaskStatus.backgroundColor = UIColor.TaskTypeStatus.progressPendingColor
//            //cell.lblTaskStatus.textColor = UIColor.MyTheme.progressPendingColor
//            cell.vwTaskBG.backgroundColor = UIColor.MyTheme.progressPendingColor
//            break
//        }

        //cell.lblColor.backgroundColor = UIColor.TaskType[indexPath.row%3]

        cell.lblEndTime.isHidden = true

        if(anEnumType == .Meeting || anEnumType == .Task)
        {
            let time1 = arrItems[indexPath.row].Start_Time as String
            let time2 = arrItems[indexPath.row].End_Time as String

            cell.lblTime.text = (time1.convertTimeFormat(inputFormat: DFullTimeFormat, outFormat: DTaskTimeFormat, time: time1))
            cell.lblEndTime.text = (time2.convertTimeFormat(inputFormat: DFullTimeFormat, outFormat: DTaskTimeFormat, time: time2))
            cell.lblEndTime.isHidden = false
        }

        let todaysDate = Date().toString(dateFormat: DDBSmallDateFormat)
        if arrItems[indexPath.row].Task_Date as String == todaysDate {
            //cell.imgEditWidthConstraint.constant = 40.0
            cell.btnTaskStatusEdit.tag = indexPath.row
            cell.btnTaskStatusEdit.isUserInteractionEnabled = true
        }
        else {
            //cell.imgEditWidthConstraint.constant = 0.0
            cell.btnTaskStatusEdit.isUserInteractionEnabled = false
        }

        cell.btnTaskStatusEdit.addTarget(self, action: #selector(showAlert(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let todaysDate = Date().toString(dateFormat: DDBSmallDateFormat)
        if arrItems[indexPath.row].Task_Date as String == todaysDate {
            let vc = UIStoryboard(name: "AddTaskVC", bundle: nil).instantiateViewController(withIdentifier: "AddTaskVC") as? AddTaskVC

            vc?.isForEdit = true
            vc?.taskID = arrItems[indexPath.row].ID

            vc?.currentTaskType = TaskTypeEnum(rawValue: String(arrItems[indexPath.row].Task_Type))!
            vc?.taskDetailObj = DBManager.sharedInstance.selectTaskOfSelectedId(Id: arrItems[indexPath.row].ID)

            AppDelegate.sharedInstance.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerheight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: footerheight))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }

    /* This function is used to display actionsheet to change task status
    - Author: Nirav Patel
    - Date: Feb 26, 2020
    */
    @IBAction func showAlert(_ sender: AnyObject) {
        let alert = UIAlertController(title: "", message: "Select Status", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: TaskStatusEnum.const_InProgress.rawValue, style: .default , handler:{ (UIAlertAction)in
            self.updateTaskStatus(status: TaskStatusEnum.const_InProgress.rawValue as NSString, index: sender.tag)
        }))

        alert.addAction(UIAlertAction(title: TaskStatusEnum.const_Completed.rawValue, style: .default , handler:{ (UIAlertAction)in
            self.updateTaskStatus(status: TaskStatusEnum.const_Completed.rawValue as NSString, index: sender.tag)
        }))

        alert.addAction(UIAlertAction(title: TaskStatusEnum.const_Pending.rawValue, style: .default , handler:{ (UIAlertAction)in
            self.updateTaskStatus(status: TaskStatusEnum.const_Pending.rawValue as NSString, index: sender.tag)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
            //self.updateTaskStatus(status: "Pending", index: sender.tag)
        }))

        AppDelegate.sharedInstance.navigationController?.topViewController!.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    /* This function is used to update task status locally and update UI also.
    - Author: Nirav Patel
    - Date: Feb 26, 2020
    */
    func updateTaskStatus(status: NSString, index: Int) {
        let objModel = self.arrItems[index]
        objModel.Task_Status = status

        if(self.arrItems[index].Task_Type as String == TaskTypeEnum.Task.rawValue)
        {
            if(status as String == TaskStatusEnum.const_Completed.rawValue)
            {
                let TaskDataDict:[String: TaskModel] = ["Task": objModel]
                NotificationCenter.default.post(name: Notification.Name("completedHoursClick"), object:nil, userInfo: TaskDataDict )
            }
            else if(status as String == TaskStatusEnum.const_InProgress.rawValue)
            {
                objModel.TotalTaskHours = CommonFunctions.getDifferenceTotalTimeInMinutes(from: String().convertDateFormatter(dateStr: (objModel.Start_Time as String), timeFormat: DFullTimeFormat), EndTime: String().convertDateFormatter(dateStr: (objModel.End_Time as String), timeFormat: DFullTimeFormat)) as NSString
                
                DBManager.sharedInstance.UpdateTaskOfID(taskDetail: objModel, taskID: objModel.ID)
                self.reloadList(arrList: [objModel], tableView: tblView, footerHeight: self.footerheight)
                NotificationCenter.default.post(name: Notification.Name("ProgressViewReload"), object: nil)
            }
            else
            {
                objModel.TotalTaskHours = "-"
                DBManager.sharedInstance.UpdateTaskOfID(taskDetail: objModel, taskID: objModel.ID)
                self.reloadList(arrList: [objModel], tableView: tblView, footerHeight: self.footerheight)
                NotificationCenter.default.post(name: Notification.Name("ProgressViewReload"), object: nil)
            }
            
        }
        else
        {
            DBManager.sharedInstance.UpdateTaskOfID(taskDetail: objModel, taskID: objModel.ID)
            self.reloadList(arrList: [objModel], tableView: tblView, footerHeight: self.footerheight)
            NotificationCenter.default.post(name: Notification.Name("ProgressViewReload"), object: nil)
        }
    }
    
    

}
