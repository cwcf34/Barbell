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
    var routine : Routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataController.getContext()) as! Routine

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = CoreDataController.getContext()
        
        let fetchRequest = NSFetchRequest<Routine>(entityName: "Routine")
        do{
            foundRoutines = try context.fetch(fetchRequest)
            
        }catch{
            print("Bad getExercise query")
        }
        for routine in foundRoutines{
            print(routine.name)
        }
        
        self.tableView.reloadData()
        return
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
    
    /*func loadRoutines() -> [Routine]{
        
        
        //CoreData
        let fetchRequest = NSFetchRequest<Routine>(entityName: "Routine")
        do{
            let foundRoutine = try CoreDataController.getContext().fetch(fetchRequest)
            return foundRoutine
        }catch{
            print("we messed this up")
        }
        return [Routine]()
        
    }*/

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
    
    
    
    /*Logic for searching through workouts */
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        filterPlayers = allPlayers?.filter({ (players: Player) -> Bool in
//            return players.firstName?.lowercased().range(of: searchText.lowercased()) != nil
//        })
//        
//        if searchText != ""{
//            shouldShowSearch = true
//            self.tableView.reloadData()
//        }
//        else{
//            shouldShowSearch = false
//            self.tableView.reloadData()
//        }
//    }
//    
//    
//    func createSearchbar() {
//        searchBar.showsCancelButton = false
//        searchBar.placeholder = "Enter search"
//        searchBar.delegate = self
//        
//        self.navigationItem.titleView = searchBar
//    }
//    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar){
//        shouldShowSearch = true
//        searchBar.endEditing(true)
//        self.tableView.reloadData()
//    }
    
    /*End Search Logic*/

}
