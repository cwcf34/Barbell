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
    class func connectToDatabase(registerInfo: RegisterInfo) -> Bool {
        var request = URLRequest(url: URL(string: "http://bbapi.eastus.cloudapp.azure.com/api/user/\(registerInfo.email)/")!)
        request.httpMethod = "POST"
        
        
        print("Request STRING \(request)")
        
        //"{name:hi ads, password:kj}"\\
        let postString = "\"{name:\(registerInfo.firstName)" + " " + "\(registerInfo.lastName)" + ", " + "password:\(registerInfo.password)}\" "
        //print("POST STRING::\(postString)")
        
        let postDATA:Data = postString.data(using: String.Encoding.utf8)!
        
        request.httpBody = postDATA
        
        /*
        do {
            let postData = try JSONSerialization.data(withJSONObject: postString, options: [])
            print ("\n\(postData)\n\n\n")
        } catch {
            let err = error as NSError
            print("ERROR IS \(err)")
        }
    
        
        if let postData = try JSONSerialization.jsonObject(with: (postString as? Data)!, options: []) {
            
        }catch{
            
        }
        */
        
       
        
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
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
        return true
    }
    
    class func createWorkout(workoutModel: WorkoutModel) -> Bool {
        var request = URLRequest(url: URL(string: "http://bbapi.eastus.cloudapp.azure.com/api/user/c@me.com/")!)
        request.httpMethod = "PUT"
        
        print("Request STRING \(request)")
        
        //"{name:hi ads, password:kj}"\\
        let putString = "\"{id:\(workoutModel.id)" + "," + "name:\(workoutModel.name)" + "," + "weight:\(workoutModel.weight)}\" "
        print("PUT STRING::\(putString)")
        
        do {
            let putData = try JSONSerialization.data(withJSONObject: putString, options: [])
            print ("\n\(putData)\n\n\n")
        } catch {
            let err = error as NSError
            print("ERROR IS \(err)")
        }
        
        /*
         if let postData = try JSONSerialization.jsonObject(with: (postString as? Data)!, options: []) {
         
         }catch{
         
         }
         */
        
        
        
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
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
        return true
    }
}
