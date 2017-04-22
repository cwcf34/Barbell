//
//  StartRoutineTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/30/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

protocol ExerciseHistoryViewControllerDelegate: class { //Setting up a Custom delegate for this class. I am using `class` here to make it weak.
    func sendDataBackToHomePageViewController(routinePassed: Routine?) //This function will send the data back to origin viewcontroller.
}

class ExerciseHistoryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var CompletedSetsLabel: UILabel!
    @IBOutlet weak var CompletedRepsLabel: UILabel!
    @IBOutlet weak var CompletedWeightLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    
    var workoutPassed : Workout!
    var routinePassed : Routine!
    var liftsInWorkout = [Lift]()
    var user : User!
    var i = 0
    var hasFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = CoreDataController.getUser()
        
        liftsInWorkout = workoutPassed.hasExercises?.allObjects as! [Lift]
        print(liftsInWorkout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        switch (Int(workoutPassed.weeknumber))
        {
        case 1:
            dayOfWeek.text = "Sunday"
            
        case 2:
            dayOfWeek.text = "Monday"
            
        case 3:
            dayOfWeek.text = "Tuesday"
            
        case 4:
            dayOfWeek.text = "Wednesday"
            
        case 5:
            dayOfWeek.text = "Thursday"
            
        case 6:
            dayOfWeek.text = "Friday"
            
        case 7:
            dayOfWeek.text = "Saturday"
            
        default:
            dayOfWeek.text = "Hump Day"
        }
        
        if(liftsInWorkout.count == 1) {
            hasFinished = true
            nextButton.setTitle("Finished", for: [])
        }
        
        exerciseLabel.text = liftsInWorkout[i].name
        CompletedSetsLabel.text = String(liftsInWorkout[i].sets)
        CompletedRepsLabel.text = String(liftsInWorkout[i].reps)
        CompletedWeightLabel.text = String(liftsInWorkout[i].weight)
        
        if(liftsInWorkout.count == 1) {
            hasFinished = true
            nextButton.setTitle("Finished", for: [])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func nextExercise(_ sender: Any) {
        if(hasFinished == true){
            let viewControllers = self.navigationController!.viewControllers
            for aViewController in viewControllers
            {
                if aViewController is WorkoutHistoryTableViewController
                {
                    _ = self.navigationController?.popToViewController(aViewController, animated: true)
                }
            }
        }else{
            i += 1
            viewWillAppear(true)
            
            if(i == liftsInWorkout.count - 1){
                nextButton.setTitle("Finished", for: [])
                hasFinished = true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    
}
