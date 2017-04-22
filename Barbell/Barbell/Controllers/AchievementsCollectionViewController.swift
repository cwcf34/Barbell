//
//  AchievementsCollectionViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 4/3/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

let reuseIdentifier = "MyCell"
var carImages = ["100.png",
                 "200.png",
                 "300.png",
                 "1000.png",
                 "1500.png"]

var carImagesNotDone = ["100ND.png",
                 "200ND.png",
                 "300ND.png",
                 "1000ND.png",
                 "1500ND.png"]

var imageTitles = ["100 Workouts",
                    "200 Workouts",
                    "300 Workouts",
                    "1000 Workouts",
                    "1500 Workouts"]

class AchievementsCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(carImages.count)
        return carImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        
        // Configure the cell
        let image = UIImage(named: carImages[indexPath.row])
        cell.imageView.image = image
        cell.label.text = imageTitles[indexPath.row]
        
        return cell
    }
}
