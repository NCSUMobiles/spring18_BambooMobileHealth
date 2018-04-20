//
//  LoginViewController.swift
//  BMH
//
//  Created by Shreyas Zagade on 4/3/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var username: String = ""//= "PPV44"
    var password: String = "" //= "password"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // eventually the login should happen against a back end.
    fileprivate func performLogin() {
        username = (usernameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
        password = passwordTextField.text!
        
        if (username.count == 0) {
            let alert = UIAlertController(title: "Error!", message: "Please enter a username", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (password.count == 0) {
            let alert = UIAlertController(title: "Error!", message: "Please enter a password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            // now post a login request
            activityIndicator.isHidden = false
            usernameTextField.isEnabled = false
            passwordTextField.isEnabled = false
            activityIndicator.startAnimating()
            
            Alamofire.request(
                URL(string: "http://35.196.193.243/api/login")!,
                method: .post,
                parameters: ["username": username, "password": password.sha256()])
                .responseJSON { (response) -> Void in
                    
                    if response.response?.statusCode == 200 {
                        // read token here
                        let customToken = (response.result.value as? [String: Any])?["token"] as? String
                        
                        // now pass this to Firebase for authentication
                        Auth.auth().signIn(withCustomToken: customToken ?? "") { (user, error) in
                            if error == nil {
                                self.activityIndicator.isHidden = true
                                self.usernameTextField.isEnabled = true
                                self.passwordTextField.isEnabled = true
                                self.activityIndicator.stopAnimating()
                                
                                // Authentication successful, proceed forward
                                LoginHelper.saveLogedInUser(userId: self.username)
                                let appDelegate  = (UIApplication.shared.delegate) as! AppDelegate
                                appDelegate.loadFromJSON()
                                self.performSegue(withIdentifier: "loginToTabBar", sender: self)
                            }
                            else {
                                print ("Error authenticating with Firebase")
                                let alert = UIAlertController(title: "Network Error", message: "Couldn't connect to authentication server. Please try again later.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    } else if response.response?.statusCode == 401 {
                        print("Incorrect Username Password")
                        let alert = UIAlertController(title: "Invalid Credentials", message: "Please check your credentials and try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if response.response?.statusCode == 403 {
                        print("Username not found")
                        let alert = UIAlertController(title: "Oops!", message: "We could not find a user account matching that name.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if response.response?.statusCode == 500 {
                        print("Couldn't create authentication token")
                        let alert = UIAlertController(title: "Oops!", message: "Something went wrong. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print ("Some other error on server")
                        let alert = UIAlertController(title: "Network Error", message: "Couldn't connect to authentication server. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    self.activityIndicator.isHidden = true
                    self.usernameTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                    self.activityIndicator.stopAnimating()
            }
        }
        
        /*
         if(usernameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == username && passwordTextField.text == password) {
         LoginHelper.saveLogedInUser(userId: username)
         let appDelegate  = (UIApplication.shared.delegate) as! AppDelegate
         appDelegate.loadFromJSON()
         performSegue(withIdentifier: "loginToTabBar", sender: self)
         }
         else {
         print("Incorrect Username Password")
         let alert = UIAlertController(title: "Oops!", message: "Incorrect Username/Password", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
         self.present(alert, animated: true, completion: nil)
         }
         */
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
