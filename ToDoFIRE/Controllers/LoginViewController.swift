//
//  ViewController.swift
//  ToDoFIRE
//
//  Created by Yury Radetsky on 15.03.2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let segueIdentifier = "tasksSegue"
    
    var ref: DatabaseReference! = nil

    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        // для того, чтобы клавиатура не перекрывала контент (в сториборд view меняем на Scroll View
        // когда клавиатура поднимается
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        // когда клавиатура опускается
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        warnLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
         
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + keyboardFrameSize.height)
        
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrameSize.height, right: 0)
    }
    
    @objc func keyboardDidHide() {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        
        UIView.animateKeyframes(withDuration: 3, delay: 0, options: .beginFromCurrentState) { [weak self] in
            self?.warnLabel.alpha = 1
        } completion: { [weak self] (complete) in
            self?.warnLabel.alpha = 0
        }

    }

    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Error ocured")
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
            
        }
        
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in

            guard error == nil, user != nil else {
                
                print(error?.localizedDescription)
                return
            }
            
            let userRef = self.ref.child((user?.user.uid)!)
            userRef.setValue(["email": user?.user.email])
            
        }
    }
    

}

