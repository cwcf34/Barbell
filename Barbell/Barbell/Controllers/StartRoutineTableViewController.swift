//
//  StartRoutineTableViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 4/2/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class StartRoutineTableViewController: UITableViewController {

    var routinePassed : Routine!
    var workoutsInRoutine = [Workout]()
    var workoutToPass : Workout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print("starting routine " + routinePassed.name!)
        
        workoutsInRoutine = routinePassed.workouts?.allObjects as! [Workout]
        
        //Sort
        workoutsInRoutine.sort { Int($0.weekday!)! < Int($1.weekday!)! }
        workoutsInRoutine.sort { $0.weeknumber < $1.weeknumber }
        
        for workout in workoutsInRoutine {
            print(workout.weeknumber)
            print(workout.weekday)
        }
        
        //workoutsInRoutine = Workout(context: routinePassed.workouts)
        //for workout in routinePassed.workouts! {
        //    print(workout)
            //print((workout as Workout).weekday)
            //print((workout as Workout).weeknumber)
        //    workoutsInRoutine.append(workout as! Workout)
        //}
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Int(routinePassed.numberOfWeeks)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var count : Int = 0
        
        for workout in workoutsInRoutine {
            if(Int(workout.weeknumber) == section+1) {
                count += 1
            }
        }
        
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        
        
        switch (Int(workoutsInRoutine[indexPath.section+indexPath.row].weekday!)!)
        {
        case 1:
            cell.textLabel?.text = "Sunday Funday"
            
        case 2:
            cell.textLabel?.text = "Messed up Monday"
            
        case 3:
            cell.textLabel?.text = "Tequila Tuesday"
            
        case 4:
            cell.textLabel?.text = "Wasted Wednesday"
            
        case 5:
            cell.textLabel?.text = "Thirsty Thursday"
            
        case 6:
            cell.textLabel?.text = "Fucked up Friday"
            
        case 7:
            cell.textLabel?.text = "Shitfaced Saturday"
            
        default:
            cell.textLabel?.text = "Hump Day"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Week " + String(section+1)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        workoutToPass = workoutsInRoutine[indexPath.section+indexPath.row]
        self.performSegue(withIdentifier: "startWorkoutSegue", sender: self)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "startWorkoutSegue"){
            var viewController = segue.destination as! StartWorkoutTableViewController
            viewController.workoutPassed = workoutToPass
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
