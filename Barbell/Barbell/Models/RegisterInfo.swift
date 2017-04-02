//
//  registerInfo.swift
//  Barbell
//
//  Created by Cody Cameron on 2/21/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation

public class RegisterInfo {
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    
    init(email: String, password: String, firstName: String, lastName: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
}
