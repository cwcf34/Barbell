//
//  Workout+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 4/15/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var id: Int16
    @NSManaged public var weekday: String?
    @NSManaged public var weeknumber: Int16
    @NSManaged public var isFinished: Bool
    @NSManaged public var createdRoutine: Routine?
    @NSManaged public var hasExercises: NSSet?

}

// MARK: Generated accessors for hasExercises
extension Workout {

    @objc(addHasExercisesObject:)
    @NSManaged public func addToHasExercises(_ value: Lift)

    @objc(removeHasExercisesObject:)
    @NSManaged public func removeFromHasExercises(_ value: Lift)

    @objc(addHasExercises:)
    @NSManaged public func addToHasExercises(_ values: NSSet)

    @objc(removeHasExercises:)
    @NSManaged public func removeFromHasExercises(_ values: NSSet)

}
