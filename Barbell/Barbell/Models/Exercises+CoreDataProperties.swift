//
//  Exercise+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 3/10/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension Exercises {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercises> {
        return NSFetchRequest<Exercises>(entityName: "Exercises")
    }

    @NSManaged public var descript: String?
    @NSManaged public var duration: Int16
    @NSManaged public var id: Int16
    @NSManaged public var muscleGroup: String?
    @NSManaged public var name: String?
    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var weight: Int16

}
