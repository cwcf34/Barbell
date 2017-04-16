//
//  StartWorkoutViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 4/15/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

protocol StartWorkoutTableViewControllerDelegate: class { //Setting up a Custom delegate for this class. I am using `class` here to make it weak.
    func sendDataBackToHomePageViewController(routinePassed: Routine?) //This function will send the data back to origin viewcontroller.
}

class StartWorkoutViewController: UIViewController {

    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var liftSets: UILabel!
    @IBOutlet weak var liftReps: UILabel!
    @IBOutlet weak var liftWeight: UILabel!
    @IBOutlet weak var setsCompletedText: UITextField!
    @IBOutlet weak var repsCompleteedText: UITextField!
    @IBOutlet weak var weightCompletedText: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var workoutPassed : Workout!
    var routinePassed : Routine!
    var liftsInWorkout = [Lift]()
    var i = 0
    var hasFinished = false
    
    weak var customDelegateForDataReturn: StartWorkoutTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        liftsInWorkout = workoutPassed.hasExercises?.allObjects as! [Lift]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch (Int(workoutPassed.weeknumber))
        {
        case 1:
            weekDayLabel.text = "Sunday"
            
        case 2:
            weekDayLabel.text = "Monday"
            
        case 3:
            weekDayLabel.text = "Tuesday"
            
        case 4:
            weekDayLabel.text = "Wednesday"
            
        case 5:
            weekDayLabel.text = "Thursday"
            
        case 6:
            weekDayLabel.text = "Friday"
            
        case 7:
            weekDayLabel.text = "Saturday"
            
        default:
            weekDayLabel.text = "Hump Day"
        }
        
        exerciseLabel.text = liftsInWorkout[i].name
        liftSets.text = String(liftsInWorkout[i].sets)
        liftReps.text = String(liftsInWorkout[i].reps)
        liftWeight.text = String(liftsInWorkout[i].weight)
    
        if(liftsInWorkout.count == 1) {
            hasFinished = true
            nextButton.setTitle("Finished", for: [])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func next(_ sender: Any) {
        if(hasFinished == true){
            let finished : LegacyLift = NSEntityDescription.insertNewObject(forEntityName: "LegacyLift", into: CoreDataController.getContext()) as! LegacyLift
            finished.liftName = liftsInWorkout[i].name
            finished.liftRep = liftsInWorkout[i].reps
            finished.liftSets = liftsInWorkout[i].sets
            finished.liftWeight = liftsInWorkout[i].weight
            finished.timeStamp = Date() as NSDate
            
            CoreDataController.saveContext()
            
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
            let finished : LegacyLift = NSEntityDescription.insertNewObject(forEntityName: "LegacyLift", into: CoreDataController.getContext()) as! LegacyLift
            finished.liftName = liftsInWorkout[i].name
            finished.liftRep = liftsInWorkout[i].reps
            finished.liftSets = liftsInWorkout[i].sets
            finished.liftWeight = liftsInWorkout[i].weight
            finished.timeStamp = Date() as NSDate
            
            CoreDataController.saveContext()
            
            if(i == liftsInWorkout.count - 1){
                nextButton.setTitle("Finished", for: [])
                hasFinished = true
            }
        }
        
        repsCompleteedText.text = ""
        setsCompletedText.text = ""
        weightCompletedText.text = ""
    }

}
