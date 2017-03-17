//
//  addWorkOutViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 3/9/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

class addWorkOutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var routine: UITextField!
    @IBOutlet weak var realTableView: UITableView!
    var weeks = ["Week 1", "Week 2", "Week 3"]
    var value = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        realTableView.delegate = self
        realTableView.dataSource = self
        realTableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")
        
        stepper.value = Double(value)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SaveRoutine(_ sender: Any) {
        //logic to send stuff to db
    }

    @IBAction func AddWeeks(_ sender: Any) {
        if(stepper.value < Double(value)) {
            deleteCell()
        } else {
            insert()
        }
        
        
        value = Int(stepper.value);
        
    }
    
    func insert() {
        weeks.append("Week \(weeks.count + 1)")
        
        let insertionIndexPath = IndexPath(row: weeks.count - 1, section: 0)
        realTableView.insertRows(at: [insertionIndexPath], with: .automatic)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeks.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.nameLabel.text = weeks[indexPath.row]
        cell.myTableViewController = self
        return cell
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
    

}

class CustomCell: UITableViewCell {
    
    
    var myTableViewController: addWorkOutViewController?
    
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
