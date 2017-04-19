//
//  addWorkOutViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 3/9/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import CoreData

class addRoutineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var routine: UITextField!
    @IBOutlet weak var realTableView: UITableView!
    @IBOutlet weak var publicSwitch: UISwitch!
    
    var weeks = ["Week 1", "Week 2", "Week 3"]
    var value = 3
    var goingForwards : Bool!
    
    var user = [User]()
    var thisRoutine = Routine()
    var valueToPass : Int16!
    var routinePassed : Routine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goingForwards = false
        var count : Int = Int(routinePassed.numberOfWeeks)

        if (routinePassed.name != nil) {
            stepper.value = Double(value)
            //print("addRoutine received routine named: " + routinePassed.name!)
            routine.text = routinePassed.name
            if !routinePassed.isPublic {
                publicSwitch.setOn(false, animated: true)
            }
            
            while(value < count) {
                AddWeeks(nil)
                value += 1
                stepper.value = Double(value)
            }
        }
        else {
            routinePassed.name = routine.text
            if publicSwitch.isOn {
                //send to api!
                //not done yet!
                routinePassed.isPublic = true
            }
            else{
                routinePassed.isPublic = false
            }
            routinePassed.numberOfWeeks = Int16(weeks.count)
            //routinePassed.creator = String(user.first) + String(user.last)
            //routinePassed.addToUsers(user.first!)
            //user.first?.addToScheduleArr(routinePassed)
            
            thisRoutine = routinePassed
            stepper.value = Double(value)
        }
        
        
        //user = CoreDataController.getUser()
        
        realTableView.delegate = self
        realTableView.dataSource = self
        realTableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        goingForwards = false
        routine.text = routinePassed.name
        //self.value = Int(routinePassed.numberOfWeeks)
        
        
        if (routinePassed.isPublic == true){
            //send to api!
            //not done yet!
            publicSwitch.setOn(true, animated: true)
        }
        else{
            publicSwitch.setOn(false, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func AddWeeks(_ sender: Any?) {
        if(stepper.value < Double(value)) {
            deleteCell()
        } else {
            insert()
        }
        
        
        value = Int(stepper.value);
        
    }
    
    @IBAction func saveRoutine(_ sender: Any) {
        if(routine.text == ""){
            let notAllFormsFilled = UIAlertController(title: "Attention!", message: "Please provide a Routine name!", preferredStyle: UIAlertControllerStyle.alert)
            notAllFormsFilled.addAction(UIAlertAction(title: "Click here and fill out Routine name", style: UIAlertActionStyle.default, handler: nil))
            self.present(notAllFormsFilled, animated: true, completion: nil)
            return
        }

        let viewControllers = self.navigationController!.viewControllers
        for var aViewController in viewControllers
        {
            if aViewController is RoutineTableViewController
            {
                _ = self.navigationController?.popToViewController(aViewController, animated: true)
            }
        }
     }
    
    func insert() {
        weeks.append("Week \(weeks.count + 1)")
        
        let insertionIndexPath = IndexPath(row: weeks.count - 1, section: 0)
        realTableView.insertRows(at: [insertionIndexPath], with: .automatic)
        //realTableView.backgroundColor = UIColor(red: 62,green: 92,blue: 118)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeks.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.nameLabel.text = "Weeks " + String(indexPath.row + 1)
        cell.myTableViewController = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegueWithIdentifier("showQuestionnaire", sender: indexPath);
        valueToPass = Int16(indexPath.row) + 1
        saveRoutineInfo()
        self.performSegue(withIdentifier: "showWeekSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showWeekSegue"){
            goingForwards = true
            var viewController = segue.destination as! WeekTableViewController
            viewController.week = valueToPass
            viewController.routinePassed = routinePassed
        }
    }
    
    func deleteCell() {
        // First figure out how many sections there are
        let lastSectionIndex = realTableView.numberOfSections - 1
        
        // Then grab the number of rows in the last section
        let lastRowIndex = realTableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        // Now just construct the index path
        let pathToLastRow = IndexPath(row: lastRowIndex, section: lastSectionIndex)
    
        weeks.removeLast()
        realTableView.deleteRows(at: [pathToLastRow], with: .automatic)
        
    }
    
    func saveRoutineInfo() {
        routinePassed.name = routine.text
        if publicSwitch.isOn {
            //send to api!
            //not done yet!
            routinePassed.isPublic = true
        }
        else{
            routinePassed.isPublic = false
        }
        routinePassed.numberOfWeeks = Int16(weeks.count)
        routinePassed.creator = CoreDataController.getUser().fname! + " " + CoreDataController.getUser().lname!
        //routinePassed.addToUsers(user.first!)
        //user.first?.addToScheduleArr(routinePassed)
        
        thisRoutine = routinePassed
    }
    
     override func viewWillDisappear(_ animated: Bool) {
        if(goingForwards == false) {
            if publicSwitch.isOn {
                routinePassed.isPublic = true
            }
            else{
                routinePassed.isPublic = false
            }
            saveRoutineInfo()
            
            if(routinePassed.name == nil || routinePassed.name! == ""){
                CoreDataController.getContext().delete(routinePassed)
            } else {
                if routinePassed.isPublic == true {
                    if routinePassed.id <= 0 {
                        DataAccess.sendRoutineToRedis(routine: routinePassed)
                    }
                    else{
                        let redisRoutine = RedisRoutine(id: routinePassed.id)
                        DataAccess.deleteRoutineFromRedis(routine: redisRoutine)
                        DataAccess.editRoutineinRedis(routine: routinePassed)
                    }
                }
            }
            
            CoreDataController.saveContext()
        }
    }

}

class CustomCell: UITableViewCell {
    
    
    var myTableViewController: addRoutineViewController?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Item"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    func setupViews() {
        addSubview(nameLabel)

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
    }
    
}
