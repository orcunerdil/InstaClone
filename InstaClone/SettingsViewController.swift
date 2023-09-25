//
//  SettingsViewController.swift
//  InstaClone
//
//  Created by Orçun Erdil on 18.05.2023.
//

import UIKit
import Firebase


class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        view.addGestureRecognizer(gestureKeyboard)
        
    }
    
    
    
    @IBAction func logoutClicked(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toViewController", sender: nil)
        } catch  {
            print("error")
        }
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)

    }
  

}
