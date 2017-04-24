//
//  CreateWorkoutTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/7/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    var foundRoutines = [Routine]()
    var routine : Routine!
    var routineSearchResults = [Routine]()
    var didDelete: Bool!
    var shouldBeginEditing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //might see if we can get to the hex color
        
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = CoreDataController.getContext()
        didDelete = false
        
        let fetchRequest = NSFetchRequest<Routine>(entityName: "Routine")
        do{
            foundRoutines = try context.fetch(fetchRequest)
            var counter = 0
            for foundRoutine in foundRoutines{
                /*
                if foundRoutine.isFinished == false{
                    foundRoutines.remove(at: counter)
                }
                else{
                    counter += 1
                }*/
            }
 
        }catch{
            print("Bad getExercise query")
        }
        for routine in foundRoutines{
            if(routine.name == nil || routine.name == "") {
                CoreDataController.getContext().delete(routine)
                didDelete = true;
                break;
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            return foundRoutines.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
        print(indexPath.row-1)
        cell?.textLabel?.text = foundRoutines[indexPath.row].name
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                routine = foundRoutines[indexPath.row]
                self.performSegue(withIdentifier: "finishedWorkouts", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "finishedWorkouts"){
            let viewController = segue.destination as! WorkoutHistoryTableViewController
            viewController.routinePassed = routine
        }
    }
}
