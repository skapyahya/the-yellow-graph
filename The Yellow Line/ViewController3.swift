//
//  ViewController3.swift
//  The Yellow Line
//
//  Created by Yahya Ayash Luqman on 27/09/16.
//  Copyright © 2016 Yaluqman. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController3: UIViewController {

    @IBOutlet weak var login_email: UITextField!
    @IBOutlet weak var login_password: UITextField!
    @IBOutlet weak var signup_email: UITextField!
    @IBOutlet weak var signup_uname: UITextField!
    @IBOutlet weak var signup_password: UITextField!
    @IBOutlet weak var signup_therapist: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: AnyObject) {
        let email = login_email.text;
        let password = login_password.text;
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: {(user, error) in
            if user != nil {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func createUserAndLogin(_ sender: AnyObject) {
        let email = signup_email.text;
        let password = signup_password.text;
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
            // ...
            if((error) != nil) {
                // Handle Error
                print(error)
            }
            let uid = user?.uid;
            var ref: FIRDatabaseReference!
            ref = FIRDatabase.database().reference()
            ref.child("profile").child(uid!).child("name").setValue(self.signup_uname.text)
            ref.child("profile").child(uid!).child("therapist").setValue(self.signup_therapist.isOn)
            self.dismiss(animated: true, completion: nil)
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
