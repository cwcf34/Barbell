//
//  RegistrationViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 2/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Handle register button clicked
    @IBAction func register(_ sender: Any) {
        if(emailField.hasText && passwordField.hasText && firstNameField.hasText && lastNameField.hasText) {
            
            let registerInfo = RegisterInfo.init(email: emailField.text!, password: passwordField.text!, firstName: firstNameField.text!, lastName: lastNameField.text!)
            
            
            print(registerInfo.email)
            let dbResponse = DataAccess.connectToDatabase(registerInfo: registerInfo)
            print(dbResponse)
        } else {
            if(!emailField.hasText) {
                emailField.text = "Please enter an email."
                emailField.textColor = UIColor.red
            }
            if(!passwordField.hasText) {
                passwordField.text = "Please enter a password."
                passwordField.textColor = UIColor.red
            }
            if(!firstNameField.hasText) {
                firstNameField.text = "Please enter a first name."
                firstNameField.textColor = UIColor.red
            }
            if(!lastNameField.hasText) {
                lastNameField.text = "Please enter a last name."
                lastNameField.textColor = UIColor.red
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
