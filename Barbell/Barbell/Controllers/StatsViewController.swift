//
//  StatsViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/30/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: UIViewController {

    @IBOutlet weak var setsTextArea: UITextField!
    @IBOutlet weak var repsTextArea: UITextField!
    @IBOutlet weak var weightTextArea: UITextField!
    @IBOutlet weak var muscleGroup: UILabel!
    @IBOutlet weak var exerciseName: UILabel!
    
    
    var muscle : String!
    var exercise : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        muscleGroup.text = muscle
        exerciseName.text = exercise
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveStats(_ sender: Any) {
        
        
           let lift : Lift = NSEntityDescription.insertNewObject(forEntityName: "Lift", into: CoreDataController.getContext()) as! Lift
        
            lift.muscleGroup = muscle
            lift.name = self.exercise
            lift.sets = Int16(setsTextArea.text!)!
            lift.reps = Int16(repsTextArea.text!)!
            lift.weight = Int16(weightTextArea.text!)!
      
        
        

        
        //CoreDataController.saveContext()
        
        self.dismiss(animated: true, completion: nil)
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
