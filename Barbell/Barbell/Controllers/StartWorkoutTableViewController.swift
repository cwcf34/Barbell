//
//  StartRoutineTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/30/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

protocol StartWorkoutTableViewControllerDelegate: class { //Setting up a Custom delegate for this class. I am using `class` here to make it weak.
    func sendDataBackToHomePageViewController(routinePassed: Routine?) //This function will send the data back to origin viewcontroller.
}

class StartWorkoutTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var DayOfTheWeek: UILabel!
    @IBOutlet weak var RountineExerciseLabel: UILabel!
    @IBOutlet weak var RountineSetsLabel: UILabel!
    @IBOutlet weak var RountineRepsLabel: UILabel!
    @IBOutlet weak var RountineWeightLabel: UILabel!
    @IBOutlet weak var CompletedSetsTextArea: UITextField!
    @IBOutlet weak var CompletedRepsTextArea: UITextField!
    @IBOutlet weak var CompletedWeightTextArea: UITextField!
    var workoutPassed : Workout!
    var routinePassed : Routine!
    var liftsInWorkout = [Lift]()
    var i = 0
    var hasFinished = false
    
    weak var customDelegateForDataReturn: StartWorkoutTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CompletedSetsTextArea.delegate = self
        CompletedRepsTextArea.delegate = self
        CompletedWeightTextArea.delegate = self
        
        liftsInWorkout = workoutPassed.hasExercises?.allObjects as! [Lift]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        switch (Int(workoutPassed.weeknumber))
        {
            case 1:
                DayOfTheWeek.text = "Sunday"
                
            case 2:
                DayOfTheWeek.text = "Monday"
                
            case 3:
                DayOfTheWeek.text = "Tuesday"
                
            case 4:
                DayOfTheWeek.text = "Wednesday"
                
            case 5:
                DayOfTheWeek.text = "Thursday"
                
            case 6:
                DayOfTheWeek.text = "Friday"
                
            case 7:
                DayOfTheWeek.text = "Saturday"
                
            default:
                DayOfTheWeek.text = "Hump Day"
        }
        
        RountineExerciseLabel.text = liftsInWorkout[i].name
        RountineSetsLabel.text = String(liftsInWorkout[i].sets)
        RountineRepsLabel.text = String(liftsInWorkout[i].reps)
        RountineWeightLabel.text = String(liftsInWorkout[i].weight)
        print("\n\n")
        print(liftsInWorkout[i].weight)
        
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
            CoreDataController.maybeSaveHistory(name: liftsInWorkout[i].name!, reps: liftsInWorkout[i].reps, sets: liftsInWorkout[i].sets, weight: liftsInWorkout[i].weight)
        
            
            customDelegateForDataReturn?.sendDataBackToHomePageViewController(routinePassed: routinePassed)
            
            let viewControllers = self.navigationController!.viewControllers
            for var aViewController in viewControllers
            {
                if aViewController is RoutineTableViewController
                {
                    _ = self.navigationController?.popToViewController(aViewController, animated: true)
                }
            }
        }else{
            i += 1
            viewWillAppear(true)
            CoreDataController.maybeSaveHistory(name: liftsInWorkout[i].name!, reps: liftsInWorkout[i].reps, sets: liftsInWorkout[i].sets, weight: liftsInWorkout[i].weight)
            
            if(i == liftsInWorkout.count - 1){
                nextButton.setTitle("Finished", for: [])
                hasFinished = true
            }

        }
        
        CompletedRepsTextArea.text = ""
        CompletedSetsTextArea.text = ""
        CompletedWeightTextArea.text = ""
        
        
        //TODO
        //this should take us to the next exercise for that workout
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    

}
