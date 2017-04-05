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
            
            if(dbResponse == false){
                self.present(invalidLogin, animated: true, completion: nil)
                
            }
            if(dbResponse == true){
                CoreDataController.clearData()
                
                
                //Add user info to persistent Database
                DataAccess.getUserfromRedis(email: email.text!)
                let routines = DataAccess.getRoutinesFromRedis()
                
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
