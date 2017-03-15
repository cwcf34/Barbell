//
//  LoginViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 2/27/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        if(email.hasText && password.hasText) {
            
            let loginInfo = LoginInfo.init(email: email.text!, password: password.text!)
            
            //print(loginInfo.email)
            let dbResponse = DataAccess.login(loginInfo: loginInfo)
            print(dbResponse)
            
            //Add user info to persistent Database
            //let user:User = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.persistentContainer.viewContext) as! User
            //user.fname = firstNameField.text
            //user.lname = lastNameField.text
            //user.email = emailField.text
            
            //CoreDataController.saveContext()
            
        } else {
            if(!email.hasText) {
                email.text = "Please enter an email."
                email.textColor = UIColor.red
            }
            if(!password.hasText) {
                password.text = "Please enter a password."
                password.textColor = UIColor.red
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
