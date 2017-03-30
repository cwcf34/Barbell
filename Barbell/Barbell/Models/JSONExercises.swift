//
//  JSONExercises.swift
//  Barbell
//
//  Created by Cody Cameron on 3/26/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation

public class JSONExercises {
    var muscleGroup: String = ""
    var exercises = [String]()
    
    init(muscleGroup: String, exercises: [String]) {
        self.muscleGroup = muscleGroup
        self.exercises = exercises
    }
}
