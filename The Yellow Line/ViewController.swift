//
//  ViewController.swift
//  The Yellow Graph
//
//  Created by Yahya Ayash Luqman on 24/09/16.
//  Copyright © 2016 Yaluqman. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var gdate: UILabel!
    @IBOutlet weak var graphView2: UIView!
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                FIRDatabase.database().reference().child("profile").child((user?.uid)!).observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) -> Void in
                    self.username.text = (snapshot.value as! NSDictionary)["name"] as! String
                })
                // Get the graph view and draw a graph (main)
                self.graphView.layer.sublayers = nil;
                self.graphView2.layer.sublayers = nil;
                
                let lastWeekDate = NSCalendar.current.date(byAdding: .weekOfYear, value: -1, to: NSDate() as Date)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy MMM dd"
                let string = dateFormatter.string(from: NSCalendar.current.date(byAdding: .day, value: 1, to: lastWeekDate!)!)
                self.gdate.text = string
                _ = Graph(graphView: self.graphView, date: lastWeekDate!, completion: {()->Void in
                    self.indicator.isHidden = true
                })
                
                let prevWeekDate = NSCalendar.current.date(byAdding: .weekOfYear, value: -2, to: NSDate() as Date)
                _ = Graph(graphView: self.graphView2, date: prevWeekDate!, completion: {()->Void in
                })
            } else {
                // No user is signed in.
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "vc3")
                self.present(vc, animated: true)
            }
        }
    }
}
