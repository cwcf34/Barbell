//
//  AchievementsCollectionViewController.swift
//  Barbell
//
//  Created by Curtis Markway on 4/3/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class AchievementsCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    let cellIdentifiers:[String] = ["100","200","300", "1000", "1500"]
    
    
    let sizes:[CGSize] = [CGSize(width:100, height:100),CGSize(width:100, height:100),CGSize(width:100, height:100)]
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellIdentifiers.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers[indexPath.item], for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizes[indexPath.item]
    }
}
