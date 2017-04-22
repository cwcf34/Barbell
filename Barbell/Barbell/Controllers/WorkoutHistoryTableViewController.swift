//
//  StartRoutineTableViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 4/2/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class WorkoutHistoryTableViewController: UITableViewController, StartWorkoutViewControllerDelegate {
    var routinePassed : Routine!
    var workoutsInRoutine = [Workout]()
    var workoutToPass : Workout!
    var isSorted : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("starting routine " + routinePassed.name!)
        
        workoutsInRoutine = routinePassed.workouts?.allObjects as! [Workout]
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if(isSorted == false) {
            workoutsInRoutine.sort { Int($0.weekday!)! < Int($1.weekday!)! }
            workoutsInRoutine.sort { $0.weeknumber < $1.weeknumber }
            
            for workout in workoutsInRoutine {
                print(workout.weeknumber)
                print(workout.weekday)
            }
        }
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
    func sendDataBackToHomePageViewController(routinePassed: Routine?) {
        self.routinePassed = routinePassed
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var count : Int = 0
        for workout in workoutsInRoutine {
            if(Int(workout.weeknumber) < indexPath.section+1) {
                count += 1
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        
        switch (Int(workoutsInRoutine[count+indexPath.row].weekday!)!)
        {
        case 1:
            cell.textLabel?.text = "Sunday"
            
        case 2:
            cell.textLabel?.text = "Monday"
            
        case 3:
            cell.textLabel?.text = "Tuesday"
            
        case 4:
            cell.textLabel?.text = "Wednesday"
            
        case 5:
            cell.textLabel?.text = "Thursday"
            
        case 6:
            cell.textLabel?.text = "Friday"
            
        case 7:
            cell.textLabel?.text = "Saturday"
            
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
        self.performSegue(withIdentifier: "exerciseHistory", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "exerciseHistory"){
            var viewController = segue.destination as! ExerciseHistoryViewController
            viewController.workoutPassed = workoutToPass
            viewController.routinePassed = self.routinePassed
        }
    }
    
}
