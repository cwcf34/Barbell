//
//  ExerciseParser.swift
//  Barbell
//
//  Created by Darryl Lopez on 3/24/17.
//  Copyright © 2017 Team Barbell. All rights Preserved.
//

import Foundation
import UIKit

public class ExerciseParser {
   
    //MARK: Load Json
    static func loadWorkoutJson(){
        let bundle = Bundle.main
        
        if let path = bundle.path(forResource: "workouts", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
            parseJson(data: data)
        }
    }
    
    //MARK: - Parse Json
    private static func parseJson(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let root = json as? [String: Any]{
            
            print("\n\n ROOT DATA \(root)\n\n")
        
        }
    }
    
    
}
