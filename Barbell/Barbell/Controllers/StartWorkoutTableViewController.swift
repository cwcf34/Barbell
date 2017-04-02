//
//  StartRoutineTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/30/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

class StartWorkoutTableViewController: UITableViewController {

    @IBOutlet weak var DayOfTheWeek: UILabel!
    @IBOutlet weak var RountineExerciseLabel: UILabel!
    @IBOutlet weak var RountineSetsLabel: UILabel!
    @IBOutlet weak var RountineRepsLabel: UILabel!
    @IBOutlet weak var RountineWeightLabel: UILabel!
    @IBOutlet weak var CompletedExerciseLabel: UILabel!
    @IBOutlet weak var CompletedSetsTextArea: UITextField!
    @IBOutlet weak var CompletedRepsTextArea: UITextField!
    @IBOutlet weak var CompletedWeightTextArea: UITextField!
    var workoutPassed : Workout!
    var liftsInWorkout : Lift!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    /*    print("starting workout " + workoutPassed.weeknumber + " " + workoutPassed.weekday)
        
        liftsInWorkout = workoutPassed.workouts?.allObjects as! [Workout]
        
        //Sort
        workoutsInRoutine.sort { Int($0.weekday!)! < Int($1.weekday!)! }
        workoutsInRoutine.sort { $0.weeknumber < $1.weeknumber }
        
        for workout in workoutsInRoutine {
            print(workout.weeknumber)
            print(workout.weekday)
        }*/
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
        //TODO
        //this should take us to the next exercise for that workout
    }
    @IBAction func finishedWorkout(_ sender: Any) {
        //TODO
        //this needs to calculate the time that it took for a workout to finish
        //should segue back to the routine view
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
