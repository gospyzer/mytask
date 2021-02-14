//
//  FileIOModel.swift
//  TaskManager
//
//  Created by Hima on R 2/02/14.
//  Copyright © Reiwa 2 Hima. All rights reserved.
//


import UIKit

/* This Class is written to handle file Read/Write of type HTML page
 - Author: Hima Seta
 - Date: February 13, 2020
*/

class HTMLFileIOModel: NSObject {
    
    /// Array of Tasks
    var arrTasks = [TaskModel]()
    var floatPending :Float = 0.0
    var floatDone :Float = 0.0
    var floatInProgress :Float = 0.0
    var totalDonePer :Float = 0.0
    var totalPendingPer :Float = 0.0
    var totalInProgressPer :Float = 0.0
   
    var ValuesOfXY = [String]()
   
    
    /* This function is written to reload HTML page data
     - Author: Hima Seta
     - Date: February 13, 2020
    */
    func reloadTasks(isPDFPreview : Bool , strStartDate : String , strEndDate : String)
    {
        if(!isPDFPreview)
        {
            let allTaskWithProgress  = DBManager.sharedInstance.selectTaskExceptReminderOfSelectedDate(sortBy: 0, strDate: strStartDate)
                   
            arrTasks = allTaskWithProgress.0
        }
        else
        {
            let allTaskWithCounts = DBManager.sharedInstance.selectTaskFromToTable(strStartDate: strStartDate, strEndDate: strEndDate, sortBy: 1)
            arrTasks = allTaskWithCounts.0
            
            floatPending = Float(allTaskWithCounts.1)
            floatDone = Float(allTaskWithCounts.2)
            floatInProgress = Float(allTaskWithCounts.3)
            
            let largest : Float = (Float(arrTasks.count))
            print(largest)
            
            totalDonePer = Float((floatDone * 100)/(largest))
            totalInProgressPer = Float((floatInProgress * 100)/(largest))
            totalPendingPer = Float((floatPending * 100)/(largest))
            
            ValuesOfXY = calculateCircleProgressPer(doneP: totalDonePer, ProgressP: totalInProgressPer, PendingP: totalPendingPer)
            print(ValuesOfXY)
            
        }
        
        
    }
    
     //MARK: - File Read Write functions
     
     /* This function written to copy HTML file from project bundle to the Documents directory.
      - Author: Hima Seta
      - Date: February 13, 2020
     */
    
     func writeFileContentToDocDir(writeString : String)
     {
         if let fileURL = FileManager.documentsDirHTMLFilePath() {

             //writing
             do {
                 try writeString.write(to: fileURL, atomically: false, encoding: .utf8)
                 print("File writing successful")
             }
             catch {/* error handling here */
                 print("Unable to write and use HTML template files.")
             }

             //reading
             do {
                 let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                 print(text2)
             }
             catch {/* error handling here */
                 print("Unable to read and use HTML template files.")
             }
         }
     }
    
    /* This function written write PDF content in HTML file
     - Author: Hima Seta
     - Date: February 18, 2020
    */
    
