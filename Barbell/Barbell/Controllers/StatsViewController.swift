//
//  StatsViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/30/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

protocol StatsViewControllerDelegate: class { //Setting up a Custom delegate for this class. I am using `class` here to make it weak.
    func sendDataBackToHomePageViewController(routinePassed: Routine?, workoutPassed: Workout?) //This function will send the data back to origin viewcontroller.
}

class StatsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var setsTextArea: UITextField!
    @IBOutlet weak var repsTextArea: UITextField!
    @IBOutlet weak var weightTextArea: UITextField!
    @IBOutlet weak var muscleGroup: UILabel!
    @IBOutlet weak var exerciseName: UILabel!
    
    weak var customDelegateForDataReturn: StatsViewControllerDelegate?
    
    
    var muscle : String = ""
    var exercise : String = ""
    var workout : Workout!
    var routinePassed : Routine!
    var sets: Int = 0
    var reps: Int = 0
    var weight: Int = 0
    var lift : Lift?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        muscleGroup.text = muscle
        exerciseName.text = exercise
        
        
        setsTextArea.delegate = self
        repsTextArea.delegate = self
        weightTextArea.delegate = self
        
        
        if(sets != 0 && reps != 0 && weight != 0) {
            exerciseName.text = exercise
            muscleGroup.text =  muscle
            setsTextArea.text = String(sets)
            repsTextArea.text = String(reps)
            weightTextArea.text = String(weight)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveStats(_ sender: Any) {
    
        if(sets != 0 && reps != 0 && weight != 0 && muscle != "" && exercise != "") {
            lift?.muscleGroup = muscle
            lift?.name = self.exercise
            lift?.sets = Int16(setsTextArea.text!)!
            lift?.reps = Int16(repsTextArea.text!)!
            lift?.weight = Int16(weightTextArea.text!)!
            
            print("\n\n\n")
            print(lift?.weight)
            
            CoreDataController.saveContext()
        }else{
            let newLift : Lift = NSEntityDescription.insertNewObject(forEntityName: "Lift", into: CoreDataController.getContext()) as! Lift
    
            newLift.muscleGroup = muscle
            newLift.name = self.exercise
            newLift.sets = Int16(setsTextArea.text!)!
            newLift.reps = Int16(repsTextArea.text!)!
            newLift.weight = Int16(weightTextArea.text!)!
            
            print("\n\n\n")
            print(newLift.weight)
            
            workout.addToHasExercises(newLift)
            
            CoreDataController.saveContext()
        }
        

        
//        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as! [UIViewController];
//        for aViewController in viewControllers {
//            if(aViewController is ExercisesViewController){
//                let aVC = aViewController as! ExercisesViewController
//                aVC.day = workout.weekday
//                aVC.week = workout.weeknumber
//                self.navigationController!.popToViewController(aViewController, animated: true);
//            }
//        }
        
        customDelegateForDataReturn?.sendDataBackToHomePageViewController(routinePassed: routinePassed, workoutPassed: self.workout)
        
        let viewControllers = self.navigationController!.viewControllers
        for var aViewController in viewControllers
        {
            if aViewController is ExercisesViewController
            {
                _ = self.navigationController?.popToViewController(aViewController, animated: true)
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
