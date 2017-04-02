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
        
        do{
           let exercise : Exercisei = try NSEntityDescription.insertNewObject(forEntityName: "Exercisei", into: CoreDataController.getContext()) as! Exercisei
        
            exercise.muscleGroup = muscle
            exercise.name = self.exercise
            exercise.sets = Int16(setsTextArea.text!)!
            exercise.reps = Int16(repsTextArea.text!)!
            exercise.weight = Int16(weightTextArea.text!)!
        }catch let error as NSError{
            print("\n\n\n\n\n\n\n\n")
            print(error)
        }
        
        CoreDataController.saveContext()
        
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
