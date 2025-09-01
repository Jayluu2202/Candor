//
//  editUserViewController.swift
//  Candor
//
//  Created by mac on 12/08/25.
//

import UIKit

class editUserViewController: UIViewController {
    
    @IBOutlet weak var updatePasswordOutlet: UIButton!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var userEmailIDTextField: UITextField!
    @IBOutlet weak var userEMPID: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var nameInitialLabel: UILabel!
    
    let viewModelUser = LoggedInUserVM()
    let passwordViewModel = EmployeePasswordVM()
    var currentUserData: LoggedInUserData?
    var selectedImageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        fetchUserProfile()
    }
    
    func setupUI() {
        updatePasswordOutlet.layer.cornerRadius = 10
        
        // Make profile image tappable
        userProfileImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        userProfileImage.addGestureRecognizer(tapGesture)
        userProfileImage.layer.cornerRadius = userProfileImage.frame.width / 2
        userProfileImage.clipsToBounds = true
    }
    
    func setupBindings() {
        // User profile fetch bindings
        viewModelUser.onProfileFetchSuccess = { [weak self] userData in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentUserData = userData
                self.displayUserData(userData)
            }
        }
        
        viewModelUser.onProfileFetchFailure = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: errorMessage)
            }
        }
        
        // Password update bindings
        passwordViewModel.onPasswordUpdateSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        passwordViewModel.onPasswordUpdateFailure = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: errorMessage)
            }
        }
    }
    
    func fetchUserProfile() {
        viewModelUser.fetchUserProfile()
    }
    
    @objc func profileImageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func updatePasswordButton(_ sender: UIButton) {
        guard validatePasswordFields() else { return }
        
        guard let currentPassword = currentPasswordTextField.text,
              let newPassword = newPasswordTextField.text else {
                  showAlert(title: "Error", message: "Please fill all password fields")
                  return
              }
        
        passwordViewModel.updatePasswordWithCurrent(
            currentPassword: currentPassword,
            newPassword: newPassword,
            profileImage: selectedImageData
        )
    }
    
    func validatePasswordFields() -> Bool {
        
        guard let currentPassword = currentPasswordTextField.text, !currentPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter current password")
            return false
        }
        
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter new password")
            return false
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please confirm new password")
            return false
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Error", message: "New password and confirm password don't match")
            return false
        }
        
        guard newPassword.count >= 6 else {
            showAlert(title: "Error", message: "New password must be at least 6 characters long")
            return false
        }
        
        return true
    }
    
    func displayUserData(_ userData: LoggedInUserData){
        let fullName = "\(userData.first_name) \(userData.last_name)"
        userNameTextField.text = fullName
        userEmailIDTextField.text = userData.email
        userEMPID.text = "\(userData.id)"
        
        // Set name initials
        let firstInitial = userData.first_name.first?.uppercased() ?? ""
        let lastInitial = userData.last_name.first?.uppercased() ?? ""
        nameInitialLabel.text = "\(firstInitial)\(lastInitial)"
        
        // Load profile image if available
        if let profileImageURL = userData.profile_image, !profileImageURL.isEmpty {
            loadProfileImage(from: profileImageURL)
        }
    }
    
    func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.userProfileImage.image = UIImage(data: data)
                self?.nameInitialLabel.isHidden = true
            }
        }.resume()
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true, completion: nil)
    }
}

extension editUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            userProfileImage.image = editedImage
            nameInitialLabel.isHidden = true
            // Convert image to data for upload
            selectedImageData = editedImage.jpegData(compressionQuality: 0.7)
        } else if let originalImage = info[.originalImage] as? UIImage {
            userProfileImage.image = originalImage
            nameInitialLabel.isHidden = true
            
            // Convert image to data for upload
            selectedImageData = originalImage.jpegData(compressionQuality: 0.7)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
