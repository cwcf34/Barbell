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

class StartWorkoutTableViewController: UITableViewController {

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
    
    weak var customDelegateForDataReturn: StartWorkoutTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("starting workout " + String(workoutPassed.weeknumber) + " " + workoutPassed.weekday!)
        
        liftsInWorkout = workoutPassed.hasExercises?.allObjects as! [Lift]
        
        //Sort
        //liftsInWorkout.sort { Int($0.weekday!)! < Int($1.weekday!)! }
        //liftsInWorkout.sort { $0.weeknumber < $1.weeknumber }
        //
        for lift in liftsInWorkout {
            print(lift.muscleGroup!)
            print(lift.name!)
        }
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    @IBAction func nextExercise(_ sender: Any) {
        if(i + 1 < liftsInWorkout.count ){
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
            }
        }else{
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
                if aViewController is ExercisesViewController
                {
                    _ = self.navigationController?.popToViewController(aViewController, animated: true)
                }
            }
        }
        
        CompletedRepsTextArea.text = ""
        CompletedSetsTextArea.text = ""
        CompletedWeightTextArea.text = ""
        
        //TODO
        //this should take us to the next exercise for that workout
    }
    @IBAction func finishedWorkout(_ sender: Any) {
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
