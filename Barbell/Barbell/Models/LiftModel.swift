//
//  LiftModel.swift
//  Barbell
//
//  Created by Caleb Albertson on 4/3/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation

public class LiftModel {
    var id: Int
    var exercise : String
    var sets : Int
    var reps : Int
    var weight : Int
    var dayIndex : Int
    var workout : Workout
    var lift : Lift
    
    init(id: Int, workout: Workout, lift: Lift) {
        self.id = id
        self.exercise = lift.name!
        self.sets = Int(lift.sets)
        self.reps = Int(lift.reps)
        self.weight = Int(lift.weight)
        self.workout = workout
        self.lift = lift
        let weekday = Int(workout.weekday!)

        dayIndex = ((Int(workout.weeknumber) - 1) * 7) + (weekday! - 1)
        
    }
}
