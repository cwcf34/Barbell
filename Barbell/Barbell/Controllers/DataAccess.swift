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
        print("this is register postString" + postString)
        
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
                print("this is register reponse string: " + responseString )
                
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
    
    class func setUser(user: User) -> Bool {
        var request = URLRequest(url: URL(string: apiURL + "user/" + user.email! + "/")!)
        request.httpMethod = "PUT"
        
        var responseString  = "false"
        
        print("Request STRING \(request)")
        
        //let putString = "\"{id:\(workoutModel.id)" + "," + "name:\(workoutModel.name)" + "," + "weight:\(workoutModel.weight)}\" "
        let putString = "\"{name:\(user.fname!)" + " " + "\(user.lname!)" + "," + "email:" + "," + "password:" + "," + "age:\(user.age)" + "," + "weight:\(user.weight)" + "," + "squat:\(user.squat)" + "," + "bench:\(user.bench)" + "," + "deadlift:\(user.deadlift)" + "," + "snatch:\(user.snatch)" + "," + "cleanjerk:\(user.cleanAndJerk)}\" "
        
        let postDATA:Data = putString.data(using: String.Encoding.utf8)!
        
        request.httpBody = postDATA
    
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
        
        if(responseString == "true"){
            return true
        } else{
            return false
        }
    }
    
    class func login (loginInfo: LoginInfo ) -> Bool{
        var request = URLRequest(url: URL(string: apiURL + "login/\(loginInfo.email)/")!)
        
        var responseString  = "false"
        var result = false
        request.httpMethod = "POST"
        
        let postString = "\"{password:\(loginInfo.password)}\" "
        print("this is postString: " + postString)
        
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
            
            responseString = String(data: data, encoding: .utf8)!
            print("this is login response string: " + responseString)
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
        
        var tokensA = responseString.components(separatedBy: ",")
        var tokensNames = tokensA[0].components(separatedBy: " ")
        var tokensEmail = tokensA[2].components(separatedBy: " ")
        var tokensAge = tokensA[4].components(separatedBy: " ")
        var tokensWeight = tokensA[9].components(separatedBy: " ")
        var tokensSquat = tokensA[3].components(separatedBy: " ")
        var tokensBench = tokensA[7].components(separatedBy: " ")
        var tokensDeadlift = tokensA[1].components(separatedBy: " ")
        var tokensSnatch = tokensA[6].components(separatedBy: " ")
        var tokensCJ = tokensA[5].components(separatedBy: " ")
        var tokensWO = tokensA[10].components(separatedBy: " ")
        
        user.fname = tokensNames[1]
        user.lname = tokensNames[2]
        user.email = tokensEmail[1]
        user.age = Int16(tokensAge[1])!
        user.weight = Int16(tokensWeight[1])!
        user.squat = Int16(tokensSquat[1])!
        user.bench = Int16(tokensBench[1])!
        user.deadlift = Int16(tokensDeadlift[1])!
        user.snatch = Int16(tokensSnatch[1])!
        user.cleanAndJerk = Int16(tokensCJ[1])!
        user.workoutsCompleted = 0//Int16(tokensWO[1])!
        
        
        CoreDataController.saveContext()
        return 

    }
}
