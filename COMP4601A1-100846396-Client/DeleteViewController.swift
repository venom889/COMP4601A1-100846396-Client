//
//  DeleteViewController.swift
//  COMP4601A1-100846396-Client
//
//  Created by Ben Sweett on 2015-01-19.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class DeleteViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchField: UITextField!
    
    var searchText: String! = ""
    
    var webVC: WebViewController!
    
    // MARK: - Lifecyle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.delegate = self
        
        SharedHelper.setNavBarForViewController(self, title: "Delete Document", withSubmitButton: true)
    }
    
    /**
        Adds this controller as an observer and disables the submit button
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"DELETE", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotResponseFromServer:", name:"DELETE-MULTI", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNetworkError:", name:"NETWORK-ERROR", object: nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
        Clears the fields and removes this controller as an obeserver
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        searchField.text = ""
        searchText = ""
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    /**
    Submits a delete by tags or by id based on the form input
    */
    @IBAction func submitAction(sender: UIBarButtonItem) {
        if (searchText.rangeOfString(":") != nil || !SharedHelper.validId(searchText)){
            SharedNetworkConnection.sharedInstance.deleteMultipleDocumentsOnServer(searchText)
        } else {
            SharedNetworkConnection.sharedInstance.deleteDocumentOnServer(searchText)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text: String = textField.text + string
        
        if(textField == searchField) {
            if(SharedHelper.validId(text) || SharedHelper.validTags(text)) {
                searchText = text
            } else {
                searchText = ""
            }
        }
        
        if(checkCompleteForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text: String = textField.text
        if(textField == searchField) {
            if(SharedHelper.validId(text) || SharedHelper.validTags(text)) {
                searchText = text
            } else {
                searchText = ""
                JLToast.makeText("Invalid ID or Tag", duration: JLToastDelay.LongDelay).show()
            }
        }
        
        if(checkCompleteForm()) {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
    
    
    // MARK: - Form State
    
    /**
    Checks that the form is complete
    */
    func checkCompleteForm() -> Bool{
        if(searchText != "") {
            return true
        }
        
        return false
    }
    
    /**
    pops this view from the nav stack
    */
    func popView() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - NSNotifications
    
    /**
    Gets the response from the notification and sends it to a alert controller before displaying it
    */
    func gotResponseFromServer(notification: NSNotification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as Dictionary<String,String>
        let response: String = userInfo["message"]!
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            let alert = UIAlertController(title:  "SDA Response", message: response, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                
            }
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: { () -> Void in
                self.popView()
            })
        }
    }
    
    /**
    Gets the error from the notification and sends it to an alert controller before displaying it
    */
    func gotNetworkError(notification: NSNotification) {
        let userInfo:Dictionary<String,String> = notification.userInfo as Dictionary<String,String>
        let error: String = userInfo["error"]!
        
        let alert = UIAlertController(title:  "Network Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
            
        }
        alert.addAction(cancelAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true) {
                
            }
        }
    }
    
}
