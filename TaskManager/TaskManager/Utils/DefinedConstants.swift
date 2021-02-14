//
//  DefinedConstants.swift
//  TaskManager
//
//  Created by Hima on 23/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit

let bannerAdID = "ca-app-pub-6058234353449901/6141XXXXXX"
let fullAdID = "ca-app-pub-792484733858xxxx/618372xxxx"

let DTaskdateFormatFull = "dd MMMM yyyy"
let DTaskdateFormat = "dd-MMM-yyyy"
let DTaskTimeFormat = "hh:mm a"

let DSmallDateFormat = "dd-MM-yyyy"
let DDBSmallDateFormat = "yyyy-MM-dd"
let DFullTimeFormat = "HH:mm"

let DtodayDate = Date()

let DBundlePathToTaskTableHTMLTemplate = Bundle.main.path(forResource: "taskTable", ofType: "html")
let DBundlePathToTaskTablePDFHTMLTemplate = Bundle.main.path(forResource: "PDFHistoryTable", ofType: "html")
let DHTMLFileName = "taskTable.html"
let DPDFHTMLFileName = "PDFHistoryTable.html"


enum TaskStatusEnum : String {
    case const_InProgress = "In Progress"
    case const_Completed = "Completed"
    case const_Pending = "Pending"
    
    static func index(of aStatus: TaskStatusEnum) -> Int {
        let elements = [TaskStatusEnum.const_InProgress, TaskStatusEnum.const_Completed, TaskStatusEnum.const_Pending]

        return elements.index(of: aStatus)!
    }
}


enum TaskTypeEnum : String {
    case Task = "Task"
    case Meeting = "Meeting"
    case Reminder = "Reminder"
}

struct DB {
    static let Name = "TaskManager.sqlite"
}


let arrColors = [UIColor(red: 255/255.0, green:205/255.0, blue:210/255.0, alpha: 1.0), UIColor(red: 225/255.0, green:190/255.0, blue:231/255.0, alpha: 1.0), UIColor(red: 197/255.0, green:202/255.0, blue:233/255.0, alpha: 1.0), UIColor(red: 187/255.0, green:222/255.0, blue:251/255.0, alpha: 1.0), UIColor(red: 179/255.0, green:229/255.0, blue:252/255.0, alpha: 1.0), UIColor(red: 178/255.0, green:235/255.0, blue:242/255.0, alpha: 1.0), UIColor(red: 178/255.0, green:223/255.0, blue:219/255.0, alpha: 1.0), UIColor(red: 200/255.0, green:230/255.0, blue:201/255.0, alpha: 1.0), UIColor(red: 220/255.0, green:237/255.0, blue:200/255.0, alpha: 1.0), UIColor(red: 240/255.0, green:244/255.0, blue:195/255.0, alpha: 1.0), UIColor(red: 255/255.0, green:249/255.0, blue:196/255.0, alpha: 1.0), UIColor(red: 255/255.0, green:236/255.0, blue:179/255.0, alpha: 1.0), UIColor(red: 255/255.0, green:224/255.0, blue:178/255.0, alpha: 1.0), UIColor(red: 255/255.0, green:204/255.0, blue:188/255.0, alpha: 1.0), UIColor(red: 215/255.0, green:204/255.0, blue:200/255.0, alpha: 1.0)]

