//
//  UIScoreView.swift
//  StarView
//
//  Created by Pulkit Rohilla on 27/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

@objc protocol UIScoreViewDelegate {
    
    func scoreForStarAtIndex(index : NSInteger) -> NSInteger
    func titleForStarAtIndex(index : NSInteger) -> NSString

}

@IBDesignable
class UIScoreView: UIView {
    
    @IBOutlet weak var delegate : AnyObject?

    @IBInspectable var starColor : UIColor = UIColor.black
    @IBInspectable var scoreColor : UIColor = UIColor.darkGray
    @IBInspectable var titleColor : UIColor = UIColor.black

    @IBInspectable var starCount : Int = 7
    
    let adjustmentAngle: CGFloat = 630.25
    let defaultSides = 5
    let defaultPointyness: CGFloat = 2
    
    var heightConstraint : NSLayoutConstraint!
    
    override func prepareForInterfaceBuilder() {
        
        let lblText = UILabel.init(frame: self.bounds)
        lblText.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        lblText.text = "UIScoreView"
        lblText.textAlignment = .center
        lblText.textColor = UIColor.darkGray
        
        self.layoutSubviews()
        self.addSubview(lblText)
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let frame : CGRect = self.bounds
        let frameHeight = frame.width / CGFloat(starCount)
        
        if (heightConstraint != nil) {
            
            self.removeConstraint(heightConstraint)
        }
        
        heightConstraint = NSLayoutConstraint.init(item: self,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: NSLayoutAttribute(rawValue: 0)!,
                                                       multiplier: 1.0,
                                                       constant: frameHeight)
        

        self.addConstraint(heightConstraint)

    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        UIColor.clear.setFill()
        UIRectFill(rect)
        
        var frame : CGRect = rect
        frame.size.width = frame.width / CGFloat(starCount)
        
        for index in 0 ..< starCount
        {
            drawStarWithScore(frame: frame, progress: 1, index: index)
            
            frame.origin.x += frame.width
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
    
    func drawStarWithScore(frame : CGRect, progress : CGFloat, index : NSInteger){
        
        let starPath = UIBezierPath.init(cgPath: self.starPath(frame: frame, sides: defaultSides, pointyness: defaultPointyness))
        
        starColor.setFill()
        starPath.fill()
        
        starColor.setStroke()
        starPath.stroke()
        
        drawScoreInFrame(frame: frame, index: index)
        drawTitleInFrame(frame: frame, index: index)
    }
    
    func drawTitleInFrame(frame : CGRect, index : NSInteger)
    {
        let frameHeight = frame.height
        let fontHeight  = frameHeight/8
                
        let textRect = CGRect.init(x: frame.origin.x, y: frame.origin.y + 5, width: frame.width, height: frame.height)
        
        var title : NSString = ""
        
        if self.delegate != nil {
            
            title = (self.delegate?.titleForStarAtIndex(index: index))!
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let font = UIFont.systemFont(ofSize: fontHeight, weight: 0.002)
        
        let textFontAttributes = [NSForegroundColorAttributeName: titleColor,
                                  NSParagraphStyleAttributeName : paragraphStyle,
                                  NSFontAttributeName : font] as [String : Any]
        
        title.draw(in: textRect, withAttributes: textFontAttributes)
    }
    
    func drawScoreInFrame(frame : CGRect, index : NSInteger)
    {
        let frameHeight = frame.height
        let fontHeight  = frameHeight/2 - 10
        
        let yOffSet = frame.midY - fontHeight/2 - 5
        
        let textRect = CGRect.init(x: frame.origin.x, y: yOffSet, width: frame.width, height: frame.height)
        
        var score = 0
        
        if self.delegate != nil {
            
            score = (self.delegate?.scoreForStarAtIndex(index: index))!
        }
        
        let scoreString : NSString = String(describing: score) as NSString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let font = UIFont.systemFont(ofSize: fontHeight)

        let textFontAttributes = [NSForegroundColorAttributeName: scoreColor,
                                  NSParagraphStyleAttributeName : paragraphStyle,
                                  NSFontAttributeName : font] as [String : Any]
        
        scoreString.draw(in: textRect, withAttributes: textFontAttributes)
    }
    
}