    func PDFwriteFileContentToDocDir(writeString : String)
    {
        if let fileURL = FileManager.documentsDirPDFHTMLFilePath() {

            //writing
            do {
                try writeString.write(to: fileURL, atomically: false, encoding: .utf8)
                print("File writing successful")
            }
            catch {/* error handling here */
                print("Unable to write and use HTML template files.")
            }

            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                print(text2)
            }
            catch {/* error handling here */
                print("Unable to read and use HTML template files.")
            }
        }
    }
     
    /* This function written to read HTML file from Documents directory.
      - Author: Hima Seta
      - Date: February 13, 2020
     */
     func readFileContentFromDocDir() -> String
        {
            if let fileURL = FileManager.documentsDirHTMLFilePath() {
                //reading
                do {
                    let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                    print(text2)
                  return text2
                }
                catch {/* error handling here */
                    print("Unable to read and use HTML template files.")
                }
            
            }
          return ""
        }
    
    /* This function written to read HTML file from Documents directory for History PDF.
     - Author: Hima Seta
     - Date: February 18, 2020
    */
    
    func PDFreadFileContentFromDocDir() -> String
    {
        if let fileURL = FileManager.documentsDirPDFHTMLFilePath() {
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                print(text2)
              return text2
            }
            catch {/* error handling here */
                print("Unable to read and use HTML template files.")
            }
        
        }
      return ""
    }
     
     /* This function written to render and replace actual values in HTML file from Documents directory.
      - Author: Hima Seta
      - Date: February 13, 2020
     */
     func renderHTMLTaskListTable() -> String {
         // Store the invoice number for future use.
         
         do {
             // Load the invoice HTML template code into a String variable.
             let fileURL = FileManager.documentsDirHTMLFilePath()!
             var taskTableHTMLContent = try String(contentsOf: fileURL, encoding: .utf8)
            
             for i in 0..<arrTasks.count {
                 
                
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#SR\(i+1)#", with: "\(i+1)")
                
                if(arrTasks[i].Task_Type as String == TaskTypeEnum.Task.rawValue)
                {
                    taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Project\(i+1)#", with: (arrTasks[i].Project_Name as String))
                }
                else{
                    taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Project\(i+1)#", with: (arrTasks[i].Project_Name as String) + "<br>" + (arrTasks[i].Task_Type as String))
                }
                 
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#TaskList\(i+1)#", with: (arrTasks[i].Title as String) + "<br>" + (arrTasks[i].Description as String))
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Hours\(i+1)#", with: "\(arrTasks[i].TotalTaskHours as String)")
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Status\(i+1)#", with: String(arrTasks[i].Task_Status))
             }
             
            
             
             // The HTML code is ready.
             return taskTableHTMLContent
             
         }
         catch {
             print("Unable to open and use HTML template files.")
         }
         
         return ""
     }
    
    /* This function written to render and replace actual values in PDF HTML file from Documents directory.
     - Author: Hima Seta
     - Date: February 18, 2020
    */
    
    func PDFrenderHTMLTaskListTable() -> String {
        // Store the invoice number for future use.
        
        do {
            // Load the invoice HTML template code into a String variable.
            let fileURL = FileManager.documentsDirPDFHTMLFilePath()!
            var taskTableHTMLContent = try String(contentsOf: fileURL, encoding: .utf8)
           
            taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#DonePer#", with: String(format: "%d", Int(floatDone)))
            taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#ProgressPer#", with: String(format: "%d", Int(floatInProgress)))
            taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#PendingPer#", with: String(format: "%d", Int(floatPending)))
            
            taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#DoneBarValues#", with: "\(ValuesOfXY[0])")
            taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#ProgressBarValues#", with: "\(ValuesOfXY[1])")
            taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#PendingBarValues#", with: "\(ValuesOfXY[2])")

            
           
            
            
            for i in 0..<arrTasks.count {
                
                ///get date task count
                 ///row span on  count
                 ///skip text after 1
                 
                print((arrTasks[i].Task_Date as String))
                taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Date\(i+1)#", with: "\(arrTasks[i].Task_Date as String)")
               
               if(arrTasks[i].Task_Type as String == TaskTypeEnum.Task.rawValue)
               {
                   taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Project\(i+1)#", with: (arrTasks[i].Project_Name as String))
               }
               else{
                   taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Project\(i+1)#", with: (arrTasks[i].Project_Name as String) + "<br>" + (arrTasks[i].Task_Type as String))
               }

                taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#TaskList\(i+1)#", with: (arrTasks[i].Title as String) + "<br>" + (arrTasks[i].Description as String))
                taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Hours\(i+1)#", with: "\(arrTasks[i].TotalTaskHours as String)")
                taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#Status\(i+1)#", with: String(arrTasks[i].Task_Status))
                
                
            }
            
            for i in 0..<arrTasks.count
            {
                let allTaskWithProgress  = DBManager.sharedInstance.selectTaskListOfSelectedDate(sortBy: 0, strDate: arrTasks[i].Task_Date as String)
                         
                 let arrDateTasks = allTaskWithProgress.0
                 
                 
                
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#DateRowSpan\(i+1)#", with: " rowspan=\(arrDateTasks.count)")
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#ProjectRowSpan\(i+1)#", with: " rowspan=\(1)")
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#TaskListRowSpan\(i+1)#", with: " rowspan=\(1)")
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#HoursRowSpan\(i+1)#", with: " rowspan=\(1)")
                 taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#StatusRowSpan\(i+1)#", with: " rowspan=\(1)")
                
//                if(arrDateTasks.count > 1)
//                {
//                    taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "<td>\(arrTasks[i].Task_Date as String)</td>", with: String(arrTasks[i].Task_Status))
//                }
                
                for j in 0..<arrDateTasks.count - 1
                {
                    taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "<td align='left' #DateRowSpan\(i+2)#>\(arrTasks[i].Task_Date as String)</td>", with:"")
                }
                
            }
           
            
            // The HTML code is ready.
            return taskTableHTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return ""
    }
   
    func calculateCircleProgressPer(doneP : Float, ProgressP : Float, PendingP : Float) ->([String])
    {
        //251.2 -- Full circle value
        let fullCircleValue : Float = 251.2
        
        var DoneValueX: Float = 0.0,DoneValueY: Float = 0.0,ProgressValueX: Float = 0.0,ProgressValueY: Float = 0.0,PendingValueX: Float = 0.0,PendingValueY: Float = 0.0
        
        DoneValueX = Float((doneP * fullCircleValue)/100)
        DoneValueY = Float(fullCircleValue-DoneValueX)
        let finalDoneValue = "\(DoneValueX),\(DoneValueY)"
        
        ProgressValueX = Float((ProgressP * fullCircleValue)/100)
        ProgressValueY = Float(fullCircleValue-ProgressValueX)
        let finalProgressValue = "\(ProgressValueX),\(ProgressValueY)"
        
        PendingValueX = Float((PendingP * fullCircleValue)/100)
        PendingValueY = Float(fullCircleValue-PendingValueX)
        let finalPendingValue = "\(PendingValueX),\(PendingValueY)"
        let arrStr = [finalDoneValue,finalProgressValue,finalPendingValue]
        return arrStr
        
    }
     /* This function written to add UI changes (Adding rows in table) in HTML file from Documents directory.
      - Author: Hima Seta
      - Date: February 13, 2020
     */
     func addTableRowDesign(numOfRows : String) -> String
     {
         var tableHTMLContent: String!
         var allAllItems = ""
         
         do {
             var taskTableHTMLContent = try String(contentsOfFile: DBundlePathToTaskTableHTMLTemplate!)
             
             for i in 1..<arrTasks.count
             {
                 tableHTMLContent = "\n\t<tr>\n\t\t<td>#SR\(i+1)#</td>\n\t\t<td>#Project\(i+1)#</td>\n\t\t<td>#TaskList\(i+1)#</td>\n\t\t<td>#Hours\(i+1)#</td>\n\t\t<td>#Status\(i+1)#</td>\n\t</tr>"
                 allAllItems += tableHTMLContent
             }
             // Set the items.
             taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#ADDROW#", with: allAllItems)
             
             return taskTableHTMLContent
         }
         catch {
             print("Unable to open and use HTML template files.")
         }
         return ""
     }
    
    /* This function written to add UI changes (Adding rows in table) in PDF HTML file from Documents directory.
         - Author: Hima Seta
         - Date: February 18, 2020
        */
    
    func PDFaddTableRowDesignFor(numOfRows : String) -> String
    {
        var tableHTMLContent: String!
        var allAllItems = ""
        
        do {
            var taskTableHTMLContent = try String(contentsOfFile: DBundlePathToTaskTablePDFHTMLTemplate!)
            
            for i in 1..<arrTasks.count
            {
                tableHTMLContent = "\n\t<tr>\n\t\t<td align='left' #DateRowSpan\(i+1)#>#Date\(i+1)#</td>\n\t\t<td align='left' #ProjectRowSpan\(i+1)#>#Project\(i+1)#</td>\n\t\t<td align='left' #TaskListRowSpan\(i+1)#>#TaskList\(i+1)#</td>\n\t\t<td align='left' #HoursRowSpan\(i+1)#>#Hours\(i+1)#</td>\n\t\t<td align='left' #StatusRowSpan\(i+1)#>#Status\(i+1)#</td>\n\t</tr>"
                allAllItems += tableHTMLContent
            }
            // Set the items.
            taskTableHTMLContent = taskTableHTMLContent.replacingOccurrences(of: "#ADDROW#", with: allAllItems)
            
            return taskTableHTMLContent
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        return ""
    }
}

