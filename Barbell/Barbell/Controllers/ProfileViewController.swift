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
        
        user = getUser()
        
        
        if let user = user as? [User] {
            firstName.text = user.first?.fname
            lastName.text = user.first?.lname
            age.text = "\(user.first?.age)"
            weight.text = "\(user.first?.weight)"
            squat.text = "\(user.first?.squat)"
            bench.text = "\(user.first?.bench)"
            deadlift.text = "\(user.first?.deadlift)"
            snatch.text = "\(user.first?.snatch)"
            cleanAndJerk.text = "\(user.first?.cleanAndJerk)"
            workoutsCompleted.text = "\(user.first?.workoutsCompleted)"
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func getUser() -> [User]{
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do{
            let foundPlayer = try getContext().fetch(fetchRequest)
            return foundPlayer
        }catch{
            print("we messed this up")
        }
        return [User]()
    }
    
    func getContext() -> NSManagedObjectContext {
        return CoreDataController.persistentContainer.viewContext
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
            //user.first?.weight = weight.text
            //user.first?.squat = squat.text
            //user.first?.bench = bench.text
            //user.first?.deadlift = deadlift.text
            //user.first?.snatch = snatch.text
            //user.first?.cleanAndJerk = cleanAndJerk.text
        }
        
        CoreDataController.saveContext()
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
