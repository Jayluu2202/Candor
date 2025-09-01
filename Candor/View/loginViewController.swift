//
//  ViewController.swift
//  Candor
//
//  Created by mac on 24/07/25.
//

import UIKit

class loginViewController: UIViewController {

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var forgotPasswordOutlet: UIButton!
    
    var eyeClosed = true
    let viewModel = UserLoginFile()
    let test = dashboardTab()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailTextFieldEdits()
        passwordTextFieldEdits()
        loginSuccessAndFailureLogic()
        
    }
    
    func loginSuccessAndFailureLogic(){
        viewModel.onLoginSuccess = { userData in
            DispatchQueue.main.async {
                print("Login success: \(userData.user_type)")
                print("Role: \(userData.role?.name ?? "")")
                
                                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let nextVC = storyboard.instantiateViewController(withIdentifier: "tabViewController") as? tabViewController {
                                        
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
        viewModel.onLoginFailure = { errorMessage in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Login Failed", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func eyeButton(_ sender: UIButton) {
        passwordTF.isSecureTextEntry.toggle()
        eyeClosed = !eyeClosed
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        guard let email = emailTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty else {
                  showAlert("Please enter email and password.")
                  return
              }

        viewModel.login(email: email, password: password)
    }
    
    @IBAction func forgotButton(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "forgotPasswordViewController") as! forgotPasswordViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Input Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func emailTextFieldEdits(){
        emailTF.placeholder = "Email"
        emailTF.text = "vaghanidhara49@gmail.com"
    }
    
    func passwordTextFieldEdits(){
        passwordTF.placeholder = "Password"
        passwordTF.text = "WebSite@123!"
    }
}
