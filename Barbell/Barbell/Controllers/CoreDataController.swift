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
                return
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
    
    class func getUser() -> [User]{
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do{
            let foundUser = try getContext().fetch(fetchRequest)
            return foundUser
        }catch{
            print("we messed this up")
        }
        return [User]()
    }
    
    class func clearData() {
        //let context = getContext()
        let isEmpty = entityIsEmpty(entity: "User")
        if isEmpty {
            return
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        var result : NSPersistentStoreResult?
        /*do {
            result = try request.execute
        }
        catch{
            print(result?.description)
        }*/
        //saveContext()
        
    }
    
    class func entityIsEmpty(entity: String) -> Bool{
        //var appDel:AppDelegate = UIApplication.sharedApplication().delegae as! AppDelegate
        //let context = NSManagedObjectContext()
        let context = getContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        var results : NSArray?
        var count = 0
       
        do {
            count = try context.count(for: request)
            if count == 0{
                return true
            }
            else{
                return false
            }
            /*print("isempty results" + (results?.description)!)
            if results?.count == 0{*/

        } catch {
            print("error")
            return true
        }
        
       
    }
}
