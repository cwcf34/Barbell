//
//  StartRoutineTableViewController.swift
//  Barbell
//
//  Created by Cody Cameron on 3/30/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

protocol ExerciseHistoryViewControllerDelegate: class { //Setting up a Custom delegate for this class. I am using `class` here to make it weak.
    func sendDataBackToHomePageViewController(routinePassed: Routine?) //This function will send the data back to origin viewcontroller.
}

class ExerciseHistoryViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var CompletedSetsLabel: UILabel!
    @IBOutlet weak var CompletedRepsLabel: UILabel!
    @IBOutlet weak var CompletedWeightLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var yAxis1: UILabel!
    @IBOutlet weak var yAxis2: UILabel!
    @IBOutlet weak var yAxis3: UILabel!
    @IBOutlet weak var yAxis4: UILabel!
    
    
    var workoutPassed : Workout!
    var routinePassed : Routine!
    var liftsInWorkout = [Lift]()
    var historyData = [LegacyLift]()
    var user : User!
    var i = 0
    var hasFinished = false
    
    var list: [CGRect] = []
    var adjList = AdjList()
    var weightLifted = [135,150,175,140,145]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = CoreDataController.getUser()
        
        liftsInWorkout = workoutPassed.hasExercises?.allObjects as! [Lift]
        print(liftsInWorkout)
        
        //get first graph
        if let firstLift = liftsInWorkout.first {
            getGraphData(pastLift: firstLift.name!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch (Int(workoutPassed.weeknumber))
        {
        case 1:
            dayOfWeek.text = "Sunday"
            
        case 2:
            dayOfWeek.text = "Monday"
            
        case 3:
            dayOfWeek.text = "Tuesday"
            
        case 4:
            dayOfWeek.text = "Wednesday"
            
        case 5:
            dayOfWeek.text = "Thursday"
            
        case 6:
            dayOfWeek.text = "Friday"
            
        case 7:
            dayOfWeek.text = "Saturday"
            
        default:
            dayOfWeek.text = "Hump Day"
        }
        
        if(liftsInWorkout.count == 1) {
            hasFinished = true
            nextButton.setTitle("Finished", for: [])
        }
        
        exerciseLabel.text = liftsInWorkout[i].name
        CompletedSetsLabel.text = String(liftsInWorkout[i].sets)
        CompletedRepsLabel.text = String(liftsInWorkout[i].reps)
        CompletedWeightLabel.text = String(liftsInWorkout[i].weight)
        
        
        
        if(liftsInWorkout.count == 1) {
            hasFinished = true
            nextButton.setTitle("Finished", for: [])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGraphData(pastLift: String) {
        if let user = user {
            
            //saves all the legacy lifts
            historyData = DataAccess.getHistoryfromRedis(email: user.email!, pastlift: pastLift)
            
            createGraph(num: weightLifted.count, offsetX: 315/weightLifted.count, offsetY: 315/4, width: 10, height: 10, weightLifted: weightLifted)
            
            adjList.setList(list)
            
            graphView.setList(data: adjList.adjacencyList)
            graphView.draw(CGRect.init(x: 0, y: 0, width: 0, height: 0))
            
        }
    }
    
    func createGraph(num: Int, offsetX: Int, offsetY: Int, width: Int, height: Int, weightLifted: [Int] ){
        
        var newWeight = [Int]()
        var percentageRange = [Int]()
        var pix = [Int]()
        
        if var lowest = weightLifted.first {
            
            //get lowest
            for weight in weightLifted {
                
                if( weight < lowest){
                    lowest = weight
                }
            }
            
            //label y axis with 4 scaling
            var s1 = (lowest * 2)/3
            var s2 = s1 * 2
            var s3 = s1 * 3
            var s4 = s1 * 4
            
            yAxis1.text = s1.description
            yAxis2.text = s2.description
            yAxis3.text = s3.description
            yAxis4.text = s4.description
            
            //new range
            var range = s4 - s1
            
            for weight in weightLifted{
                newWeight.append( weight - s1)
            }
            
            for weight in newWeight{
                var percent = (weight*100/range)
                percentageRange.append(percent)
            }
            
            for percent in percentageRange{
                let newPoint = 315 - ((percent*315)/100)
                pix.append(newPoint)
            }
        }
        
        
        var x = 5
        var y = 315
        
        list.append(CGRect.init(x: x, y: y, width: width, height: height))
        
        for i in 0..<num {
            x += offsetX
            let point = CGRect(x: x, y: pix[i], width: width, height: height)
            list.append(point)
        }
    }

    @IBAction func nextExercise(_ sender: Any) {
        
        if(hasFinished == true){
            let viewControllers = self.navigationController!.viewControllers
            for aViewController in viewControllers
            {
                if aViewController is WorkoutHistoryTableViewController
                {
                    _ = self.navigationController?.popToViewController(aViewController, animated: true)
                }
            }
        }else{
            i += 1
            viewWillAppear(true)
            
            getGraphData(pastLift: liftsInWorkout[i].name!)
            
            if(i == liftsInWorkout.count - 1){
                nextButton.setTitle("Finished", for: [])
                hasFinished = true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    
}
