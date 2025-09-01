//
//  addProjectForm.swift
//  Candor
//
//  Created by mac on 04/08/25.
//

import UIKit

protocol DataReload: AnyObject {
    func dataReloading()
}
class addProjectForm: UIViewController {

    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var popupContainerView: UIView!
    @IBOutlet weak var addTaskButtonOutlet: UIButton!
    @IBOutlet weak var endDatePickerOutlet: UIDatePicker!
    @IBOutlet weak var startDatePickerOutlet: UIDatePicker!
    @IBOutlet weak var projectTFOutlet: UITextField!
    
    let viewModel = addProjectVM()
    var reloadDelegate: DataReload?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
        customUiElement()
    }
    
    func customUiElement(){
        popupContainerView.layer.cornerRadius = 12
        popupContainerView.clipsToBounds = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        preferredContentSize = CGSize(width: 250, height: 200)
                
        startDatePickerOutlet.minimumDate = Date()
        startDatePickerOutlet.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
    }
    
    @objc func startDateChanged() {
        let selectedStartDate = startDatePickerOutlet.date
        endDatePickerOutlet.minimumDate = selectedStartDate

        if endDatePickerOutlet.date < selectedStartDate {
            endDatePickerOutlet.setDate(selectedStartDate, animated: true)
        }
    }

    private func setupCallbacks() {
        viewModel.onProjectAdded = { [weak self] message in
            DispatchQueue.main.async {
                self?.dismiss(animated: true) {
                    self?.reloadDelegate?.dataReloading()
                }
            }
        }
        
        viewModel.onError = { error in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTaskButton(_ sender: UIButton) {
        guard let name = projectTFOutlet.text, !name.isEmpty else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let start = formatter.string(from: startDatePickerOutlet.date)
        let end = formatter.string(from: endDatePickerOutlet.date)
        
        viewModel.addNewProject(name: name, startDate: start, deadline: end)
    }
    
}
