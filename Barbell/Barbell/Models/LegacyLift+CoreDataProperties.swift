//
//  LegacyLift+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 4/15/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension LegacyLift {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LegacyLift> {
        return NSFetchRequest<LegacyLift>(entityName: "LegacyLift")
    }

    @NSManaged public var liftName: String?
    @NSManaged public var liftRep: Int16
    @NSManaged public var liftSets: Int16
    @NSManaged public var liftWeight: Int16
    @NSManaged public var timeStamp: NSDate?

}
