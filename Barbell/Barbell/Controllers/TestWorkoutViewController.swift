//
//  TestWorkoutViewController.swift
//  Barbell
//
//  Created by Caleb Albertson on 3/3/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

class TestWorkoutViewController: UIViewController {

    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createWorkout(_ sender: Any) {
        if(idTextField.hasText && nameTextField.hasText && weightTextField.hasText) {
    
            let workoutModel = WorkoutModel.init(id: Int(idTextField.text!)!, name: nameTextField.text!, weight: Int(weightTextField.text!)!)
            
            print(workoutModel.name)
            //let dbResponse = DataAccess.createWorkout(workoutModel: workoutModel);
            //print(dbResponse)
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
}
