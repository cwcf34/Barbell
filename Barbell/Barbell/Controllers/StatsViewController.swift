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

class StatsViewController: UIViewController {

    @IBOutlet weak var setsTextArea: UITextField!
    @IBOutlet weak var repsTextArea: UITextField!
    @IBOutlet weak var weightTextArea: UITextField!
    @IBOutlet weak var muscleGroup: UILabel!
    @IBOutlet weak var exerciseName: UILabel!
    
    weak var customDelegateForDataReturn: StatsViewControllerDelegate?
    
    
    var muscle : String!
    var exercise : String!
    var workout : Workout!
    var routinePassed : Routine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(muscle)
        print(exercise)
        print(workout.weeknumber)
        print(workout.weekday)
        
        muscleGroup.text = muscle
        exerciseName.text = exercise
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveStats(_ sender: Any) {
    
        let lift : Lift = NSEntityDescription.insertNewObject(forEntityName: "Lift", into: CoreDataController.getContext()) as! Lift
    
        lift.muscleGroup = muscle
        lift.name = self.exercise
        lift.sets = Int16(setsTextArea.text!)!
        lift.reps = Int16(repsTextArea.text!)!
        lift.weight = Int16(weightTextArea.text!)!
    
        workout.addToHasExercises(lift)
        
        CoreDataController.saveContext()
        
//        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as! [UIViewController];
//        for aViewController in viewControllers {
//            if(aViewController is ExercisesViewController){
//                let aVC = aViewController as! ExercisesViewController
//                aVC.day = workout.weekday
//                aVC.week = workout.weeknumber
//                self.navigationController!.popToViewController(aViewController, animated: true);
//            }
//        }
        
        print(workout.weekday)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "addExercisesSegue"){
//            var viewController = segue.destination as! ExercisesViewController
//            viewController.week = workout.weeknumber
//            viewController.day = workout.weekday
//            viewController.workout = workout
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
