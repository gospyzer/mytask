//
//  SettingsListModel.swift
//  TaskManager
//
//  Created by Hima on R 2/02/14.
//  Copyright © Reiwa 2 Hima. All rights reserved.
//

import UIKit

/* This Delegate Protocol written to notify when email table and PDF table created
 - Author: Hima Seta
 - Date: February 18, 2020
*/
protocol SettingsListModelDelegate: class {
    func sendEmailDelegate(strEmailBody : String)
    func previewPDFDelegate(strPDFBody : String)
    func switchChanged(item: String)
    func restoreInApp()
}


/* This Model written to create HTML page including table
 - Author: Hima Seta
 - Date: February 18, 2020
*/
class SettingsListModel: NSObject {

     var arrItems = ["Remove Ads", "Export History"]
    
    ///SettingsListModelDelegate delegate model
    weak var delegate: SettingsListModelDelegate?
    
    ///HTMLFileIOModel local variable
    var htmlFileObj = HTMLFileIOModel()
    
    var strEmailBodyData : String = ""
    
    
    /* This function is written to reload items for HTML
     - Author: Hima Seta
     - Date: February 18, 2020
    */
    func reloadSettingItems(tableView : UITableView ,isPDFPreview : Bool, strStartDate: String, strEndDate : String) -> (String)
    {
        tableView.reloadData()
        tableView.tableFooterView = UIView()
        htmlFileObj.reloadTasks(isPDFPreview: isPDFPreview, strStartDate: strStartDate, strEndDate: strEndDate)
        
        if(htmlFileObj.arrTasks.count > 0)
        {
            if(isPDFPreview)
            {
                let htmlTableUIStr = htmlFileObj.PDFaddTableRowDesignFor(numOfRows: String(htmlFileObj.arrTasks.count))
                htmlFileObj.PDFwriteFileContentToDocDir(writeString: htmlTableUIStr)
                           
                           
                let htmlFileStr = htmlFileObj.PDFrenderHTMLTaskListTable()
                htmlFileObj.PDFwriteFileContentToDocDir(writeString: htmlFileStr)
                   
                strEmailBodyData = htmlFileObj.PDFreadFileContentFromDocDir()
                   
                return strEmailBodyData
            }
            else
            {
                let htmlTableUIStr = htmlFileObj.addTableRowDesign(numOfRows: String(htmlFileObj.arrTasks.count))
                htmlFileObj.writeFileContentToDocDir(writeString: htmlTableUIStr)
                           
                           
                let htmlFileStr = htmlFileObj.renderHTMLTaskListTable()
                htmlFileObj.writeFileContentToDocDir(writeString: htmlFileStr)
                   
                strEmailBodyData = htmlFileObj.readFileContentFromDocDir()
                   
                return strEmailBodyData
            }
           
        }
        return ""
       
    }
    
}

/* This Table model written to add data in table
 - Author: Hima Seta
 - Date: February 18, 2020
*/

class SettingTableCell: UITableViewCell{
    
    @IBOutlet var lblText: UILabel!
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var objcSwitch: UISwitch!
    @IBOutlet var btnRestore: UIButton!
    @IBOutlet var btnRestoreWidthConstraint: NSLayoutConstraint!
}

extension SettingsListModel: UITableViewDataSource, UITableViewDelegate
{
      //  let cellReuseIdentifier = "DailyCell"
    
        // MARK: - TableView Delegate
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return arrItems.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            var cell : SettingTableCell! = tableView.dequeueReusableCell(withIdentifier: "SettingTableCell") as? SettingTableCell

          if cell == nil {
         //   tableView.register(UINib(nibName: "TaskTableCell", bundle: nil), forCellReuseIdentifier: "SettingTableCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableCell") as? SettingTableCell
            }

            cell.objcSwitch.tag = indexPath.row
            cell.objcSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell.btnRestoreWidthConstraint.constant = 0.0

            if indexPath.row == 0 {
                cell.btnRestore.addTarget(self, action: #selector(restoreInApp(_:)), for: .touchUpInside)

                cell.imgArrow.isHidden = true
                cell.objcSwitch.isHidden = false
                cell.btnRestore.isHidden = false

                if AppDelegate.sharedInstance.isPurchased == false {
                    cell.objcSwitch.isOn = false
                    cell.objcSwitch.isUserInteractionEnabled = true
                    cell.btnRestoreWidthConstraint.constant = 70.0
                } else {
                    cell.objcSwitch.isOn = true
                    cell.objcSwitch.isUserInteractionEnabled = false
                }
            }
            else {
                cell.imgArrow.isHidden = false
                cell.objcSwitch.isHidden = true
                cell.btnRestore.isHidden = true
            }
            
            cell.lblText.text = arrItems[indexPath.row]
            
            cell.selectionStyle = .none
            return cell
            
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               
            switch indexPath.row {
           
            case 0:
                let item = arrItems[indexPath.row]
                //delegate?.selectedItem(title: item)
                break
            case 1:
                delegate?.previewPDFDelegate(strPDFBody: strEmailBodyData)
            default:
                break
            }
                
        }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
             return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

    @objc func switchChanged(_ sender: UISwitch) {
        delegate?.switchChanged(item: arrItems[sender.tag])
    }

    @objc func restoreInApp(_: UIButton) {
        delegate?.restoreInApp()
    }
       
        
}
