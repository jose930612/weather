//
//  PopupViewController.swift
//  gMaps
//
//  Created by Jose Mejia on 3/28/17.
//  Copyright © 2017 ITink. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var humidityInfo: UILabel!
    @IBOutlet weak var pressureInfo: UILabel!
    @IBOutlet weak var weatherInfo: UILabel!
    @IBOutlet weak var weatherImgIcon: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0)
        
        /*let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)*/
        
        popView.backgroundColor = UIColor(red:0.26, green:0.52, blue:0.96, alpha:1.0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func closePopup(_ sender: Any) {
        self.view.removeFromSuperview()
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
