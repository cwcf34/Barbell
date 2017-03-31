//
//  ProfileViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 3/14/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
    
    var user = [User]()
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var squat: UITextField!
    @IBOutlet weak var bench: UITextField!
    @IBOutlet weak var deadlift: UITextField!
    @IBOutlet weak var snatch: UITextField!
    @IBOutlet weak var cleanAndJerk: UITextField!
    @IBOutlet weak var workoutsCompleted: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = CoreDataController.getUser()
        
        
        if let user = user as? [User] {
            firstName.text = user.first?.fname
            lastName.text = user.first?.lname
            
            if let userAge = user.first?.age{
                age.text = userAge.description
            }
            if let userWeight = user.first?.weight{
                weight.text = userWeight.description
            }
            if let userSquat = user.first?.squat{
                squat.text = userSquat.description
            }
            if let userBench = user.first?.bench{
                bench.text = userBench.description
            }
            if let userDeadlift = user.first?.deadlift{
                deadlift.text = userDeadlift.description
            }
            if let userSnatch = user.first?.snatch{
                snatch.text = userSnatch.description
            }
            if let userClean = user.first?.cleanAndJerk{
                cleanAndJerk.text = userClean.description
            }
            if let userWorkouts = user.first?.workoutsCompleted{
                workoutsCompleted.text = userWorkouts.description
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveUserInfo(_ sender: Any) {
        if let user = user as? [User] {
            user.first?.fname = firstName.text
            user.first?.lname = lastName.text
            
            if let ageString = age.text {
                
                if let age = Int16(ageString) {
                    user.first?.age = age
                }
                
            }
            if let weightString = weight.text {
                
                if let weight = Int16(weightString) {
                    user.first?.weight = weight
                }
                
            }
            if let squatString = squat.text {
                
                if let squat = Int16(squatString) {
                    user.first?.squat = squat
                }
                
            }
            if let benchString = bench.text {
                
                if let bench = Int16(benchString) {
                    user.first?.bench = bench
                }
                
            }
            if let deadliftString = deadlift.text {
                
                if let deadlift = Int16(deadliftString) {
                    user.first?.deadlift = deadlift
                }
                
            }
            if let snatchString = snatch.text {
                
                if let snatch = Int16(snatchString) {
                    user.first?.snatch = snatch
                }
                
            }
            if let cleanAndJerkString = cleanAndJerk.text {
                
                if let cleanAndJerk = Int16(cleanAndJerkString) {
                    user.first?.cleanAndJerk = cleanAndJerk
                }
                
            }
            
        }
        
        CoreDataController.saveContext()
        DataAccess.saveUserToRedis(email: (user.first?.email)!)
    }

}
