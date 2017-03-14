//
//  LoginInfo.swift
//  Barbell
//
//  Created by Curtis Markway on 3/14/17.
//  Copyright © 2017 Team Barbell. All rights reserved.
//

import Foundation

public class LoginInfo {
    var email: String
    var password: String
    var client_id: String
    var client_secret: String
    var grant_type: String
    
    init(email: String, password: String, client_id: String, client_secret: String) {
        self.email = email
        self.password = password
        self.client_id = client_id
        self.client_secret = client_secret
        self.grant_type = "password"
    }
}
