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
                    "1000 Pound Club",
                    "1500 Pound Club"]

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
        return carImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
        let achievements = CoreDataController.getAchievements()

        cell.label.text = imageTitles[indexPath.row]
    
        for achievement in achievements {
            if(achievement.achievementNumber == indexPath.row+1){
                cell.imageView.image = UIImage(named: carImages[indexPath.row])
            }else{
                print("\n\nTesting does " + String(achievement.achievementNumber) + " equals " + String(indexPath.row+1))
                cell.imageView.image = UIImage(named: carImagesNotDone[indexPath.row])
            }
        }
        
//        for integer in achievements{
//            if(achievement.achievementNumber == 1){
//                cell.imageView.image = UIImage(named: carImages[0])
//            }else{
//                cell.imageView.image = UIImage(named: carImagesNotDone[0])
//            }
//            if(achievement.achievementNumber == 2){
//                cell.imageView.image = UIImage(named: carImages[1])
//            }else{
//                cell.imageView.image = UIImage(named: carImagesNotDone[1])
//            }
//            if(achievement.achievementNumber == 3){
//                cell.imageView.image = UIImage(named: carImages[2])
//            }else{
//                cell.imageView.image = UIImage(named: carImagesNotDone[2])
//            }
//            if(achievement.achievementNumber == 4){
//                cell.imageView.image = UIImage(named: carImages[3])
//            }else{
//                cell.imageView.image = UIImage(named: carImagesNotDone[3])
//            }
//            if(achievement.achievementNumber == 5){
//                cell.imageView.image = UIImage(named: carImages[4])
//            }else{
//                cell.imageView.image = UIImage(named: carImagesNotDone[4])
//            }
//        }
        
        
        return cell
    }
}
