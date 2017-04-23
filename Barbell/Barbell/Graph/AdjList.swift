//
//  AdjList.swift
//  graphZ
//
//  Created by Mr. Lopez on 4/11/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import Foundation
import UIKit

class AdjList{
    var adjacencyList: [CGRect] = []
    
    func setList(_ list: [CGRect]){
        adjacencyList = list
    }
    
    func addVertex(newPoint: CGRect){
        adjacencyList.append(newPoint)
    }
}
