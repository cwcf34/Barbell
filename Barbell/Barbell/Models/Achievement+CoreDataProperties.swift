//
//  Achievement+CoreDataProperties.swift
//  Barbell
//
//  Created by Caleb Albertson on 4/15/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData


extension Achievement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }

    @NSManaged public var achievementNumber: Int16
    @NSManaged public var name: String?
    @NSManaged public var achievedOn: NSDate?

}

