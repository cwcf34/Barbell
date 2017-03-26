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
        if let path = bundle.path(forResource: "workouts", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                parseJson(data: data)
            }catch{
                let error = error as Error
                print(error)
            }
        }
    }
    
    //MARK: - Parse Json
    private static func parseJson(data: Data) {
        
        var dict: [String: Any] = [:]
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let root = json as? [String: Any] {
                
                for body in root {
                    print("\n\nNEW EX: \(body)\n\n")
                    
                    //let region = body.key as String
                        
                    if let muscleArray = body.value as? [String: Any] {
                        for muscle in muscleArray {
                            print("muscle: \(muscle.key)")
                            let musclePart = muscle.key
                            
                            if let exerciseArray = muscle.value as? [String] {
                                for ex in exerciseArray {
                                    print("exercise: \(ex)")
                                    dict["\(musclePart)"] = exerciseArray
                                }
                            }
                        }
                    }
                }
            }
        }catch {
            let error = error as Error
            print(error)
        }
    }
}
