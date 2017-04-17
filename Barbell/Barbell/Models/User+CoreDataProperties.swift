//
//  User+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 4/15/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var age: Int16
    @NSManaged public var bench: Int16
    @NSManaged public var cleanAndJerk: Int16
    @NSManaged public var deadlift: Int16
    @NSManaged public var email: String?
    @NSManaged public var fname: String?
    @NSManaged public var lname: String?
    @NSManaged public var snatch: Int16
    @NSManaged public var squat: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var workoutsCompleted: Int16

}
