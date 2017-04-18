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
    
    var user : User?
    
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
        
        
        if let user = user {
            firstName.text = user.fname
            lastName.text = user.lname
            if user.age == 0 {
            }
            else{
                age.text = String(user.age)
            }
            if user.weight == 0{
            }
            else{
                weight.text = String(user.weight)
            }
            if user.squat == 0{
            }
            else{
                squat.text = String(user.squat)
            }
            if user.bench == 0{
            }
            else{
                bench.text = String(user.bench)
            }
            if user.deadlift == 0{
            }
            else{
                deadlift.text = String(user.deadlift)
            }
            if user.snatch == 0{
            }
            else{
                snatch.text = String(user.snatch)
            }
            if user.cleanAndJerk == 0{
            }
            else{
                cleanAndJerk.text = String(user.cleanAndJerk)
            }
            workoutsCompleted.text = String(user.workoutsCompleted)
            
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveUserInfo(_ sender: Any) {
        if let user = user {
            user.fname = firstName.text
            user.lname = lastName.text
            
            if let ageString = age.text {
                
                if let age = Int16(ageString) {
                    user.age = age
                }
                
            }
            if let weightString = weight.text {
                
                if let weight = Int16(weightString) {
                    user.weight = weight
                }
                
            }
            if let squatString = squat.text {
                
                if let squat = Int16(squatString) {
                    user.squat = squat
                }
                
            }
            if let benchString = bench.text {
                
                if let bench = Int16(benchString) {
                    user.bench = bench
                }
                
            }
            if let deadliftString = deadlift.text {
                
                if let deadlift = Int16(deadliftString) {
                    user.deadlift = deadlift
                }
                
            }
            if let snatchString = snatch.text {
                
                if let snatch = Int16(snatchString) {
                    user.snatch = snatch
                }
                
            }
            if let cleanAndJerkString = cleanAndJerk.text {
                
                if let cleanAndJerk = Int16(cleanAndJerkString) {
                    user.cleanAndJerk = cleanAndJerk
                }
                
            }
            
        }
        
        CoreDataController.saveContext()
    }


    @IBAction func Logout(_ sender: Any) {
        var foundRoutines = [Routine]()
        
        let fetchRequest = NSFetchRequest<Routine>(entityName: "Routine")
        do{
            foundRoutines = try CoreDataController.getContext().fetch(fetchRequest)
            
        }catch{
            print("Bad getExercise query")
        }
        for routine in foundRoutines{
            if(routine.name != nil) {
                print(routine.name)
                if(routine.isPublic == false) {
                    DataAccess.sendRoutineToRedis(routine: routine)
                }
            }
        }
        DataAccess.checkRoutines()
        DataAccess.saveUserToRedis(email: (user?.email)!)
        
       self.performSegue(withIdentifier: "toLogin", sender: self)
    }
}
