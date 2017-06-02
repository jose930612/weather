//
//  StatsViewController.swift
//  gMaps
//
//  Created by Jose Mejia on 6/1/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit
import Firebase

class StatsViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var maxLabel: UILabel!
    
    var ref = FIRDatabase.database().reference()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0)
        
        
        self.graphPoint()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.graphPoint()
    }
    
    
    @IBAction func closeView(_ sender: Any) {
        
        self.view.removeFromSuperview()
        
    }
    
    
    func graphPoint(){
        
        //self.graphView.graphPoints.remove(at: 0)
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let year =  components.year!
        let month = components.month!
        let day = components.day!
        //let hour = components.hour!
        //let minute = components.minute!
        
        var dateString = "\(month)-\(day)-\(year)"
        //var timeString = "\(hour):\(minute)"
        
        //let userID = ""
        ref.child("weather").child(dateString).observeSingleEvent(of: .value, with: { (weatherData) in
            // Get user value
            let values = weatherData.value as? NSDictionary
            for (key,_) in values! {
                let data = values![key] as? NSDictionary
                //let tempString = data?["temperature"]! as! Int
                let temperature = data?["temperature"]! as! Int
                /*if self.graphView.graphPoints.count == 1 {
                    self.graphView.graphPoints[0] = temperature
                }else {*/
                    self.graphView.graphPoints.append(temperature)
                //}
                
                //print("Temp: \(temperature)")
                
            }
            
            self.maxLabel.text = "\(self.graphView.graphPoints.max()!)"
            
            //let data = value!["12:13"] as? NSDictionary
            
            //let username = value?["12:13"][""] as? String ?? ""
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
