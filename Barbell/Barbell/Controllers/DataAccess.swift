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
    private static var authURL = "http://bbapi.eastus.cloudapp.azure.com:63894/connect/token/"
    private static var refreshToken = ""
    private static var accessToken = ""
    
    class func register(registerInfo: RegisterInfo) -> Bool {
        var responseString = ""
        
        var request = URLRequest(url: URL(string: apiURL + "user/\(registerInfo.email)/")!)
        
        request.httpMethod = "POST"
        
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
                print("\nREgister response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            if(responseString == "\"true\""){
                result = true
            } else{
                result = false
            }
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        //after registring, check if true
        if (result){
            result = getAuthentication(user: registerInfo.email,pass: registerInfo.password)
        }
        
        //start the countdown to resfresh tokens
        startRefreshCountdown()
        
        return result
    }
    
    class func login (loginInfo: LoginInfo ) -> Bool{
        
        //login by getting authentication
        return getAuthentication(user: loginInfo.email,pass: loginInfo.password)
    }
    
    class func getAuthentication(user: String, pass: String) -> Bool{
        var responseString = ""
        var authenticated = true
        
        //request token for validation
        var request = URLRequest(url: URL(string: authURL)!)
        
        //add request settings
        let headers = [
            "Content-type": "application/x-www-form-urlencoded"
        ]
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        
        if  (pass != " " && user != " " ) {
            
            let postBody = "client_id=iOS&username=\(user)&password=\(pass)&client_secret=secret&grant_type=password&scope=WebAPI offline_access".data(using:String.Encoding.ascii, allowLossyConversion: false)
            
            // add form url encoded post data
            request.httpBody = postBody
            
            
            let sem = DispatchSemaphore(value: 0)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                // check for fundamental networking error
                guard let data = data, error == nil else {                                                                        print("error=\(error)")
                    authenticated = false
                    return
                }
                
                
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("\nGet Auth response = \(response)\n")
                    authenticated = false
                }
                
                //convert data to string
                responseString = String(data: data, encoding: .utf8)!
                print("Loading Auth request response: " + responseString)
                
                if (authenticated){
                    //convert data to [String:String] for parsing
                    if let authData = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] {
                        
                        //key:value pairs on response from server
                        for (key,value) in authData{
                            print("KEY::\(key)VALUE::\(value)")
                            
                            if (key == "access_token") {
                                if let value = value as? String {
                                    accessToken = "Bearer \(value)"
                                }
                            }else if(key == "refresh_token"){
                                if let value = value as? String {
                                    refreshToken = value
                                }
                            }
                        }
                    }else {
                        // if data cant be converted into [string:any], something went wrong
                        authenticated = false
                    }
                }
                
                //send signal to continue w execution
                sem.signal()
            }
            // start url task
            task.resume()
            
            // wait for signal
            sem.wait()
            
        }else {
            //if passed user or pass is " ", auth WILL fail
            authenticated = false
        }
        
        //are you auth'd?
        return authenticated
    }
    
    //refreshs' the auth tokens
    class func startRefreshCountdown() {
        
        //access token and refresh token expire in 60m/3600s
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3000)) {
            
            //refresh both tokens 50m/3000s after register or login to be safe
            refreshAuthToken(token: refreshToken)
            
            //after another 50m refresh again
            //i <3 recursion
            startRefreshCountdown()
        }
    }
    
    class func refreshAuthToken(token: String){
        //request token for refresh of validation
        var responseString = ""
        
        //URL REQUEST SETUP
        var request = URLRequest(url: URL(string: authURL)!)
        
        let headers = [
            "Content-type": "application/x-www-form-urlencoded"
        ]
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        
        //how to form url encoded post data as opposed to json
        let postBody = "client_id=iOS&client_secret=secret&grant_type=refresh_token&refresh_token=\(refreshToken)".data(using:String.Encoding.ascii, allowLossyConversion: false)
        
        //attach post body data
        request.httpBody = postBody
        
        //create semaphore control
        let sem = DispatchSemaphore(value: 0)
        
        //create url task to refresh access token using refresh token
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            // check for fundamental networking error
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            //now i  haz teh data
            // check for http errors
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("\nREFRESH Auth TOKEN response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("Loading REFRESH Auth TOKEN response: " + responseString)
            
            //convert data to [String:String] for parsing
            if let refreshData = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] {
                
                //key:value pairs on response from server
                for (key,value) in refreshData{
                    print("KEY::\(key)VALUE::\(value)")
                    
                    if (key == "error") {
                        
                    }else if (key == "access_token") {
                        //grab new access token
                        if let value = value as? String {
                            accessToken = "Bearer \(value)"
                        }
                    }else if(key == "refresh_token"){
                        //grab new refresh token
                        if let value = value as? String {
                            refreshToken = value
                        }
                    }
                }
            }
            
            //send signal of completion
            sem.signal()
        }
        
        //start task
        task.resume()
        //wait for singal of completion
        sem.wait()
    }
    
    class func searchRoutinesInRedis(_ query: String) -> [Routine] {
        //temp holder
        var searchedRoutines = [Routine]()
        
        if let user = CoreDataController.getUser() as? User {
            
            //setup URL Request
            if let url = URL(string: "\(apiURL)routine/?query=\(query)") {
                
                var request = URLRequest(url: url)
                let headers = [
                    "Content-Type": "application/json",
                    "Authorization": self.accessToken
                ]
                
                request.allHTTPHeaderFields = headers
                
                let sem = DispatchSemaphore(value: 0)
                let task = URLSession.shared.dataTask(with: request) {
                    data, response, error in
                    
                    //opposite of if let
                    guard let data = data, error == nil else {
                        print("error=\(error)")
                        return
                    }
                    
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String:Any]]{
                        //print("JSONFULL == \(json)\n\n")
                        
                        //there were no found routines
                        if (json.count != 0) {
                            for eachRoutine in json {
                                
                                //this would save every searched routine to core data LUL
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
                                    if (key == "creator"){
                                        if let value = value as? String{
                                            newRoutine.creator = value
                                        }
                                    }
                                    if (key == "Id"){
                                        if let value = value as? String{
                                            if let castedValue = Int16(value){
                                                newRoutine.id = castedValue
                                            }
                                        }
                                    }
                                }
                                
                                /*
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
                                 */
                                
                                //add searched Routine to searchedResults LIst
                                searchedRoutines.append(newRoutine)
                            }
                            
                        }
                        
                    }
                    
                    //send completion signal
                    sem.signal()
                }
                
                //start task and wait for completion
                task.resume()
                sem.wait()
            }
        }
        
        return searchedRoutines
    }
    
    class func getRoutinesFromRedis () -> [Routine] {
        let user : User = CoreDataController.getUser()
        var routine : Routine = NSEntityDescription.insertNewObject(forEntityName: "Routine", into: CoreDataController.getContext()) as! Routine
        print("email trying to login: " + user.email!)
        var request = URLRequest(url: URL(string: apiURL + "routine/\(user.email!)/")!)
        var responseString = ""
        let headers = [
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                print("\nGetting routine from redis response = \(response)\n")
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
                    
                    //newRoutine.creator = user.fname! + user.lname!
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
                "Content-Type": "application/json",
                "Authorization": self.accessToken
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
    
    class func editRoutineinRedis (routine: Routine) -> Bool {
        
        let user : User = CoreDataController.getUser()
        
        var putString = ""
        var email : String!
        email = user.email!
        var request = URLRequest(url: URL(string: apiURL + "routine/\(email!)/")!)
        let routineName : String!
        var isPublicInt = 0
        if routine.isPublic == true {
            isPublicInt = 1
        }
        routineName = routine.name!
        putString = "\"{name:\(routineName!)" + "," + "weeks:\(routine.numberOfWeeks)" + "," + "isPublic:\(isPublicInt)" + "," + "creator:\(routine.creator)}\" "
        
        request.httpMethod = "PUT"
        
        var responseString = ""
        let headers = [
            "Content-Type": "application/json",
            "Authorization": self.accessToken
        ]
        
        print(putString)
        
        let putDATA:Data = putString.data(using: String.Encoding.utf8)!
        
        request.httpBody = putDATA
        request.allHTTPHeaderFields = headers
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                   // check for fundamental networking error
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
        if routine.name == nil{
            return false
        }
        routineName = routine.name!
        postString = "\"{name:\(routineName!)" + "," + "weeks:\(routine.numberOfWeeks)" + "," + "isPublic:\(isPublicInt)" + "," + "creator:\(user.email!)}\" "
        
        request.httpMethod = "POST"
        
        var responseString = ""
        let headers = [
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                if (httpStatus.statusCode == 401){
                    //get refresh token because there is a problem w Auth
                    refreshAuthToken(token: refreshToken)
                    
                }
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
    
    class func getUserfromRedis(email : String){
        var request = URLRequest(url: URL(string: apiURL + "user/\(email)/")!)
        let user : User = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.getContext()) as! User
        request.httpMethod = "GET"
        var responseString = ""
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                print("\nGET USER FROM REDIS response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("\nGet user response \(responseString)\n")
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        //let tokens = responseString.components(separatedBy: ",")
        //var token = [String]()
        if let user = user as? User {
            
            /*
            for i in tokens{
                var token = i.components(separatedBy: ":")
                if token[0] == "name"{
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
                    
                    
                    var ageTokens = token[1].components(separatedBy: "\"")
                    //token[1].remove(at: token[1].endIndex)
                    ageTokens[0].remove(at: ageTokens[0].startIndex)
                    user.age = Int16(ageTokens[0])!
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
                if token[0] == "\"snatch"{
                    
                    token[1].remove(at: token[1].startIndex)
                    user.snatch = Int16(token[1])!
                }
                if token[0] == "workoutsCompleted"{
                    
                    
                    token[1].remove(at: token[1].startIndex)
                    user.workoutsCompleted = Int16(token[1])!
                }
            } */
            
            
        
        
            if let data = responseString.data(using: .utf8){
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]{
                    print("\nUSERJSON == \(json)\n\n")
             
                    
                        for (key,value) in json {
                            if (key == "Age"){
                                if let value = value as? Int16{
                                    user.age = value
                                }
                             }
                             else if (key == "Weight"){
                                if let value = value as? Int16{
                                    user.weight = value
                                }
                             }
                             else if (key == "Bench"){
                                if let value = value as? Int16{
                                    user.bench = value
                                }
                             }
                             else if (key == "Deadlift"){
                                if let value = value as? Int16{
                                    user.deadlift = value
                                }
                             }
                             else if (key == "Squat"){
                                if let value = value as? Int16{
                                    user.squat = value
                                }
                             }
                             else if (key == "Snatch"){
                                if let value = value as? Int16{
                                    user.snatch = value
                                }
                             }
                             else if (key == "CleanAndJerk"){
                                if let value = value as? Int16{
                                    user.cleanAndJerk = value
                                }
                             }
                             else if (key == "WorkoutsCompleted"){
                                if let value = value as? Int16{
                                    user.workoutsCompleted = value
                                }
                             }
                             else if (key == "Email"){
                                if let value = value as? String{
                                    user.email = value
                                }
                            }
                            else if (key == "Name"){
                                if let value = value as? String{
                                    var name = value.components(separatedBy: " ")
                                    user.fname = name[0]
                                    user.lname = name[1]
                                }
                            }
                        }
                    
                }
            /*print("loaded achievement" + newHistory.liftName! + String(describing: newHistory.timeStamp))*/
            }
        }
        CoreDataController.saveContext()
        
        
        print(user)
        
        return
        
    }
    
    class func checkRoutines(){
        let redisRoutines = reloadRoutinesFromRedis()
        let fetchRequest = NSFetchRequest<Routine>(entityName: "Routine")
        
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
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                print("\nreloadRoutines response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("\nLoading routine response: \(responseString)\n")
            
            
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
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                print("\nDELETE ROUTINE response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("\nGet user response \(responseString)\n")
            
            
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
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                print("\nSAVE USER TO REDIS response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("\nSave user to redis response \(responseString)\n")
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        return
    }
    
    class func getAchievementsfromRedis(email : String){
        var request = URLRequest(url: URL(string: apiURL + "achievement/\(email)/")!)
        request.httpMethod = "GET"
        var responseString = ""
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                print("\nGET USER FROM REDIS response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("\nGet achievement response \(responseString)\n")
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        if let data = responseString.data(using: .utf8) as? Data{
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String:Any]]{
                //print("JSONFULL == \(json)\n\n")
                
                for eachAchievement in json {
                    
                    let newAchievement : Achievement = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into: CoreDataController.getContext()) as! Achievement
                    
                    
                    for (key,value) in eachAchievement{
                        if (key == "achievementNumber"){
                            if let value = value as? String{
                                if let castedValue = Int16(value){
                                    newAchievement.achievementNumber = castedValue
                                }
                            }
                        }
                        if (key == "Name"){
                            if let value = value as? String{
                                print("Found routine named in redis" + value)
                                newAchievement.name = value
                            }
                        }
                        if (key == "achievedOn"){
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                            formatter.locale = Locale.init(identifier: "en_GB")
                            let dateObj = formatter.date(from: value as! String)
                        }
                    }
                    print("loaded achievement" + String(newAchievement.achievementNumber))
                    
                }
                
            }
        }
        CoreDataController.saveContext()
    }
    
    class func saveAchievementsToRedis(){
        let user = CoreDataController.getUser()
        let achievements = CoreDataController.getAchievements()
        var postString = ""
        
        var request = URLRequest(url: URL(string: apiURL + "achievement/\(user.email!)/")!)
        
        request.httpMethod = "POST"
        
        
        for achievement in achievements{
            postString = "\"{date:\(achievement.achievedOn!)" + "," + "id:\(achievement.achievementNumber)}\" "
            print(postString)
            
            let postDATA:Data = postString.data(using: String.Encoding.utf8)!
            request.httpBody = postDATA
            var responseString = ""
            let headers = [
                "Content-Type": "application/json",
                "Authorization": self.accessToken
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
                
                print("Did save Achievement " + String(achievement.achievementNumber) + " to redis?  " + responseString)
                
                
                sem.signal()
            }
            
            task.resume()
            sem.wait()
        }
    }
    
    class func getHistoryfromRedis(email : String, pastlift: String) -> [LegacyLift]{
        var request = URLRequest(url: URL(string: apiURL + "exercise/\(email)/?exercise=\(pastlift)")!)
        
        var liftData = [LegacyLift]()
        
        request.httpMethod = "GET"
        var responseString = ""
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": self.accessToken
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
                print("\nGET USER FROM REDIS response = \(response)\n")
            }
            
            responseString = String(data: data, encoding: .utf8)!
            
            print("\nGet ExerciseData for \(pastlift) response \(responseString)\n")
            
            
            sem.signal()
        }
        
        task.resume()
        sem.wait()
        
        if let data = responseString.data(using: .utf8) as? Data{
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String:Any]]{
                //print("JSONFULL == \(json)\n\n")
                
                for eachHistory in json {
                    
                    let newHistory : LegacyLift = NSEntityDescription.insertNewObject(forEntityName: "LegacyLift", into: CoreDataController.getContext()) as! LegacyLift
                    
                    newHistory.liftName = pastlift
                    
                    for (key,value) in eachHistory{
                        if (key == "Reps"){
                            if let value = value as? String{
                                if let castedValue = Int16(value){
                                    newHistory.liftRep = castedValue
                                }
                            }
                        }
                        if (key == "Weight"){
                            if let value = value as? String{
                                if let castedValue = Int16(value){
                                    newHistory.liftWeight = castedValue
                                }
                            }
                        }
                        if (key == "Sets"){
                            if let value = value as? String{
                                if let castedValue = Int16(value){
                                    newHistory.liftSets = castedValue
                                }
                            }
                        }
                        if (key == "Date"){
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                            formatter.locale = Locale.init(identifier: "en_GB")
                            let dateObj = formatter.date(from: value as! String)
                            newHistory.timeStamp = dateObj! as NSDate
                        }
                    }
                    /*print("loaded achievement" + newHistory.liftName! + String(describing: newHistory.timeStamp))*/
                    liftData.append(newHistory)
                }
            }
        }
        CoreDataController.saveContext()
        return liftData
    }
    
    class func saveHistoryToRedis(){
        let user = CoreDataController.getUser()
        let history = CoreDataController.getHistory()
        var postString = ""
        
        var request = URLRequest(url: URL(string: apiURL + "exercise/\(user.email!)/")!)
        
        request.httpMethod = "PUT"
        
        for lift in history{
            if let lift = lift as? LegacyLift{
                postString = "\"{date:\(lift.timeStamp),exercise:\(lift.liftName),sets:\(lift.liftSets),reps:\(lift.liftRep),weight:\(lift.liftWeight)}\""
                
                print(postString)
                
                let postDATA:Data = postString.data(using: String.Encoding.utf8)!
                request.httpBody = postDATA
                var responseString = ""
                let headers = [
                    "Content-Type": "application/json",
                    "Authorization": self.accessToken
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
                    
                    print("Did save Historic lift " + lift.liftName! + String(describing: lift.timeStamp) + " to redis?  " + responseString)
                    
                    
                    sem.signal()
                }
                
                task.resume()
                sem.wait()
            }
        }
    }
}
