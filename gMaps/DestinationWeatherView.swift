//
//  DestinationWeatherView.swift
//  gMaps
//
//  Created by Jose Mejia on 4/29/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit

@IBDesignable class DestinationWeatherView: UIView {
    
    @IBInspectable var tempText = "Temperature: ---ºC" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var humText = "Humidity: ---%" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var pressText = "Pressure: ----hPa" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var locationName = "Medellín, Antioquia, Medellín" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let temperatureLabel = UILabel()
    let humidityLabel = UILabel()
    let pressureLabel = UILabel()
    let locationLabel = UILabel()
    let closeButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        //locationLabel.backgroundColor = UIColor.red
        locationLabel.textColor = UIColor.white
        locationLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 19)
        locationLabel.text = String(locationName)
        locationLabel.textAlignment = NSTextAlignment.justified
        
        //temperatureLabel.backgroundColor = UIColor.red
        temperatureLabel.textColor = UIColor.white
        temperatureLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 19)
        temperatureLabel.text = String(tempText)
        temperatureLabel.textAlignment = NSTextAlignment.justified
        
        //humidityLabel.backgroundColor = UIColor.red
        humidityLabel.textColor = UIColor.white
        humidityLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 19)
        humidityLabel.text = String(humText)
        humidityLabel.textAlignment = NSTextAlignment.justified
        
        //pressureLabel.backgroundColor = UIColor.red
        pressureLabel.textColor = UIColor.white
        pressureLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 19)
        pressureLabel.text = String(pressText)
        pressureLabel.textAlignment = NSTextAlignment.justified
        
        //closeButton.backgroundColor = UIColor.red
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        closeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 23)
        
        addSubview(locationLabel)
        addSubview(temperatureLabel)
        addSubview(humidityLabel)
        addSubview(pressureLabel)
        addSubview(closeButton)

    }
    
    override func layoutSubviews() {
        locationLabel.frame = CGRect(x: 2, y: 0, width: bounds.size.width/1.08, height: bounds.size.height/4)
        temperatureLabel.frame = CGRect(x: 2, y: bounds.size.height/4, width: bounds.size.width/2, height: bounds.size.height/4)
        humidityLabel.frame = CGRect(x: 2, y: (bounds.size.height/4)*2, width: bounds.size.width/2, height: bounds.size.height/4)
        pressureLabel.frame = CGRect(x: 2, y: (bounds.size.height/4)*3, width: (bounds.size.width/2), height: bounds.size.height/4)
        closeButton.frame = CGRect(x: (bounds.size.width-22), y: 2, width: 20, height: 20)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
