//
//  addWorkOutViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 3/9/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

class addWorkOutViewController: UIViewController {

    @IBOutlet weak var routine: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func SaveRoutine(_ sender: Any) {
        //logic to send stuff to db
    }

    @IBAction func AddWeeks(_ sender: Any) {
        
    }
}
