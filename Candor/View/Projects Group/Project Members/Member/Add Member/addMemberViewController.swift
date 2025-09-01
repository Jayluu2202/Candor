//
//  addMemberViewController.swift
//  Candor
//
//  Created by mac on 21/08/25.
//

import UIKit

protocol AddMemberDelegate: AnyObject {
    func memberAdded()
}

class addMemberViewController: UIViewController {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var memberSelectPullDownButtonOutlet: UIButton!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    weak var delegate: AddMemberDelegate?
    var projectId: Int = 0
    
    private let membersViewModel = MembersVM()
    private var employees: [EmployeeMember] = []
    private var selectedEmployees: [EmployeeMember] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMembersVM()
        fetchEmployees()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerPopup()
    }
    
    private func centerPopup() {
        let popupWidth: CGFloat = 300
        let popupHeight: CGFloat = 200  // Adjust height for Add Member UI
        
        innerView.frame = CGRect(
            x: (view.bounds.width - popupWidth) / 2,
            y: (view.bounds.height - popupHeight) / 2,
            width: popupWidth,
            height: popupHeight
        )
    }
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        // Style the inner view
        innerView.layer.cornerRadius = 12
        innerView.layer.shadowColor = UIColor.black.cgColor
        innerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        innerView.layer.shadowRadius = 8
        innerView.layer.shadowOpacity = 0.2
        
        // Style close button
        closeButtonOutlet.layer.cornerRadius = 8
        
        // Style add button
        if let addButton = addButtonOutlet {
            addButton.layer.cornerRadius = 8
            addButton.backgroundColor = UIColor.systemBlue
            addButton.setTitleColor(.white, for: .normal)
            addButton.isEnabled = false
            addButton.alpha = 0.5
        }
        
        // Initial setup for pulldown button
        setupPulldownButton()
    }
    
    private func setupPulldownButton() {
        memberSelectPullDownButtonOutlet.setTitle("Select Members", for: .normal)
        memberSelectPullDownButtonOutlet.layer.cornerRadius = 8
        memberSelectPullDownButtonOutlet.layer.borderWidth = 1
        memberSelectPullDownButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
        memberSelectPullDownButtonOutlet.backgroundColor = UIColor.systemBackground
        memberSelectPullDownButtonOutlet.setTitleColor(.systemBlue, for: .normal)
        
        memberSelectPullDownButtonOutlet.showsMenuAsPrimaryAction = true
        
        // Initially set an empty menu
        let emptyMenu = UIMenu(title: "Loading...", children: [])
        memberSelectPullDownButtonOutlet.menu = emptyMenu
    }
    
    private func setupMembersVM() {
        membersViewModel.onEmployeesFetched = { [weak self] employees in
            DispatchQueue.main.async {
                self?.employees = employees
                self?.setupEmployeeDropdown()
            }
        }
        
        membersViewModel.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.delegate?.memberAdded()
                self?.dismiss(animated: true)
            }
        }
        
        membersViewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
    }
    
    private func fetchEmployees() {
        membersViewModel.getEmployeeList(projectId: projectId)
    }
    
    private func setupEmployeeDropdown() {
        guard !employees.isEmpty else {
            // Handle empty employee list
            let emptyAction = UIAction(title: "No employees available", attributes: [.disabled]) { _ in }
            let menu = UIMenu(title: "Select Employees", children: [emptyAction])
            memberSelectPullDownButtonOutlet.menu = menu
            return
        }
        
        var actions: [UIAction] = []
        
        for (index, employee) in employees.enumerated() {
            let displayName = getDisplayName(for: employee)
            print("Employee \(index): \(displayName)")
            
            let isSelected = selectedEmployees.contains { $0.id == employee.id }
            
            let action = UIAction(
                title: displayName,
                state: isSelected ? .on : .off
            ) { [weak self] _ in
                print("Selected employee: \(displayName)")
                self?.toggleEmployeeSelection(employee)
            }
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Select Employees", children: actions)
        memberSelectPullDownButtonOutlet.menu = menu
    }
    
    private func getDisplayName(for employee: EmployeeMember) -> String {
        // Handle different ways the name might be stored
        if let name = employee.name, !name.isEmpty {
            return name
        } else if !employee.firstName.isEmpty && !employee.lastName.isEmpty {
            let fullName = "\(employee.firstName) \(employee.lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
            return fullName.isEmpty ? "Unknown Employee" : fullName
        } else if !employee.firstName.isEmpty {
            return employee.firstName
        } else if !employee.lastName.isEmpty {
            return employee.lastName
        } else {
            return "Employee #\(employee.id)"
        }
    }
    
    private func toggleEmployeeSelection(_ employee: EmployeeMember) {
        if let index = selectedEmployees.firstIndex(where: { $0.id == employee.id }) {
            // Remove if already selected
            selectedEmployees.remove(at: index)
        } else {
            // Add if not selected
            selectedEmployees.append(employee)
        }
        
        updateUI()
    }
    
    private func updateUI() {
        // Update button title based on selection
        if selectedEmployees.isEmpty {
            memberSelectPullDownButtonOutlet.setTitle("Select Members", for: .normal)
            addButtonOutlet?.isEnabled = false
            addButtonOutlet?.alpha = 0.5
        } else if selectedEmployees.count == 1 {
            let employee = selectedEmployees.first!
            let displayName = employee.name ?? "\(employee.firstName) \(employee.lastName)"
            memberSelectPullDownButtonOutlet.setTitle(displayName, for: .normal)
            addButtonOutlet?.isEnabled = true
            addButtonOutlet?.alpha = 1.0
        } else {
            memberSelectPullDownButtonOutlet.setTitle("\(selectedEmployees.count) Members Selected", for: .normal)
            addButtonOutlet?.isEnabled = true
            addButtonOutlet?.alpha = 1.0
        }
        
        // Update menu to show selected state
        setupEmployeeDropdown()
    }
        
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func memberSelectPullDownButton(_ sender: Any) {
        print("Pull down button tapped")
    }
    
    @IBAction func addButton(_ sender: UIButton){
        guard !selectedEmployees.isEmpty else {
            print("No employees selected")
            return
        }
        
        let userIds = selectedEmployees.map { $0.id }
        print("Adding members with IDs: \(userIds)")
        membersViewModel.addProjectMember(projectId: projectId, userIds: userIds)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

// MARK: - Debug Extension
extension addMemberViewController {
    private func debugEmployeeData() {
        print("=== DEBUG: Employee Data ===")
        print("Total employees: \(employees.count)")
        for (index, employee) in employees.enumerated() {
            print("Employee \(index):")
            print("  ID: \(employee.id)")
            print("  Name: \(employee.name ?? "nil")")
            print("  First Name: \(employee.firstName ?? "nil")")
            print("  Last Name: \(employee.lastName ?? "nil")")
            print("  Display Name: \(getDisplayName(for: employee))")
        }
        print("===========================")
    }
}
