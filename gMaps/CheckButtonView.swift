//
//  CheckButtonView.swift
//  gMaps
//
//  Created by Jose Mejia on 5/7/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit

@IBDesignable class CheckButtonView: UIView {
    
    var isActive = false

    @IBInspectable var fillColor:UIColor = UIColor(red:0.23, green:0.78, blue:0.44, alpha:0.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var strokeColor:UIColor = UIColor(red:0.48, green:0.47, blue:0.47, alpha:1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let origin = CGPoint(x: 1, y: 1)
        let size = CGSize(width: self.bounds.width-2, height: self.bounds.height-2)
        let circle = CGRect(origin: origin, size: size)
        let circlePath = UIBezierPath(ovalIn: circle)
        
        strokeColor.setStroke()
        
        circlePath.stroke()
        
        let smallOrigin = CGPoint(x: self.bounds.midX/2, y: self.bounds.midX/2)
        let smallSize = CGSize(width: self.bounds.width/2, height: self.bounds.height/2)
        let smallCircle = CGRect(origin: smallOrigin, size: smallSize)
        let smallCirclePath = UIBezierPath(ovalIn: smallCircle)
        
        fillColor.setFill()
        strokeColor.setStroke()
        
        smallCirclePath.stroke()
        smallCirclePath.fill()
    }
    

}
