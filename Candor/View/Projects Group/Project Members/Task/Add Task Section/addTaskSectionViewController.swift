//
//  addTaskSectionViewController.swift
//  Candor
//
//  Created by mac on 27/08/25.
//

import UIKit

class addTaskSectionViewController: UIViewController {
    
    @IBOutlet weak var addSectionButtonOutlet: UIButton!
    @IBOutlet weak var sectionTitleTextField: UITextField!
    
    private let sectionVM = AddTaskStatusSectionVM()
    var projectId: Int = 71
    var onSectionAdded: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        addSectionButtonOutlet.layer.cornerRadius = 10
        addSectionButtonOutlet.clipsToBounds = true
    }
    
    private func bindViewModel() {
        sectionVM.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    print("⏳ Adding section...")
                    self?.addSectionButtonOutlet.isEnabled = false
                } else {
                    self?.addSectionButtonOutlet.isEnabled = true
                }
            }
        }
        
        sectionVM.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message)
                self?.dismiss(animated: true) {
                    self?.onSectionAdded?() // refresh sections in parent
                }
            }
        }
        
        sectionVM.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
    }
    @IBAction func clossButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func addSectionButton(_ sender: UIButton) {
        guard let title = sectionTitleTextField.text, !title.isEmpty else {
            showAlert(title: "Error", message: "Please enter section title")
            return
        }
        sectionVM.addTaskStatus(projectId: projectId, title: title)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
