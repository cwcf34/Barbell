//
//  RegistrationViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 2/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

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
        let alert = UIAlertController(title: "Attention!", message: "Please provide all of the feilds in order to register", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        
        let usernameTaken = UIAlertController(title: "Attention!", message: "The email that you provided is already taken", preferredStyle: UIAlertControllerStyle.alert)
        usernameTaken.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        
        if(emailField.hasText && passwordField.hasText && firstNameField.hasText && lastNameField.hasText) {
            
            let registerInfo = RegisterInfo.init(email: emailField.text!, password: passwordField.text!, firstName: firstNameField.text!, lastName: lastNameField.text!)
            
            print(registerInfo.email)
            let dbResponse = DataAccess.register(registerInfo: registerInfo)
            print(dbResponse)
            
            if(dbResponse == false){
                self.present(usernameTaken, animated: true, completion: nil)
            }
            
            if(dbResponse == true){
                
                // Nuke existing Core Data
                //Add user info to persistent Database
                CoreDataController.clearData()

                let user:User = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.getContext()) as! User
                user.fname = firstNameField.text
                user.lname = lastNameField.text
                user.email = emailField.text
                user.age = 0
                user.weight = 0
                user.squat = 0
                user.bench = 0
                user.deadlift = 0
                user.cleanAndJerk = 0
                user.snatch = 0
                user.workoutsCompleted = 0
                
                CoreDataController.saveContext()
            }
            
        } else if(!emailField.hasText || !passwordField.hasText || !firstNameField.hasText || !lastNameField.hasText) {
            self.present(alert, animated: true, completion: nil)
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
