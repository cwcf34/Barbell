//
//  Achievement+CoreDataProperties.swift
//  Barbell
//
//  Created by Curtis Markway on 4/1/17.
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
    @NSManaged public var achievers: NSSet?

}

// MARK: Generated accessors for achievers
extension Achievement {

    @objc(addAchieversObject:)
    @NSManaged public func addToAchievers(_ value: User)

    @objc(removeAchieversObject:)
    @NSManaged public func removeFromAchievers(_ value: User)

    @objc(addAchievers:)
    @NSManaged public func addToAchievers(_ values: NSSet)

    @objc(removeAchievers:)
    @NSManaged public func removeFromAchievers(_ values: NSSet)

}
