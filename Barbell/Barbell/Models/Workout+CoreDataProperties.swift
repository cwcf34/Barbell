//
//  Workout+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 2/24/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var descript: String?
    @NSManaged public var duration: Int16
    @NSManaged public var id: Int16
    @NSManaged public var name: String
    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var createdRoutine: Routine?
    @NSManaged public var creator: User?

}
