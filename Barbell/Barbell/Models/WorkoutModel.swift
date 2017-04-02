//
//  WorkoutModel.swift
//  Barbell
//
//  Created by Caleb Albertson on 3/3/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation

public class WorkoutModel {
    var id: Int
    var name: String
    var weight: Int
    
    init(id: Int, name: String, weight: Int) {
        self.id = id
        self.name = name
        self.weight = weight    }
}
