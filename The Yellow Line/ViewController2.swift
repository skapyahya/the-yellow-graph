//
//  ViewController2.swift
//  The Yellow Graph
//
//  Created by Yahya Ayash Luqman on 26/09/16.
//  Copyright © 2016 Yaluqman. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController2: UIViewController {

    @IBOutlet weak var mValue: UITextField!
    @IBOutlet weak var mDate: UIDatePicker!
    @IBAction func closeController(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func doneController(_ sender: UIButton) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference();
        ref.child("mood").child(uid!).child(String(Int(mDate.date.timeIntervalSince1970))).setValue(mValue.text)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
