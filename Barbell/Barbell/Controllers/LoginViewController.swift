//
//  LoginViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 2/27/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

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
        let notAllFormsFilled = UIAlertController(title: "Attention!", message: "Please provide all the fields in order to login", preferredStyle: UIAlertControllerStyle.alert)
        notAllFormsFilled.addAction(UIAlertAction(title: "Click here to complete registration", style: UIAlertActionStyle.default, handler: nil))
        
        let invalidLogin = UIAlertController(title: "Attention!", message: "You entered either the wrong username or password", preferredStyle: UIAlertControllerStyle.alert)
        invalidLogin.addAction(UIAlertAction(title: "Click here to complete registration", style: UIAlertActionStyle.default, handler: nil))


        
        if(email.hasText && password.hasText) {
            
            let loginInfo = LoginInfo.init(email: email.text!, password: password.text!)
            
            //print(loginInfo.email)
            let dbResponse = DataAccess.login(loginInfo: loginInfo)
            print("this is db Response:" + dbResponse.description)
            
            if(dbResponse == false){
                self.present(invalidLogin, animated: true, completion: nil)
                
            }
            if(dbResponse == true){
                CoreDataController.clearData()
                
                
                //Load all existing user info for provided email from redis into Core data
                DataAccess.getUserfromRedis(email: email.text!)
                print(CoreDataController.getUser().first?.email!)
                
                
                //CoreDataController.saveContext()
                
                /*var user = [User]()
                user = CoreDataController.getUser()
                CoreDataController.clearData()
                let user1:User = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.getContext()) as! User
                user1.email = email.text
                user1.fname = user.first?.fname
                user1.lname = user.first?.lname
                user1.age = (user.first?.age)!
                user1.weight = (user.first?.weight)!
                user1.squat = (user.first?.squat)!
                user1.bench = (user.first?.bench)!
                user1.deadlift = (user.first?.deadlift)!
                user1.cleanAndJerk = (user.first?.cleanAndJerk)!
                user1.snatch = (user.first?.snatch)!
                user1.workoutsCompleted = (user.first?.workoutsCompleted)!
                
                
                CoreDataController.saveContext()
                //DataAccess.setUser(user: (user.first)!)*/
            }
            

            
        } else if(!email.hasText || !password.hasText) {
            self.present(notAllFormsFilled, animated: true, completion: nil)
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
