//
//  forgotPasswordViewController.swift
//  Candor
//
//  Created by mac on 12/08/25.
//

import UIKit

class forgotPasswordViewController: UIViewController {

    @IBOutlet weak var changePasswordOutlet: UIButton!
    @IBOutlet weak var newPasswordIDTextField: UITextField!
    @IBOutlet weak var employeeIDTextField: UITextField!
    
    var viewModel = UserForgetPassword()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changePasswordOutlet.layer.cornerRadius = 10
        viewModel.onPasswordUpdateSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message){
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        viewModel.onPasswordUpdateFailure = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: errorMessage)
            }
        }
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        
        guard let newPassword = newPasswordIDTextField.text, !newPassword.isEmpty else {
            showAlert(title: "Missing Information", message: "New Password is missing")
            return
        }
        
        if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
            viewModel.updatePassword(userId: String(userId), newPassword: newPassword)
        } else {
            showAlert(title: "Error", message: "User not logged in")
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(title : String ,message: String, completion : (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){ _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
