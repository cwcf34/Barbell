//
//  CoreDataController.swift
//  Barbell
//
//  Created by Caleb Albertson on 2/24/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController{

    private init(){
        
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
    // Replace this implementation with code to handle the error appropriately.
    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    
    /*
     Typical reasons for an error here include:
     * The parent directory does not exist, cannot be created, or disallows writing.
     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
     * The device is out of space.
     * The store could not be migrated to the current model version.
     Check the error message to determine what the actual problem was.
     */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    } ()
    
    class func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    class func getContext() -> NSManagedObjectContext {
        return CoreDataController.persistentContainer.viewContext
    }
    //Since there should only ever be one User entity in coredata at a time, this funcion will return that user
    
    class func getUser() -> User{
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        var foundUser = [User] ()
        do{
            foundUser = try getContext().fetch(fetchRequest)
            return (foundUser.first)!
        }catch{
            print("we messed this up")
        }
        return (foundUser.first)!
    }
    
    class func getAchievements() -> [Achievement]{
        let fetchRequest = NSFetchRequest<Achievement>(entityName: "Achievement")
        var foundAchievements = [Achievement] ()
        do{
            foundAchievements = try getContext().fetch(fetchRequest)
            return (foundAchievements)
        }catch{
            print("we messed this up")
        }
        return (foundAchievements)
    }
    
    class func getHistory() -> [LegacyLift]{
        let fetchRequest = NSFetchRequest<LegacyLift>(entityName: "LegacyLift")
        var foundHistory = [LegacyLift] ()
        do{
            foundHistory = try getContext().fetch(fetchRequest)
            return (foundHistory)
        }catch{
            print("we messed this up")
        }
        return (foundHistory)
    }
    
    class func maybeSaveHistory(name: String, reps: Int16, sets: Int16, weight: Int16){
       
        if name == "Bench Press" || name == "Full Squat" || name == "Deadlift" || name == "Snatch" || name == "Clean and Jerk"{
            if reps > 0{
                let finished : LegacyLift = NSEntityDescription.insertNewObject(forEntityName: "LegacyLift", into: CoreDataController.getContext()) as! LegacyLift
                finished.liftName = name
                finished.liftRep = reps
                finished.liftSets = sets
                finished.liftWeight = weight
                finished.timeStamp = Date() as NSDate
                
                CoreDataController.saveContext()
            }
        }
    }
    
    class func newAchievement(achievementNumber: Int16){
        
        let existingAchievements = getAchievements()
        for achievement in existingAchievements{
            if achievement.achievementNumber == achievementNumber{
                return
            }
        }
        
        let achievement:Achievement = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into: CoreDataController.getContext()) as! Achievement
        
        achievement.achievementNumber = achievementNumber
        achievement.achievedOn = NSDate()
        print("New Achievement " + String(achievementNumber) + " earned on: " + String(describing: achievement.achievedOn))
        saveContext()
    }
    
    class func clearData() {
        var isLiftEmpty = false
        var isRoutineEmpty = false
        var isUserEmpty = false
        var isWorkoutEmpty = false
        var isAchievementEmpty = false
        var isLegacyLiftEmpty = false
        let context = getContext()
        
        isUserEmpty = entityIsEmpty(entity: "User")
        isRoutineEmpty = entityIsEmpty(entity: "Routine")
        isLiftEmpty = entityIsEmpty(entity: "Lift")
        isWorkoutEmpty = entityIsEmpty(entity: "Workout")
        isAchievementEmpty = entityIsEmpty(entity: "Achievement")
        isLegacyLiftEmpty = entityIsEmpty(entity: "LegacyLift")
        
     
        if !isUserEmpty {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            var result : NSPersistentStoreResult?
            do {
                result = try context.execute(request)
            }
            catch{
                print(result?.description)
            }
        }
            
        if !isLiftEmpty {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Lift")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            var result : NSPersistentStoreResult?
            do {
                result = try context.execute(request)
            }
            catch{
                print(result?.description)
            }
        }
        
        if !isRoutineEmpty {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Routine")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            var result : NSPersistentStoreResult?
            do {
                print("deleted Routines")
                result = try context.execute(request)
            }
            catch{
                print(result?.description)
            }
        }
        if !isWorkoutEmpty {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            var result : NSPersistentStoreResult?
            do {
                print("deleted Workout")
                result = try context.execute(request)
            }
            catch{
                print(result?.description)
            }
        }
        if !isAchievementEmpty{
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Achievement")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            var result : NSPersistentStoreResult?
            do {
                //print("deleted Workout")
                result = try context.execute(request)
            }
            catch{
                print(result?.description)
            }
        }
        if !isLegacyLiftEmpty{
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LegacyLift")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            var result : NSPersistentStoreResult?
            do {
                //print("deleted Workout")
                result = try context.execute(request)
            }
            catch{
                print(result?.description)
            }
        }
        saveContext()
        return
    }
    
    class func entityIsEmpty(entity: String) -> Bool{
        //var appDel:AppDelegate = UIApplication.sharedApplication().delegae as! AppDelegate
        //let context = NSManagedObjectContext()
        let context = getContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        //let error = NSError?.self
        
        do {
            let results:NSArray? = try context.fetch(request) as NSArray
            if let res = results {
                if res.count == 0{
                    return true
                }
            
                else{
                    return false
                }
            }
            /*print("isempty results" + (results?.description)!)
             if results?.count == 0{*/
            
        } catch {
            print("error")
            return true
        }
    }
}
