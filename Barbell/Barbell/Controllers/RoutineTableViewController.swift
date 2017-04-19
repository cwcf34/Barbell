//
//  CreateWorkoutTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/7/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class RoutineTableViewController: UITableViewController {
    
    var foundRoutines = [Routine]()
    var routine : Routine!
    var didDelete: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = CoreDataController.getContext()
        didDelete = false
        
        let fetchRequest = NSFetchRequest<Routine>(entityName: "Routine")
        do{
            foundRoutines = try context.fetch(fetchRequest)
            
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
        
        if(didDelete == true) {
            let fetchRequest = NSFetchRequest<Routine>(entityName: "Routine")
            do{
                foundRoutines = try context.fetch(fetchRequest)
                
            }catch{
                print("Bad getExercise query")
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
        
        return 1 + foundRoutines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if(indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "addWorkout", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
            cell?.textLabel?.text = foundRoutines[indexPath.row-1].name
        }
        
        return cell!
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            let routineObject : Routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataController.persistentContainer.viewContext) as! Routine
            routine = routineObject
            
            self.performSegue(withIdentifier: "addRoutineSegue", sender: self)
        } else {
            routine = foundRoutines[indexPath.row-1]
            
            self.performSegue(withIdentifier: "startRoutineSegue", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addRoutineSegue"){
            var viewController = segue.destination as! addRoutineViewController
            viewController.routinePassed = routine
        }
        
        if (segue.identifier == "startRoutineSegue"){
            var viewController = segue.destination as! StartRoutineTableViewController
            viewController.routinePassed = routine
        }
    }
    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let row = indexPath.row-1
//            print(row)
//            if (row < foundRoutines.count)
//            {
//                //this is where it needs to be removed from coredata
//                let deleteRoutine = foundRoutines[row]
//                foundRoutines.remove(at: row)//remove from the array
//                CoreDataController.getContext().delete(deleteRoutine) //delete games from coredata
//                
//                do{
//                    try CoreDataController.getContext().save()
//                    
//                } catch{
//                    print("error occured saving context after deleting item")
//            }
//        }
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let row = indexPath.row-1
            if (row < self.foundRoutines.count)
            {
                //this is where it needs to be removed from coredata
                let deleteRoutine = self.foundRoutines[row]
                self.foundRoutines.remove(at: row)//remove from the array
                CoreDataController.getContext().delete(deleteRoutine) //delete games from coredata

                do{
                    try CoreDataController.getContext().save()

                } catch{
                    print("error occured saving context after deleting item")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let routineObject : Routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataController.persistentContainer.viewContext) as! Routine
            self.routine = routineObject
            
            self.performSegue(withIdentifier: "addRoutineSegue", sender: self)
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
}
