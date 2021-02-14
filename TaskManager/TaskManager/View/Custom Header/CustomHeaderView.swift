//
//  CustomHeaderView.swift
//  TaskManager
//
//  Created by Hima on 17/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit

/**
This View is written to add Header in any ViewController

- Author: Hima Seta
- Date: January 17, 2020
*/

@IBDesignable class CustomHeaderView: UIView {

    // MARK: - UI properties
    
    ///UIView  used as container
   // @IBOutlet var contentView : UIView!
    
    ///UILabel show header Title
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var btnBack : UIButton!
    //@IBOutlet var constraintCenterConst : NSLayoutConstraint!
    
     //MARK:- Init functions
       
       /* This function written show header view in any viewcontroller via programming in .swift
        - Author: Hima Seta
        - Date: January 17, 2020
       */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /* This function written show header view in any viewcontroller via storyboard IB
           - Author: Hima Seta
           - Date: January 17, 2020
          */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
   
    /* This function written show header view in any viewcontroller via programming
           - Author: Hima Seta
           - Date: January 17, 2020
          */
       fileprivate func setupView() {
           let view = viewFromNibForClass()
           view.frame = bounds
           view.autoresizingMask = [
               UIView.AutoresizingMask.flexibleWidth,
               UIView.AutoresizingMask.flexibleHeight
           ]
           addSubview(view)
       }
       
       /* This will load a XIB file into a view and returns this view.
            - Author: Hima Seta
            - Date: January 17, 2020
        */
       fileprivate func viewFromNibForClass() -> UIView {
           let bundle = Bundle(for: type(of: self))
           let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
           let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
           return view
       }
    func setCeneterTitle()
    {
        self.btnBack.isHidden = true
        self.lblTitle.textAlignment = .center
        //self.constraintCenterConst.constant = 0
    }
    
    // MARK: - Button Clicks
       
       @IBAction func btnBackClicked()
       {
            AppDelegate.sharedInstance.navigationController?.popViewController(animated: true)
       }
        

}
