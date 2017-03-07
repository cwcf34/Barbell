//
//  User+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 2/24/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var age: Int16
    @NSManaged public var email: String?
    @NSManaged public var fname: String?
    @NSManaged public var lname: String?
    @NSManaged public var weight: Int16
    @NSManaged public var workoutsCompleted: Int16
    @NSManaged public var workoutStyle: String?
    @NSManaged public var achievements: NSSet?
    @NSManaged public var madeWorkouts: NSSet?
    @NSManaged public var scheduleArr: NSSet?

}

// MARK: Generated accessors for achievements
extension User {

    @objc(addAchievementsObject:)
    @NSManaged public func addToAchievements(_ value: Achievement)

    @objc(removeAchievementsObject:)
    @NSManaged public func removeFromAchievements(_ value: Achievement)

    @objc(addAchievements:)
    @NSManaged public func addToAchievements(_ values: NSSet)

    @objc(removeAchievements:)
    @NSManaged public func removeFromAchievements(_ values: NSSet)

}

// MARK: Generated accessors for madeWorkouts
extension User {

    @objc(addMadeWorkoutsObject:)
    @NSManaged public func addToMadeWorkouts(_ value: Workout)

    @objc(removeMadeWorkoutsObject:)
    @NSManaged public func removeFromMadeWorkouts(_ value: Workout)

    @objc(addMadeWorkouts:)
    @NSManaged public func addToMadeWorkouts(_ values: NSSet)

    @objc(removeMadeWorkouts:)
    @NSManaged public func removeFromMadeWorkouts(_ values: NSSet)

}

// MARK: Generated accessors for scheduleArr
extension User {

    @objc(addScheduleArrObject:)
    @NSManaged public func addToScheduleArr(_ value: Routine)

    @objc(removeScheduleArrObject:)
    @NSManaged public func removeFromScheduleArr(_ value: Routine)

    @objc(addScheduleArr:)
    @NSManaged public func addToScheduleArr(_ values: NSSet)

    @objc(removeScheduleArr:)
    @NSManaged public func removeFromScheduleArr(_ values: NSSet)

}
