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
    var day : Int16!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNewWorkout()
        //print(week)
        //print(day)
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
    
    func makeNewWorkout(){
        //let workout : Workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataController.getContext()) as! Workout
        //let lift : Lift = NSEntityDescription.insertNewObject(forEntityName: "Lift", into: CoreDataController.getContext()) as! Lift
        //workout.weekday = day
        //workout.weeknumber = week
        
        //CoreDataController.saveContext()
        
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
