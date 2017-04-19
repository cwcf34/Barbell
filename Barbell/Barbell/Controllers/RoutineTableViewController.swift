//
//  CreateWorkoutTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/7/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class RoutineTableViewController: UITableViewController, UISearchBarDelegate {
    
    var foundRoutines = [Routine]()
    var routine : Routine!
    var resultSearchController = UISearchController()
    var routineSearchResults = [Routine]()
    var didDelete: Bool!
    var shouldBeginEditing = true

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
    
    
    @IBAction func activateSearch(_ sender: Any) {
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.showsCancelButton = false
            controller.searchBar.delegate = self
            controller.searchBar.enablesReturnKeyAutomatically = true
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var validSearch = true
        //check for nil search text
        if let query = searchBar.text {
            if (query.contains(" ") ){
                let badSearch = query.trimmingCharacters(in: .whitespaces)
                if (badSearch.characters.count < 1) {
                    //alert you must enter text
                    let alertCont: UIAlertController = UIAlertController(title: "Uh Oh!", message: "Please enter a search string.", preferredStyle: .alert)
                    
                    // set the confirm action
                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    // add confirm button to alert
                    alertCont.addAction(confirmAction)
                    self.present(alertCont, animated: true, completion: nil)
                    validSearch = false
                }
            }
            
            if (validSearch) {
                routineSearchResults = DataAccess.searchRoutinesInRedis(query)
            }
        }
        
        //dismiss search bar
        resultSearchController.dismiss(animated: true, completion: nil)
        
        //myfingersarefallingasleep\\ //beansinmyfings\\
        //reset valid search flag
        validSearch = true
        tableView.reloadData()
    }
    
    func handleClearOrCancel() {
       
        //reset editing var
        shouldBeginEditing = false
        
        for routine in routineSearchResults {
            CoreDataController.getContext().delete(routine)
        }
        
        //clear search results array
        routineSearchResults = [Routine]()
        
        //dismiss search bar
        //resultSearchController.dismiss(animated: true, completion: nil)
        
        //user hit clear button
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchBar.isFirstResponder){
            //reset editing var
            handleClearOrCancel()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        handleClearOrCancel()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // reset the shouldBeginEditing BOOL
        let boolToReturn = shouldBeginEditing
        shouldBeginEditing = true
        return boolToReturn
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (routineSearchResults.count == 0){
            return 1 + foundRoutines.count
        }else {
            return 1 + routineSearchResults.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if(indexPath.row == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "addWorkout", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
            
            if (routineSearchResults.count == 0){
                cell?.textLabel?.text = foundRoutines[indexPath.row-1].name
            }else{
                cell?.textLabel?.text = routineSearchResults[indexPath.row-1].name
            }

        }

        
        return cell!
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            let routineObject : Routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataController.persistentContainer.viewContext) as! Routine
            routine = routineObject
            
            //if searching, then click add
            //remove the searched routines
            handleClearOrCancel()
            
            self.performSegue(withIdentifier: "addRoutineSegue", sender: self)
        } else {
            if (routineSearchResults.count == 0) {
                routine = foundRoutines[indexPath.row-1]
            
                self.performSegue(withIdentifier: "startRoutineSegue", sender: self)
            }else {
                routine = routineSearchResults[indexPath.row-1]
                //perform segue to do somwthing w someonelse's routine
            }
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
            let routineObject = self.foundRoutines[indexPath.row-1]
            self.routine = routineObject
            
            self.performSegue(withIdentifier: "addRoutineSegue", sender: self)
        }
        
        edit.backgroundColor = UIColor.blue
        
        if (routineSearchResults.count == 0) {
            return [delete, edit]
    
        }else{
            return []
        }
        
    }
}
