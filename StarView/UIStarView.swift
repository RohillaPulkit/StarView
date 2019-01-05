//
//  UIStarView.swift
//  StarView
//
//  Created by Pulkit Rohilla on 24/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

@IBDesignable
class UIStarView: UIView {

    @IBInspectable var color : UIColor = UIColor.black
    @IBInspectable var progress : CGFloat = 0

    var defaultDimension: CGFloat = 44.0
    let adjustmentAngle: CGFloat = 630.25
    let defaultSides = 5
    let defaultPointyness: CGFloat = 2

    override var intrinsicContentSize: CGSize{
        
        return CGSize(width: defaultDimension, height: defaultDimension)
    }
    
    override func draw(_ rect: CGRect) {

        super.draw(rect)
        
        UIColor.clear.setFill()
        UIRectFill(rect)
        
        self.drawStar(fillWithProgress: progress)
    }
    
    func degree2radian(a:CGFloat)->CGFloat {
        
        let b = CGFloat(M_PI) * a/180
        return b
    }
    
    func polygonPointArray(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
        
        let angle = degree2radian(a: 360/CGFloat(sides))
        let cx = x // x origin
        let cy = y // y origin
        let r  = radius // radius of circle
        var i = sides
        var points = [CGPoint]()
        
        while points.count <= sides {
                        
            let xpo = cx - r * cos(angle * CGFloat(i)+degree2radian(a: adjustment))
            let ypo = cy - r * sin(angle * CGFloat(i)+degree2radian(a: adjustment))
            points.append(CGPoint(x: xpo, y: ypo))
            i -= 1;
        }
        
        return points
    }
    
    func starPath(frame : CGRect, sides:Int,
                  pointyness:CGFloat) -> CGPath {
        
        let x = frame.midX
        let y = frame.midY
        let radius = frame.width/4
        
        let adjustment = CGFloat(360/sides/2) + adjustmentAngle
        let path = CGMutablePath()
        let points = polygonPointArray(sides: sides, x: x, y: y, radius: radius, adjustment: adjustmentAngle)
        let cpg = points[0]
        let points2 = polygonPointArray(sides: sides, x: x, y: y, radius: radius * pointyness, adjustment: adjustment)

        var i = 0
        
        path.move(to: CGPoint(x: cpg.x, y: cpg.y))
        
        for p in points {
            
            path.addLine(to: CGPoint(x: points2[i].x, y: points2[i].y))
            path.addLine(to: CGPoint(x: p.x, y: p.y))

            i += 1
        }
        
        path.closeSubpath()
        
        return path
    }
    
//    func returnStarPath(size: CGSize) -> CGPath {
//        
//        let numberOfPoints: CGFloat = 5
//        
//        let starRatio: CGFloat = 0.4
//        
//        let steps: CGFloat = numberOfPoints * 2
//        
//        let outerRadius: CGFloat = min(size.height, size.width) / 2
//        let innerRadius: CGFloat = outerRadius * starRatio
//        
//        let stepAngle = CGFloat(2) * CGFloat(M_PI) / CGFloat(steps)
//        let center = CGPoint(x: size.width / 2, y: size.height / 1.8)
//        
//        let path = CGMutablePath()
//        
//        for i in 0..<Int(steps) {
//            
//            let radius = i % 2 == 0 ? outerRadius : innerRadius
//            
//            let angle = CGFloat(i) * stepAngle - CGFloat(M_PI_2)
//            
//            let x = radius * cos(angle) + center.x
//            let y = radius * sin(angle) + center.y
//            
//            if i == 0 {
//                path.move(to: CGPoint(x: x, y: y))
//            }
//            else {
//                path.addLine(to: CGPoint(x: x, y: y))
//            }
//        }
//        
//        path.closeSubpath()
//
//        return path
//    }
    
    func drawStar(fillWithProgress progress : CGFloat){
        
        let starPath = UIBezierPath.init(cgPath: self.starPath(frame: self.bounds, sides: defaultSides, pointyness: defaultPointyness))
        
        let frame : CGRect = self.bounds
        let frameWidth  = self.bounds.size.width
        let progress = progress
        let rightRectOfStar = CGRect(x: frame.origin.x + progress * frameWidth, y: frame.origin.y, width: frameWidth - progress * frameWidth, height: frame.size.height)
        let clipPath = UIBezierPath.init(rect: CGRect.infinite)
        let rectPath = UIBezierPath.init(rect: rightRectOfStar)
        clipPath.append(rectPath)
        clipPath.usesEvenOddFillRule = true
        
        UIColor.clear.setFill()
        starPath.fill()
        
        let currentContext = UIGraphicsGetCurrentContext()
        
        currentContext!.saveGState()
        
        clipPath.addClip()
        color.setFill()
        starPath.fill()
        
        currentContext!.restoreGState()
        
        color.setStroke()
        starPath.stroke()
    }
}
