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
    
    class func createWorkout(workoutModel: WorkoutModel) -> Bool {
        var request = URLRequest(url: URL(string: apiURL + "user/c@me.com/")!)
        request.httpMethod = "PUT"
        
        var responseString  = "false"
        
        print("Request STRING \(request)")
        
        let putString = "\"{id:\(workoutModel.id)" + "," + "name:\(workoutModel.name)" + "," + "weight:\(workoutModel.weight)}\" "
        
        do {
            let putData = try JSONSerialization.data(withJSONObject: putString, options: [])
            print ("\n\(putData)\n\n\n")
        } catch {
            let err = error as NSError
            print("ERROR IS \(err)")
        }
        
        let headers = [
            "content-type": "application/json"
        ]
        
        request.allHTTPHeaderFields = headers
        
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
            print("responseString = \(responseString)")
        }
        task.resume()
        //sem.wait()
        
        if(responseString == "true"){
            return true
        } else{
            return false
        }
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
            print("responseString = \(responseString)")
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
        //var token = [String]()
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

    class func saveUserToRedis(email : String){
        let user = CoreDataController.getUser()
        print(email)
        //var request = URLRequest(url: URL(string: apiURL + "user/\(user.first?.email)/")!)
        var request = URLRequest(url: URL(string: apiURL + "user/\(email)/")!)
        request.httpMethod = "PUT"
        let putString = "\"{name:\(String(describing: user.first?.fname)) " + "\(String(describing: user.first?.lname))" + "," + "password:" + "," + "age:\(String(describing: user.first?.age))" + "," + "weight:\(String(describing: user.first?.weight))" + "," + "squat:\(String(describing: user.first?.squat))" + "," + "bench:\(String(describing: user.first?.bench))" + "," + "deadlift:\(String(describing: user.first?.deadlift))" + "," + "snatch:\(String(describing: user.first?.snatch))" + "," + "cleanjerk:\(String(describing: user.first?.cleanAndJerk))" + "," + "workoutsCompleted:\(String(describing: user.first?.workoutsCompleted))}\" "
        var responseString = ""
        let headers = [
            "content-type": "application/json"
        ]
    
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
