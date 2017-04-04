//
//  AllExercisesTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/26/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

class AllExercisesTableViewController: UITableViewController, UISearchResultsUpdating {
    
    

    var filteredTableData = [JSONExercises]()
    var allLifts = [String]()
    var resultSearchController = UISearchController()
    var allExercises = [JSONExercises]()
    var valueToPass : String = ""
    var exerciseToPass : String = ""
    var workout : Workout!
    var routinePassed: Routine!

    func readJSONObject(object: [String: AnyObject]) {
        var exerciseNames = [String]()
        
        guard let exercises = object["Exercises"] as? [[String: AnyObject]] else { return }
        
        for exercise in exercises {
            guard let group = exercise["group"] as? String,
                let lifts = exercise["lifts"] as? [String] else { break }
                //print(group)
            
            for lift in lifts {
                guard let test = lift as? String else { break }
                //print(test)
                exerciseNames.append(test)
            }
            
            let allExercise = JSONExercises(muscleGroup: group, exercises: exerciseNames)
            allExercises.append(allExercise)
            exerciseNames.removeAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(workout.weekday)
        
        let url = Bundle.main.url(forResource: "workouts", withExtension: "json")
        let data = NSData(contentsOf: url!)
        
        do {
            print("loading view...")
            let object = try JSONSerialization.jsonObject(with: data as! Data, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(object: dictionary)
            }
        } catch {
            print("Error")
        }
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        self.tableView.reloadData()
        
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
        if (self.resultSearchController.isActive) {
            return self.filteredTableData.count
        }
        else {
            return allExercises.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (self.resultSearchController.isActive) {
            return self.filteredTableData[section].exercises.count
        }
        else {
            return allExercises[section].exercises.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)

        // 3
        if (self.resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.section].exercises[indexPath.row]
            
            return cell
        }
        else {
            cell.textLabel?.text = allExercises[indexPath.section].exercises[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.resultSearchController.isActive) {
            return filteredTableData[section].muscleGroup
        }
        else {
            return allExercises[section].muscleGroup
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        valueToPass = allExercises[indexPath.section].muscleGroup
        exerciseToPass = allExercises[indexPath.section].exercises[indexPath.row]
        
        self.performSegue(withIdentifier: "addStatsSegue", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addStatsSegue"){
            var viewController = segue.destination as! StatsViewController
            viewController.muscle = valueToPass
            viewController.exercise = exerciseToPass
            viewController.workout = workout
            viewController.routinePassed = routinePassed
        }
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        var exerciseNames = [String]()
        
        for index in 0...allExercises.count-1 {
            let array = (allExercises[index].exercises as NSArray).filtered(using: searchPredicate)
            
            for name in array {
                exerciseNames.append(name as! String)
            }
            
            if(array.count != 0) {
                let allExercise = JSONExercises(muscleGroup: allExercises[index].muscleGroup, exercises: exerciseNames)
                filteredTableData.append(allExercise)
            }
                exerciseNames.removeAll()
        }
        
//        print(filteredTableData.count)
//        for index in 0...filteredTableData.count-1 {
//            for string in filteredTableData[index].exercises {
//                print(string)
//            }
//        }
        self.tableView.reloadData()
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
