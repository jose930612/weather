//
//  NotificationViewController.swift
//  gMaps
//
//  Created by Jose Mejia on 5/31/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let defaultNotifications:[Dictionary<String,String>] = [
        ["name":"Current Location",
         "time":"08:30 - Días entre semana",
         "latitude":"6.198078",
         "longitude":"-75.579523"],
        ["name":"Bogotá",
         "time":"18:20",
         "latitude":"4.728221",
         "longitude":"-74.034035"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return defaultNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminder", for: indexPath)
        
        cell.textLabel?.text = defaultNotifications[indexPath.row]["name"]
        cell.detailTextLabel?.text = defaultNotifications[indexPath.row]["time"]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        //let cell = tableView.cellForRow(at: indexPath)
        
        var latitud = defaultNotifications[indexPath.row]["latitude"]!
        var longitude = defaultNotifications[indexPath.row]["longitude"]!
        
        
        
        
        var alert:UIAlertController!
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitud)&lon=\(longitude)&APPID=722e31fed4758ec43905b234ed67369d&lang=sp"
        
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, AnyObject>
            
            let results:Dictionary<String, AnyObject>! = json
            
            //print(results)
            
            
            DispatchQueue.main.async(execute: {
                
                var description = ""
                
                if let weather = results["weather"] as? [[String:Any]], !weather.isEmpty {
                    description = "\(weather[0]["description"]!)"
                }
                
                //self.tableView.reloadData()
                let kelvin = results["main"]?["temp"] as! Double
                let celsius = round(kelvin - 273.15)
                
                
                alert = UIAlertController(title: "\(self.defaultNotifications[indexPath.row]["name"]!)", message: "La temperatura en \(self.defaultNotifications[indexPath.row]["name"]!) es de \(NSNumber(value: celsius))ºC\nel pronostico es:\n\(description)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            })
            
            }.resume()
        
    }
    /*
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func request () {
        
        
        
    }

}
