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
    var workout : Workout
    
    init(id: Int, workout: Workout) {
        self.id = id
        self.workout = workout   }
}
