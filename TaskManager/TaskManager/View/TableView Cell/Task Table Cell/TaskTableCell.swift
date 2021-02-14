//
//  TaskTableCell.swift
//  TaskManager
//
//  Created by Hima on 20/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit
import iOSDropDown

class TaskTableCell: UITableViewCell {

    // MARK: - UI properties
    
    ///UILabel show  Color
    @IBOutlet var lblColor : UILabel!
    
    ///UILabel show  Time
    @IBOutlet var lblTime : UILabel!

    ///UILabel show  Time
    @IBOutlet var lblEndTime : UILabel!
    
    ///UILabel show  Title
    @IBOutlet var lblTitle : UILabel!
    
    ///UILabel show  Project name
    //@IBOutlet var lblProjectNM : UILabel!
    
    ///UILabel show  Description
    @IBOutlet var lblDescription : UILabel!
    
    ///UIButton show  Task Type
    @IBOutlet var btnTaskType : UIButton!
    
    ///UIButton show  Task Type
    @IBOutlet var imgViewLeftDash : UIImageView!
    
    ///DropDown to give status of task
    //@IBOutlet weak var dropDown : DropDown!
    
    ///UILabel show  Project name
    @IBOutlet var lblProjName : UILabel!
    
    ///UILabel show  Project name
    @IBOutlet var constProjectNameHeight : NSLayoutConstraint!

    ///UILabel show  Project name
    @IBOutlet var constProjectNameTop : NSLayoutConstraint!

    /// Task UIView
    @IBOutlet var vwTaskBG: UIView!


    /// Task status uilabel
    @IBOutlet var lblTaskStatus: UILabel!

    /// Task status edit button
    @IBOutlet var btnTaskStatusEdit: UIButton!

    ///Edit task status image width constraint
    @IBOutlet var imgEditWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //loadDropDown()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    ///MARK: - DropDown load
    /*func loadDropDown()
    {
        // The list of array to display. Can be changed dynamically
        dropDown.optionArray = [TaskStatusEnum.const_InProgress.rawValue,TaskStatusEnum.const_Completed.rawValue,TaskStatusEnum.const_Pending.rawValue]
        
    
          //Its Id Values and its optional
         // dropDown.optionIds = [1,23,54,22]

          // Image Array its optional
         // dropDown.ImageArray = [👩🏻‍🦳,🙊,🥞]
          // The the Closure returns Selected Index and String
          dropDown.didSelect{(selectedText , index ,id) in
          
        }
    }*/
    
}
