//
//  PlacesTableViewController.swift
//  gMaps
//
//  Created by Jose Mejia on 5/6/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit
import CoreData

class PlacesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var placesArray = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place_type")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    self.placesArray.append(result)
                }
                
            } else {
                print("No results")
            }
            
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows:Int!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place_type")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            numberOfRows = results.count
            
        } catch {
            print("Couldn't fetch results")
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "place_type", for: indexPath)
        
        // Configure the cell...
        
        let checkButton = UIButton()
        
        //checkButton.setTitle("+", for: .normal)
        //checkButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        //checkButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 23)
        //checkButton.addTarget(self, action: #selector(GMStepper.plus), for: UIControlEvents.touchUpInside)
        cell.addSubview(checkButton)
        
        checkButton.frame = CGRect(x: (cell.bounds.size.width - cell.bounds.size.height)-4, y: 10, width: cell.bounds.size.height-20, height: cell.bounds.size.height-20)
        
        cell.textLabel?.text = placesArray[indexPath.row].value(forKey: "type") as? String
        
        //print("\(placesArray[indexPath.row].value(forKey: "isSelected") as! Int)")
        
        
        if placesArray[indexPath.row].value(forKey: "isSelected") as! Bool == true {
            checkButton.layer.cornerRadius = 11.5
            checkButton.backgroundColor = UIColor(red:0.56, green:1.00, blue:0.00, alpha:1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
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
