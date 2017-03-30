//
//  tempView.swift
//  gMaps
//
//  Created by Jose Mejia on 3/27/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit

let π:CGFloat = CGFloat(M_PI)
let NoOfGlasses = 8

@IBDesignable class tempView: UIView {
    
    @IBInspectable var counter: Int = 5
    let detailPopup = UIButton()
    let refreshButton = UIButton()
    
    @IBInspectable var counterColor: UIColor = UIColor(red:0.26, green:0.52, blue:0.96, alpha:1.0)
    
    @IBInspectable var temp = "23ºC" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var fontSize:CGFloat = 15.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var radius:CGFloat = max(55.0, 55.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shrink:CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // Drawing code
        
        // 1
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        
        // 3
        let arcWidth: CGFloat = 4
        
        // 4
        let startAngle: CGFloat = (3 * π)/2
        let endAngle: CGFloat = (3 * π)/2-0.00001
        
        // 5
        let path = UIBezierPath(arcCenter: center,
                                radius: radius/2 - arcWidth/2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.stroke()
        
        
        let fieldColor: UIColor = UIColor(red:0.92, green:0.26, blue:0.21, alpha:1.0)
        
        // set the font to Helvetica Neue 18
        let fieldFont = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        
        // set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        
        // set the Obliqueness to 0.1
        let skew = 0
        
        let attributes: NSDictionary = [
            NSForegroundColorAttributeName: fieldColor,
            NSParagraphStyleAttributeName: paraStyle,
            NSObliquenessAttributeName: skew,
            NSFontAttributeName: fieldFont!
        ]
        
        temp.draw(in: CGRect(x:(self.bounds.width/2)-(120/2), y:(self.bounds.height/2)-(fontSize/1.6), width:120.0, height:fontSize), withAttributes: attributes as? [String : Any])
        
        
        //detailPopup.setTitle("I", for: .normal)
        detailPopup.setImage(UIImage(named: "info.png"), for: .normal)
        //detailPopup.setTitleColor(UIColor.black, for: UIControlState.normal)
        //detailPopup.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        detailPopup.backgroundColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0)
        detailPopup.layer.cornerRadius = 10
        //detailPopup.layer.borderColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0.6).cgColor
        //detailPopup.layer.borderWidth = 2
        
        detailPopup.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        addSubview(detailPopup)
        
        detailPopup.frame = CGRect(x: (bounds.size.width/2)-10, y: 0, width: 20, height: 20)
        
        
        
        //refreshButton.setTitle("R", for: .normal)
        //refreshButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        refreshButton.setImage(UIImage(named: "refresh.png"), for: .normal)
        //refreshButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        refreshButton.layer.cornerRadius = 10
        //refreshButton.layer.borderColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0.6).cgColor
        //refreshButton.layer.borderWidth = 2
        refreshButton.backgroundColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0)
        
        refreshButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        addSubview(refreshButton)
        
        refreshButton.frame = CGRect(x: 0, y: (bounds.size.height/2)-10, width: 20, height: 20)
        
        let refPath = UIBezierPath()
        
        refPath.move(to: CGPoint(x: 27, y: bounds.size.height/2))
        
        refPath.addLine(to: CGPoint(x: (bounds.size.width/2)-(20+shrink), y: bounds.size.height/2))
        
        refPath.move(to: CGPoint(x: bounds.size.width-27, y: bounds.size.height/2))
        
        refPath.addLine(to: CGPoint(x: (bounds.size.width/2)+(20+shrink), y: bounds.size.height/2))
        
        refPath.move(to: CGPoint(x: bounds.size.width/2, y: bounds.size.height-27))
        
        refPath.addLine(to: CGPoint(x: bounds.size.width/2, y: (bounds.size.height/2)+(15+shrink)))
        
        refPath.move(to: CGPoint(x: bounds.size.width/2, y: 27))
        
        refPath.addLine(to: CGPoint(x: bounds.size.width/2, y: (bounds.size.height/2)-(15+shrink)))
        
        refPath.lineWidth = 4
        
        //Keep using the method addLineToPoint until you get to the one where about to close the path
        
        refPath.close()
        
        //If you want to stroke it with a red color
        //UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0.6).setStroke()
        refPath.stroke()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.radius = max(70.0, 70.0)
        self.shrink = 8.0
        self.detailPopup.isHidden = false
        self.refreshButton.isHidden = false
        self.fontSize = 20
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            //print("Touch: \(touch.location(in: self))")
            let currentPoint = touch.location(in: self)
            
            let infoPositionY = detailPopup.frame.origin.y + (detailPopup.frame.height/2)
            let infoPositionX = detailPopup.frame.origin.x + (detailPopup.frame.width/2)
            
            let refreshPositionY = refreshButton.frame.origin.y + (refreshButton.frame.height/2)
            let refreshPositionX = refreshButton.frame.origin.x + (refreshButton.frame.width/2)
            
            let refreshBtnDistX = currentPoint.x - refreshPositionX
            let refreshBtnDistY = refreshPositionY - currentPoint.y
            
            //print("ButtonX: (\(infoPositionX), \(infoPositionY))")
            
            let infoBtnDistX = currentPoint.x - infoPositionX
            let infoBtnDistY = infoPositionY - currentPoint.y
            
            //print("distanceX: \(infoBtnDistX), distanceY: \(infoBtnDistY)")
            if (infoBtnDistX >= -10 && infoBtnDistX <= 10) && (infoBtnDistY >= -10 && infoBtnDistY <= 10) {
                self.detailPopup.sendActions(for: .touchUpInside)
            }
            
            if (refreshBtnDistY >= -10 && refreshBtnDistY <= 10) && (refreshBtnDistX >= -10 && refreshBtnDistX <= 10) {
                self.refreshButton.sendActions(for: .touchUpInside)
            }
        }
        self.radius = max(55.0, 55.0)
        self.shrink = 0.0
        self.detailPopup.isHidden = true
        self.refreshButton.isHidden = true
        self.fontSize = 15
    }
    

}
