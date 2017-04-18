//
//  DataAccess.swift
//  Barbell
//
//  Created by Cody Cameron on 2/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import Foundation
import CoreData


public class DataAccess {
    
    private static var apiURL = "http://bbapi.eastus.cloudapp.azure.com/api/"
    class func register(registerInfo: RegisterInfo) -> Bool {
        var request = URLRequest(url: URL(string: apiURL + "user/\(registerInfo.email)/")!)
        request.httpMethod = "POST"
        var x : Int = -1
        
        var result = false
        
        
        let postString = "\"{name:\(registerInfo.firstName) " + "\(registerInfo.lastName)" + "," + "password:\(registerInfo.password)}\" "
        
        let postDATA:Data = postString.data(using: String.Encoding.utf8)!
        
        request.httpBody = postDATA
        
        let headers = [
            "content-type": "application/json"
        ]
        

        
        request.allHTTPHeaderFields = headers
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)!
                
                if(responseString == "\"true\""){
                    result = true
                } else{
                    result = false
                }
                
                sem.signal()
            }
            
        task.resume()
        sem.wait()
        
        return result
    }
    
    class func getRoutinesFromRedis () -> [Routine] {
        let user : User = CoreDataController.getUser()
        var routine : Routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataController.getContext()) as! Routine
        var request = URLRequest(url: URL(string: apiURL + "routine/\(user.email!)/")!)
        var responseString = ""
        let headers = [
            "content-type": "application/json"
        ]
        
        request.allHTTPHeaderFields = headers
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Loading routine response: " + responseString)
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        var allRoutines = [Routine]()
        if let data = responseString.data(using: .utf8) as? Data{
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String:Any]]{
                //print("JSONFULL == \(json)\n\n")
                
                for eachRoutine in json {
                    
                    let newRoutine : Routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataController.getContext()) as! Routine
                
                    
                    for (key,value) in eachRoutine{
                        if (key == "numWeeks"){
                            if let value = value as? String{
                                if let castedValue = Int16(value){
                                    newRoutine.numberOfWeeks = castedValue
                                }
                            }
                        }
                        if (key == "Name"){
                            if let value = value as? String{
                                print("Found routine named in redis" + value)
                                newRoutine.name = value
                            }
                        }
                        if (key == "isPublic"){
                            if let value = value as? String{
                                if(value == "1"){
                                    newRoutine.isPublic = true
                                }else{
                                    newRoutine.isPublic = false
                                }
                            }
                        }
                        
                        //getting exercises for every workoutday
                        if (key == "Id"){
                            if let value = value as? String{
                                if let castedValue = Int16(value){
                                    newRoutine.id = castedValue
                                }
                            }
                        }
                    }
                    
                    let allWorkouts = NSSet(array: getWorkoutForRoutineFromRedis(routineId: newRoutine.id))
                    //let allWorkouts = NSSet(array: getWorkoutForRoutineFromRedis(routineId: "687113553"))
                    
                    for eachWorkout in allWorkouts{
                        if let workout = eachWorkout as? Workout {
                            if ((workout.hasExercises?.count)! > 0)  {
                                newRoutine.addToWorkouts(workout)
                                workout.createdRoutine = newRoutine
                            }
                        }
                    }
                    
                    newRoutine.creator = user.fname! + user.lname!
                    //newRoutine.addToUsers(user)
                    
                    allRoutines.append(newRoutine)

                }
            }
        }
        
        
        //print("Hopefully no square brackets: " + responseString)
        
        CoreDataController.saveContext()

        return allRoutines
    }
    
    
    
    class func getWorkoutForRoutineFromRedis (routineId: Int16) -> [Workout]  {
        if let user = CoreDataController.getUser() as? User {
        
            var request = URLRequest(url: URL(string: apiURL + "workout/\(user.email!)/\(routineId)/")!)
            
            print("\n\nNEW WORKOUT REQUEST\(request)\n")
            
            var responseString = ""
            let headers = [
                "content-type": "application/json"
            ]
            
            request.allHTTPHeaderFields = headers
            
            let sem = DispatchSemaphore(value: 0)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                responseString = String(data: data, encoding: .utf8)!
                
                print("\nLoading WOrkout Data response: " + responseString)
                
                
                sem.signal()
            }
            
            task.resume()
            sem.wait()

            
            var allWorkouts = [Workout]()
            var count = 0
            
            if let data = responseString.data(using: .utf8) as? Data{
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[[String:Any]]]{
                    //print("\n\nWorkoutJSONFULL == \(json)\n\n")
                    
                    for eachWorkout in json {
                        
                        if eachWorkout.description != "[]" {
                            
                            let newWorkout : Workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: CoreDataController.getContext()) as! Workout
                            var liftList = [Lift]()
                            
                            //print("\n\nWORKOUTDATA\(eachWorkout)\n\n")
                            
                            if let eachWorkout = eachWorkout as? [[String:Any]]{
                                for eachExercise in eachWorkout {
                                    var sets = 0
                                    var reps = 0
                                    var weight = 0
                                    var name = ""
                                    
                                    for (key, value) in eachExercise{
                                        //print("\nKEY\(key)\nVALUE\(value)\n\n")
                                        
                                        if (key == "Value"){
                                            let exerciseData = value as! String
                                            
                                            let parsedData = exerciseData.components(separatedBy: ":")
                                            sets = Int(parsedData[0])!
                                            reps = Int(parsedData[1])!
                                            weight = Int(parsedData[2])!
                                            
                                        }
                                        if (key == "Key"){
                                            name = value as! String
                                        }
                                    }
                                    
                                    let newLift : Lift = NSEntityDescription.insertNewObject(forEntityName: "Lift", into: CoreDataController.getContext()) as! Lift
                                    
                                    newLift.id = 0
                                    newLift.muscleGroup = ""
                                    newLift.name = name
                                    newLift.sets = Int16(sets)
                                    newLift.reps = Int16(reps)
                                    newLift.weight = Int16(weight)
                                    newLift.inWorkout = newWorkout
                                    
                                    liftList.append(newLift)
                                }
                            }
                            
                            let weekCountInt: Int16 = Int16(floor(Double(count/7)) + 1)
                            var weekdayString = ""
                            
                            switch count % 7 {
                            case 0:
                                weekdayString = "1"
                            case 1:
                                weekdayString = "2"
                            case 2:
                                weekdayString = "3"
                            case 3:
                                weekdayString = "4"
                            case 4:
                                weekdayString = "5"
                            case 5:
                                weekdayString = "6"
                            default:
                                weekdayString = "7"
                            }
                            newWorkout.weekday = weekdayString
                            newWorkout.weeknumber = weekCountInt
                            
                            let addingList = NSSet(array: liftList)
                            newWorkout.addToHasExercises(addingList)
                            
                            allWorkouts.append(newWorkout)

                        }else{
                            print("empty workout day")
                        }
                        
                        count += 1
                    }
                }
            }
            
            return allWorkouts
        }
    }

    
    
    class func sendRoutineToRedis (routine: Routine) -> Bool {
        
        let user : User = CoreDataController.getUser()
        
        var postString = ""
        print("name:  " + user.fname!)
        print("email: " + user.email!)
        var email : String!
        email = user.email!
        var request = URLRequest(url: URL(string: apiURL + "routine/\(email!)/")!)
        let routineName : String!
        var isPublicInt = 0
        if routine.isPublic == true {
            isPublicInt = 1
        }
        routineName = routine.name!
        postString = "\"{name:\(routineName!)" + "," + "weeks:\(routine.numberOfWeeks)" + "," + "isPublic:\(isPublicInt)" + "," + "creator:\(user.fname!)}\" "
        
        request.httpMethod = "POST"
        
        var responseString = ""
        let headers = [
            "content-type": "application/json"
        ]
        
        print(postString)
        
        let postDATA:Data = postString.data(using: String.Encoding.utf8)!
        
        request.httpBody = postDATA
        request.allHTTPHeaderFields = headers
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Did save routine to redis?  " + responseString)
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        
        if Int(responseString)! > 0 {
            routine.id = Int16(responseString)!
            var workoutsInRoutine = [Workout]()
            workoutsInRoutine = routine.workouts?.allObjects as! [Workout]
            for workout in workoutsInRoutine {
                let workoutModel = WorkoutModel(id: Int(responseString)!, workout: workout)
                sendWorkoutToRedis(workoutModel: workoutModel)
            }
        }
        return true
        
    }
    
    class func sendWorkoutToRedis (workoutModel: WorkoutModel) -> Bool {
        var liftsInWorkout = [Lift]()
        liftsInWorkout = workoutModel.workout.hasExercises?.allObjects as! [Lift]
        for lift in liftsInWorkout {
            let liftModel = LiftModel(id: workoutModel.id, workout: workoutModel.workout, lift: lift)
            sendLiftToRedis(liftModel: liftModel)
        }
        
        return true
    }
    
    class func sendLiftToRedis (liftModel: LiftModel) -> Bool {
     
        let user : User = CoreDataController.getUser()
        
        var postString = ""
        var email : String!
        email = user.email!
        var request = URLRequest(url: URL(string: apiURL + "workout/\(email!)/")!)
        postString = "\"{routineId:\(liftModel.id)" + "," + "exercise:\(liftModel.exercise)" + "," + "sets:\(liftModel.sets)" + "," + "reps:\(liftModel.reps)" + "," + "weight:\(liftModel.weight)" + "," + "dayIndex:\(liftModel.dayIndex)}\" "
        
        print("Exercise request" + postString)
        request.httpMethod = "POST"
        
        var responseString = ""
        let headers = [
            "content-type": "application/json"
        ]
        
        print(postString)
        
        let postDATA:Data = postString.data(using: String.Encoding.utf8)!
        
        request.httpBody = postDATA
        request.allHTTPHeaderFields = headers
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Did save exercise to redis?  " + responseString)
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        return true
        
    }
    
    class func login (loginInfo: LoginInfo ) -> Bool{
        var request = URLRequest(url: URL(string: apiURL + "login/\(loginInfo.email)/")!)
        
        var responseString  = "false"
        
        request.httpMethod = "POST"
        
        let postString = "\"{password:\(loginInfo.password)}\" "
        
        let postDATA:Data = postString.data(using: String.Encoding.utf8)!
        
        request.httpBody = postDATA
        
        let headers = [
            "content-type": "application/json"
        ]
        
        request.allHTTPHeaderFields = headers
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("login response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            print("login responseString = \(responseString)")
            sem.signal()
        }
        task.resume()
        sem.wait()
        
        if(responseString == "\"true\""){
            return true
        } else{
            return false
        }
    }

    
    class func getUserfromRedis(email : String){
        var request = URLRequest(url: URL(string: apiURL + "user/\(email)/")!)
        let user : User = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.getContext()) as! User
        request.httpMethod = "GET"
        var responseString = ""
        
        let headers = [
            "content-type": "application/json"
        ]
        
        request.allHTTPHeaderFields = headers
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Get user response " + responseString)
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        let tokens = responseString.components(separatedBy: ",")
        //var token = [String]()B
        if let user = user as? User {
            for i in tokens{
                var token = i.components(separatedBy: ":")
                if token[0] == "\"name"{
                    token[0].remove(at: token[0].startIndex)
                    let nameTokens = token[1].components(separatedBy: " ")
                    user.fname = nameTokens[1]
                    user.lname = nameTokens[2]
                }
                if token[0] == "email"{
                    token[1].remove(at: token[1].startIndex)
                    user.email = token[1]
                }
                if token[0] == "age"{
                    token[1].remove(at: token[1].startIndex)
                    user.age = Int16(token[1])!
                }
                if token[0] == "weight"{
                    token[1].remove(at: token[1].startIndex)
                    user.weight = Int16(token[1])!
                }
                if token[0] == "squat"{
                    token[1].remove(at: token[1].startIndex)
                    user.squat = Int16(token[1])!
                }
                if token[0] == "bench"{
                    token[1].remove(at: token[1].startIndex)
                    user.bench = Int16(token[1])!
                }
                if token[0] == "deadlift"{
                    token[1].remove(at: token[1].startIndex)
                    user.deadlift = Int16(token[1])!
                    
                }
                if token[0] == "cleanjerk"{
                    token[1].remove(at: token[1].startIndex)
                    user.cleanAndJerk = Int16(token[1])!
                }
                if token[0] == "snatch"{
                    token[1].remove(at: token[1].startIndex)
                    user.snatch = Int16(token[1])!
                }
                if token[0] == "workoutsCompleted"{
                    var woTokens = token[1].components(separatedBy: "\"")
                    //token[1].remove(at: token[1].endIndex)
                    woTokens[0].remove(at: woTokens[0].startIndex)
                    user.workoutsCompleted = Int16(woTokens[0])!
                }
            }
            CoreDataController.saveContext()
            return
        }
    }
    
    class func checkRoutines(){
        let redisRoutines = reloadRoutinesFromRedis()
        let fetchRequest = NSFetchRequest<User>(entityName: "Routine")
        
        var coreRoutines = [Routine] ()
        do{
            coreRoutines = try CoreDataController.getContext().fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Routine]
        }catch{
            print("we messed this up")
        }
        
        /*for redisRoutine in redisRoutines{
            print("redis routine id:  " + String(redisRoutine.id))
        }*/
        for coreRoutine in coreRoutines{
            print("core routine id: " + String(coreRoutine.id))
            if coreRoutine.id == 0 {
                sendRoutineToRedis(routine: coreRoutine)
            }
        }
        var isInCore = false
        for redisRoutine in redisRoutines{
            isInCore = false
            for coreRoutine in coreRoutines{
                
                if coreRoutine.id == redisRoutine.id{
                    isInCore = true
                    break
                }
               
            }
            if isInCore == false {
                deleteRoutineFromRedis(routine: redisRoutine)
            }
        }
    }
    
    class func reloadRoutinesFromRedis () -> [RedisRoutine] {
        let user : User = CoreDataController.getUser()
        var request = URLRequest(url: URL(string: apiURL + "routine/\(user.email!)/")!)
        var responseString = ""
        let headers = [
            "content-type": "application/json"
        ]
        
        request.allHTTPHeaderFields = headers
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Loading routine response: " + responseString)
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        
        var allRoutines = [RedisRoutine]()
        if let data = responseString.data(using: .utf8) as? Data{
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String:Any]]{
                //print("JSONFULL == \(json)\n\n")
                
                for eachRoutine in json {
                    
                    let newRoutine = RedisRoutine(id: 0)
                    
                    
                    for (key,value) in eachRoutine{

                        if (key == "Id"){
                            if let value = value as? String{
                                if let castedValue = Int16(value){
                                    newRoutine.id = castedValue
                                }
                            }
                        }
                    }
                    allRoutines.append(newRoutine)
                }
            }
        }
        return allRoutines
    }
    
    class func deleteRoutineFromRedis(routine : RedisRoutine){
        let user : User = CoreDataController.getUser()
        var request = URLRequest(url: URL(string: apiURL + "routine/\(user.email!)/\(routine.id)")!)
        request.httpMethod = "DELETE"
        var responseString = ""
        
        let headers = [
            "content-type": "application/json"
        ]
        
        request.allHTTPHeaderFields = headers
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Get user response " + responseString)
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
    }

    class func saveUserToRedis(email : String){
        let user = CoreDataController.getUser()
        print(email)
        //var request = URLRequest(url: URL(string: apiURL + "user/\(user.first?.email)/")!)
        var request = URLRequest(url: URL(string: apiURL + "user/\(email)/")!)
        request.httpMethod = "PUT"
        var putString = ""
        if let user = user as? User,
            let fname = user.fname,
            let lname = user.lname,
            let age = String(user.age) as? String,
            let weight = String(user.weight) as? String,
            let squat = String(user.squat) as? String,
            let bench = String(user.bench) as? String,
            let deadlift = String(user.deadlift) as? String,
            let snatch = String(user.snatch) as? String,
            let cleanAndJerk = String(user.cleanAndJerk) as? String,
            let workoutsCompleted = String(user.workoutsCompleted) as? String{
        

        putString = "\"{name:\(fname) " + "\(lname)" + "," + "password:" + "," + "age:\(age)" + "," + "weight:\(weight)" + "," + "squat:\(squat)" + "," + "bench:\(bench)" + "," + "deadlift:\(deadlift)" + "," + "snatch:\(snatch)" + "," + "cleanjerk:\(cleanAndJerk)" + "," + "workoutsCompleted:\(workoutsCompleted)}\" "
        }
        //let postString = "\"{name:\(registerInfo.firstName) " + "\(registerInfo.lastName)" + "," + "password:\(registerInfo.password)}\" "
        
        
        var responseString = ""
        let headers = [
            "content-type": "application/json"
        ]
        
        print(putString)
    
        let postDATA:Data = putString.data(using: String.Encoding.utf8)!
        
        request.httpBody = postDATA
        request.allHTTPHeaderFields = headers

        let sem = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Save user to redis response " + responseString)
            
            
            sem.signal()
        }

        task.resume()
        sem.wait()
        return
    }
}
