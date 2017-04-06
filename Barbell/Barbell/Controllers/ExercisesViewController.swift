//
//  ExercisesViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 3/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class ExercisesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StatsViewControllerDelegate{
    @IBOutlet weak var exerciseTable: UITableView!
    var week : Int16!
    var day : String!
    var workout : Workout!
    var routinePassed : Routine!
    var foundLifts = [Lift]()
    
    var sets: Int!
    var reps: Int!
    var weight: Int!
    var muscle : String!
    var exercise : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(week)
        print(day)
        
        let newWorkout : Workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataController.getContext()) as! Workout
        newWorkout.weekday = day
        newWorkout.weeknumber = week
        //newWorkout.createdRoutine = routinePassed
        self.workout = newWorkout
        
        exerciseTable.delegate = self
        exerciseTable.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
    override func viewWillAppear(_ animated: Bool) {
        let context = CoreDataController.getContext()
        
        let fetchRequest = NSFetchRequest<Lift>(entityName: "Lift")
        do{
            foundLifts = workout.hasExercises?.allObjects as! [Lift]
        }catch{
            print("Bad getExercise query")
        }
        for lift in foundLifts{
            print(lift.muscleGroup)
        }
        
        exerciseTable.reloadData()
        return
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + foundLifts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if(indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "addExercise", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)
            cell?.textLabel?.text = foundLifts[indexPath.row-1].name
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            self.performSegue(withIdentifier: "loadExercisesSegue", sender: self)
        } else {
            sets = Int(foundLifts[indexPath.row-1].sets)
            reps = Int(foundLifts[indexPath.row-1].reps)
            weight = Int(foundLifts[indexPath.row-1].weight)
            muscle = foundLifts[indexPath.row-1].muscleGroup
            exercise = foundLifts[indexPath.row-1].name
            self.performSegue(withIdentifier: "holdMyBeer", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loadExercisesSegue"){
            let viewController = segue.destination as! AllExercisesTableViewController
            viewController.workout = workout
            viewController.routinePassed = routinePassed
        } else if(segue.identifier == "holdMyBeer") {
            let viewController = segue.destination as! StatsViewController
            viewController.reps = reps
            viewController.weight = weight
            viewController.sets = sets
            viewController.workout = workout
            viewController.muscle = muscle
            viewController.exercise = exercise
        }
        
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController){
            routinePassed.addToWorkouts(workout)
            print("backing up")
        }
    }
    
    func sendDataBackToHomePageViewController(routinePassed: Routine?, workoutPassed: Workout?) { //Custom delegate function which was defined inside child class to get the data and do the other stuffs.
        
        print(workout.weekday)
        print(routinePassed?.description)
        
        self.routinePassed = routinePassed
        self.workout = workoutPassed
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = indexPath.row-1
            print(row)
            if (row < foundLifts.count)
            {
                //this is where it needs to be removed from coredata
                let lift = foundLifts[row]
                foundLifts.remove(at: row)//remove from the array
                CoreDataController.getContext().delete(lift) //delete games from coredata
                
                do{
                    try CoreDataController.getContext().save()
                    
                } catch{
                    print("error occured saving context after deleting item")
                }
                
                if(foundLifts.count == 0) {
                    CoreDataController.getContext().delete(workout)
                }
            }
            
            
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
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
