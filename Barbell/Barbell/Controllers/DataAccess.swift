//
//  DataAccess.swift
//  Barbell
//
//  Created by Cody Cameron on 2/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation

public class DataAccess {
    class func connectToDatabase(registerInfo: RegisterInfo) -> Bool {
        var request = URLRequest(url: URL(string: "http://bbserver.eastus.cloudapp.azure.com/api/user/\(registerInfo.email)/" )!)
        request.httpMethod = "POST"
        let postString = "\(registerInfo.firstName)" + " " + "\(registerInfo.lastName)" + "\(registerInfo.password)"
        request.httpBody = postString.data(using: .utf8)
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
