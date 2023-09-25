//
//  ViewController.swift
//  InstaClone
//
//  Created by Orçun Erdil on 18.05.2023.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        view.addGestureRecognizer(gestureKeyboard)


    }

    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func SignInClicked(_ sender: Any) {
        
        if usernameTxt.text != "" && passwordTxt.text != "" {
            
            Auth.auth().signIn(withEmail: usernameTxt.text!, password: passwordTxt.text!) { (authdata, error) in
                if error != nil {
                    self.makeAlert(title: "Error! ", message: error?.localizedDescription ?? "Error")
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
            
        } else {
            makeAlert(title: "Error", message: "Username or password can't be empty.")
        }
        
        
    }
    
    @IBAction func SignUpClicked(_ sender: Any) {

        
        if usernameTxt.text != "" && passwordTxt.text != "" {
            
            Auth.auth().createUser(withEmail: usernameTxt.text!, password: passwordTxt.text!) { (authdata, error) in
                if error != nil {
                    self.makeAlert(title: "Error! ", message: error?.localizedDescription ?? "Error")
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
            
        }else {
           makeAlert(title: "Error", message: "Username or password can't be empty.")
        }
    }
    
    func makeAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okBtn)
        self.present(alert,animated: true)
    }
}

