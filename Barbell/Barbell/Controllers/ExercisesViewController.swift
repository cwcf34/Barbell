//
//  ExercisesViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 3/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class ExercisesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var exerciseTable: UITableView!
    var week : Int16!
    var day : String!
    var workout : Workout!
    var routinePassed : Routine!

    override func viewDidLoad() {
        super.viewDidLoad()
        print(week)
        print(day)
        
        let workout : Workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataController.getContext()) as! Workout
        self.workout = workout
        workout.weekday = day
        workout.weeknumber = week
        
        
        
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addExercise", for: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loadExercisesSegue"){
            var viewController = segue.destination as! AllExercisesTableViewController
            viewController.workout = workout
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
