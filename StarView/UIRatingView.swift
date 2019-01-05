//
//  UIRatingView.swift
//  StarView
//
//  Created by Pulkit Rohilla on 24/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

@IBDesignable
class UIRatingView: UIView {

    @IBInspectable var height: CGFloat = 44.0
    @IBInspectable var isInteractionEnabled : Bool = false
    
    @IBInspectable var fillColor : UIColor = UIColor.black
    @IBInspectable var emptyColor : UIColor = UIColor.clear
    @IBInspectable var backColor : UIColor = UIColor.clear
    
    @IBInspectable var starCount : Int = 5
    @IBInspectable var starSpacing : CGFloat = 0

    @IBInspectable var maximumValue : Int = 10
    @IBInspectable var minimumValue : Int  = 0
    @IBInspectable var progress : Int = 0
    
    let adjustmentAngle: CGFloat = 630.25
    let defaultSides = 5
    let defaultPointyness: CGFloat = 2
    
    override var intrinsicContentSize: CGSize{
        
        return CGSize(width: CGFloat(starCount) * (height + starSpacing), height: height)
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        backColor.setFill()
        UIRectFill(rect)
        
        var frame : CGRect = rect
        frame.size.width = height
        frame.origin.x += starSpacing/2
        
        let starRating = returnStarRating()
        
        let completeStars = Int(starRating);
        
        var inCompleteStars = 0;
        let inCompleteRating = (starRating - CGFloat(completeStars))
        
        if inCompleteRating > 0 {
            
            inCompleteStars = 1
        }
        
        let emptyStars = starCount - completeStars - inCompleteStars
        
        for _ in 0 ..< completeStars
        {
            drawStar(frame: frame, progress: 1)
            
            frame.origin.x += frame.width + starSpacing
        }
        
        for _ in 0 ..< inCompleteStars
        {
            drawStar(frame: frame, progress: inCompleteRating)
            
            frame.origin.x += frame.width + starSpacing
        }
        
        for _ in 0 ..< emptyStars
        {
            drawStar(frame: frame, progress: 0)
            
            frame.origin.x += frame.width + starSpacing
        }
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
    
    func drawStar(frame : CGRect, progress : CGFloat){
        
        let starPath = UIBezierPath.init(cgPath: self.starPath(frame: frame, sides: defaultSides, pointyness: defaultPointyness))
        
        let frameWidth = frame.width

        let rightRectOfStar = CGRect(x: frame.origin.x + progress * frameWidth, y: frame.origin.y, width: frameWidth - progress * frameWidth, height: frame.size.height)
        let clipPath = UIBezierPath.init(rect: CGRect.infinite)
        let rectPath = UIBezierPath.init(rect: rightRectOfStar)
        clipPath.append(rectPath)
        clipPath.usesEvenOddFillRule = true
        
        emptyColor.setFill()
        starPath.fill()
        
        let currentContext = UIGraphicsGetCurrentContext()
        
        currentContext!.saveGState()
        
        clipPath.addClip()
        fillColor.setFill()
        starPath.fill()
        
        currentContext!.restoreGState()
        
        fillColor.setStroke()
        starPath.stroke()

    }

    func returnStarRating() -> CGFloat{
        
        var starRating : CGFloat = 0
        
        let stepPerStar = maximumValue / starCount
        
        if progress < minimumValue {
           
            progress = minimumValue
        }
        else if progress > maximumValue {
            
            progress = maximumValue
        }

        starRating = CGFloat(progress)/CGFloat(stepPerStar)

        print("Star Rating :\(starRating) & Progess :\(progress)")
        
        return starRating
    }
    
    func updateProgress(forTouchAtPoint point : CGFloat){
    
        let frame : CGRect = self.frame
        let starWidth = frame.width / CGFloat(starCount)
        
        let distance = point/starWidth
        
        var intDistance = Int(distance);
        var floatDistance = (distance - CGFloat(intDistance))
        
        let stepPerStar = maximumValue / starCount

        if stepPerStar == 2{
            
            if floatDistance < 0.25{
                
                floatDistance = 0
            }
            else if floatDistance >= 0.25 && floatDistance < 0.75 {
                
                floatDistance = 0.5
            }
            else if floatDistance >= 0.75
            {
                floatDistance = 0
                intDistance += 1
            }
        }
        
        if floatDistance > 0.9 {
            
            intDistance += 1
            floatDistance = 0
        }
        
        progress = Int((CGFloat(intDistance) + floatDistance)*CGFloat(stepPerStar))
                
        setNeedsDisplay()
    }
    
    //MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isInteractionEnabled
        {
            return
        }
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)

            if (hitTest(currentPoint, with: event) != nil)
            {
                updateProgress(forTouchAtPoint: currentPoint.x)
            }
        
        }
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isInteractionEnabled
        {
            return
        }
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            
            if (hitTest(currentPoint, with: event) != nil)
            {
                updateProgress(forTouchAtPoint: currentPoint.x)
            }
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isInteractionEnabled
        {
            return
        }
        
        if let touch = touches.first {
            
            let currentPoint = touch.location(in: self)

            if (hitTest(currentPoint, with: event) != nil)
            {
                updateProgress(forTouchAtPoint: currentPoint.x)
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if self.bounds.contains(self.convert(point, from: self)) {
            
            return self
        }
        
        return nil
    }
}
