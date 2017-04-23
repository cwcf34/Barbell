//
//  GraphView.swift
//  graphZ
//
//  Created by Mr. Lopez on 4/11/17.
//  Copyright © 2017 DLopezPrograms. All rights reserved.
//

import UIKit

class GraphView: UIView {

    
    var pointsList = [CGRect]()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        
        if let context = UIGraphicsGetCurrentContext() {
            
            var fillColor = UIColor.black.cgColor
            let myShadowOffset = CGSize (width: 10,  height: 15)
            
            context.saveGState()
            context.setShadow(offset: myShadowOffset, blur: 5)
            
            context.setLineWidth(2.0)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setFillColor(fillColor)
            
            
            
            //let point = CGRect(x: 0,y: 0,width: 10,height: 10)\\
            
            
            var count = 0
            var previousPoint = CGFloat(0)
            let list = pointsList
            
            for point in list {
                
                if (count != 0){
                    previousPoint = list[count-1].midY
                    if (previousPoint == point.midY){
                        fillColor = UIColor.orange.cgColor
                    }else if (previousPoint > point.midY) {
                        fillColor = UIColor.green.cgColor
                    }else{
                        fillColor = UIColor.red.cgColor
                    }
                }
                
                
                context.addEllipse(in: point)
                context.setFillColor(fillColor)
                context.fillEllipse(in: point)
                
                
                if (count != list.count-1){
                    context.move(to: CGPoint.init(x: point.midX, y: point.midY))
                    context.addLine(to: CGPoint.init(x: list[count+1].midX, y: list[count+1].midY))
                    context.strokePath()
                }
                
                //context.addEllipse(in: point)
                
                count += 1
            }
            
            context.restoreGState()
        }
    }
    
    public func setList(data: [CGRect]) {
        pointsList = data
    }
    public func getList() -> [CGRect] {
        return pointsList
    }
    

}
