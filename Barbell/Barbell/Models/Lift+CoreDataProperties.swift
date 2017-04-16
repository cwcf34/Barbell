//
//  Lift+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 4/15/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension Lift {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lift> {
        return NSFetchRequest<Lift>(entityName: "Lift")
    }

    @NSManaged public var id: Int16
    @NSManaged public var muscleGroup: String?
    @NSManaged public var name: String?
    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var isFinished: Bool
    @NSManaged public var inWorkout: Workout?

}
