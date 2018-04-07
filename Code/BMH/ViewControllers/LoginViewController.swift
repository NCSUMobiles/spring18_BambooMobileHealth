//
//  LoginViewController.swift
//  BMH
//
//  Created by Shreyas Zagade on 4/3/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var username = "username"
    var password = "password"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func performLogin() {
        if(usernameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == username && passwordTextField.text == password) {
            LoginHelper.saveLogedInUser(userId: username)
            performSegue(withIdentifier: "loginToTabBar", sender: self)
        }
        else {
            print("Incorrect Username Password")
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        performLogin()
    }
    
    @IBAction func textFieldPrimaryAction(_ sender: UITextField) {
        performLogin()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? UITabBarController {
            (UIApplication.shared.delegate as! AppDelegate).initialTabConterllerSetup(rootTabBarController: destinationController)
        }
    }

}
