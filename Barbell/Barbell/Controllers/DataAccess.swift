//
//  DataAccess.swift
//  Barbell
//
//  Created by Cody Cameron on 2/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import UIKit
import Foundation


public class DataAccess {
    
    private static var apiURL = "http://bbapi.eastus.cloudapp.azure.com/api/"
    class func register(registerInfo: RegisterInfo) -> Bool {
        var request = URLRequest(url: URL(string: apiURL + "user/\(registerInfo.email)/")!)
        request.httpMethod = "POST"
        
        var responseString = "false"
        
        print("Request STRING \(request)")
        
        let postString = "\"{name:\(registerInfo.firstName)" + ", " + "\(registerInfo.lastName)" + ", " + "password:\(registerInfo.password)}\" "
        
        let postDATA:Data = postString.data(using: String.Encoding.utf8)!
        
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
    
    class func createWorkout(workoutModel: WorkoutModel) -> Bool {
        var request = URLRequest(url: URL(string: apiURL + "user/c@me.com/")!)
        request.httpMethod = "PUT"
        
        var responseString  = "false"
        
        print("Request STRING \(request)")
        
        let putString = "\"{id:\(workoutModel.id)" + "," + "name:\(workoutModel.name)" + "," + "weight:\(workoutModel.weight)}\" "
        print("PUT STRING::\(putString)")
        
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
}
