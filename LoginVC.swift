//
//  LoginVC.swift
//  staffspace
//
//  Created by Tuan Ma on 8/23/18.
//  Copyright © 2018 Tuan Ma. All rights reserved.
//
import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    let indicator = ActivityIndicator()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginBtn(_ sender: Any) {
        
        let email = emailTextField.text?.trim();
        let password = passwordTextField.text?.trim();
       
    
        //Checks if email and password textfields are empty
        if  ((email?.isEmpty)! && (password?.isEmpty)!) {
            let title = "Error"
            let message = "Both email and password are required."
            AlertFunc.ShowAlert(title: title, message: message, in: self)

        } else {
        
        // send request to sql db
        let url = NSURL(string : "http://demo.staffspacesolutions.com/mobile/login.php")!;
    
        // request url
        //let request = NSMutableURLRequest(url: url as URL);
        var request = URLRequest(url: url as URL)
        
        // method to pass data POST
        request.httpMethod = "POST";
        
        // append url
        let postString = "email=\(emailTextField.text!)&password=\(passwordTextField.text!)"
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print(error!)
                return
            }
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            if error == nil {
                // parse the result as JSON, since that's what the API provides
                do {
                    guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? NSDictionary else {
                            print("error trying to convert data to JSON")
                            return
                    }
                   
                   
                    guard (json["email"] as? String) != nil else {
                        print("Error while parsing")
                        DispatchQueue.main.async {
                            let title = "Error"
                            let message = "Email and/or password are incorrect."
                            AlertFunc.ShowAlert(title: title, message: message, in: self)
                        }
                        return
                    }
            
                    let id = json["id"] as? String
                
                    if id != nil {
                        
                        let email = (json["email"] as! String)
                        let fName = (json["firstName"] as! String)
                        let lName = (json["lastName"] as! String)
                        let empNum = (json["empNum"] as! String)
                        let mobileNum = (json["mobileNum"] as! String)
                        
                        // Stores info locally
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set(fName, forKey: "firstName")
                        UserDefaults.standard.set(lName, forKey: "lastName")
                        UserDefaults.standard.set(empNum, forKey: "empNum")
                        UserDefaults.standard.set(mobileNum, forKey: "mobileNum")
                        
                        UserDefaults.standard.set(json, forKey: "json")
                        user = UserDefaults.standard.value(forKey: "json") as? NSDictionary
                        DispatchQueue.main.async {
                            self.indicator.startIndicator(view: self.view, targetVC: self)
                            appDelegate.login();
                        }
                        
                    } else {
                     
                        let title = "Error"
                        let message = "Email or/and password are incorrect."
                        AlertFunc.ShowAlert(title: title, message: message, in: self)

                    }
                
                } catch  {
                    print("error trying to convert data to JSON")
                    return
                }
            } else {
                print("Problem connecting with server.")
            }
       }
        task.resume();
    }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     self.view.endEditing(true)
        return false
    }

    
}
