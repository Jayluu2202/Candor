//
//  addTaskViewController.swift
//  Candor
//
//  Created by mac on 25/08/25.
//

import UIKit

protocol AddTaskDelegate: AnyObject {
    func taskAdded()
}

class addTaskViewController: UIViewController {
    
    @IBOutlet weak var priorityPullDownButtonOutlet: UIButton!
    @IBOutlet weak var assignedToPullDownButtonOutlet: UIButton!
    @IBOutlet weak var addTaskButtonOutlet: UIButton!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var taskDatePickerOutlet: UIDatePicker!
    @IBOutlet weak var addTaskTextFieldOutlet: UITextField!
    
    private let addTaskViewModel = AddTaskVM()
    var projectId: Int = 71 // ✅ This will be set from previous VC
    weak var delegate: AddTaskDelegate?
    
    private var selectedPriority: String?
    private var selectedAssigneeId: Int?
    private var selectedStatusId: Int? // Add this for section selection
    var availableMembers: [ProjectMember] = []
    var availableSections: [TaskSection] = [] // Add this to pass sections
    
    private let membersViewModel = MembersVM()
    
    private let priorityOptions = ["Non Urgent", "Important", "Urgent"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedPriority = "Non Urgent" // Default priority
        priorityPullDownButtonOutlet.setTitle("Non Urgent", for: .normal)
        
        setupPriorityMenu()
        assignedToPullDownButtonOutlet.setTitle("Select Assignee", for: .normal)
        setupAssigneeMenu()
        // Set default section if available
        if let firstSection = availableSections.first {
            selectedStatusId = firstSection.id
        }
        
        
        setUpBindings()
        setupUI()
        if availableMembers.isEmpty {
            fetchProjectMembers()
        }
    }
    
    private func setUpBindings(){
        // Bind ViewModel callbacks
        addTaskViewModel.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message, completion: nil)
                self?.delegate?.taskAdded() // ✅ Notify previous VC
                self?.dismiss(animated: true)
            }
        }
        
        addTaskViewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error, completion: nil)
            }
        }
        
        addTaskViewModel.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.addTaskButtonOutlet.isEnabled = !isLoading
                self?.addTaskButtonOutlet.alpha = isLoading ? 0.6 : 1.0
            }
        }
        // Bind Members ViewModel callbacks
        membersViewModel.onProjectMembersFetched = { [weak self] members in
            DispatchQueue.main.async {
                self?.availableMembers = members
                print("📋 Fetched \(members.count) members for assignment")
                self?.setupAssigneeMenu()
            }
        }
        
        membersViewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                print("❌ Error fetching members: \(error)")
                // Don't show error alert for members, just log it
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        innerView.layer.cornerRadius = 15
        innerView.layer.shadowColor = UIColor.black.cgColor
        innerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        innerView.layer.shadowOpacity = 0.25
        innerView.layer.shadowRadius = 8        
    }
    
    private func fetchProjectMembers() {
        print("🔍 Fetching project members for project: \(projectId)")
        membersViewModel.getProjectMembers(projectId: projectId)
    }
    
    private func setupPriorityMenu() {
        let actions = priorityOptions.map { option in
            UIAction(title: option, state: option == selectedPriority ? .on : .off) { [weak self] _ in
                self?.selectedPriority = option
                self?.priorityPullDownButtonOutlet.setTitle(option, for: .normal)
                print("📌 Selected priority: \(option)")
                self?.setupPriorityMenu()
            }
        }
        
        let menu = UIMenu(title: "Select Priority", options: .singleSelection, children: actions)
        priorityPullDownButtonOutlet.menu = menu
        priorityPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }

    
    private func setupAssigneeMenu() {
        var actions: [UIAction] = []
        
        // Add "Unassigned" option
        let unassignedAction = UIAction(title: "All", state: selectedAssigneeId == nil ? .on : .off) { [weak self] _ in
            self?.selectedAssigneeId = nil
            self?.assignedToPullDownButtonOutlet.setTitle("All", for: .normal)
            print("👤 Selected assignee: Unassigned")
            self?.setupAssigneeMenu() // ✅ Refresh menu state
        }
        actions.append(unassignedAction)
        
        // Add members from API
        for member in availableMembers {
            let memberName = "\(member.user.firstName) \(member.user.lastName)"
            let isSelected = selectedAssigneeId == member.user.id
            let action = UIAction(title: memberName, state: isSelected ? .on : .off) { [weak self] _ in
                self?.selectedAssigneeId = member.user.id
                self?.assignedToPullDownButtonOutlet.setTitle(memberName, for: .normal)
                print("👤 Selected assignee: \(memberName) (ID: \(member.user.id))")
                self?.setupAssigneeMenu() // ✅ Refresh menu state
            }
            actions.append(action)
        }
        
        // Build menu
        let menu = UIMenu(title: "Select Assignee", options: .singleSelection, children: actions)
        assignedToPullDownButtonOutlet.menu = menu
        assignedToPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }

    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addTaskButton(_ sender: Any) {
        guard let title = addTaskTextFieldOutlet.text, !title.isEmpty else {
            showAlert(title: "Validation", message: "Please enter task title", completion: nil)
            return
        }
        
        // Format selected date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dueDateString = formatter.string(from: taskDatePickerOutlet.date)
        
        // Use default section if no specific section selected
        let statusId = selectedStatusId ?? availableSections.first?.id
        
        // Create request - fixed to use dynamic projectId
        let request = AddTaskRequest(
            title: title,
            projectId: self.projectId, // Use the dynamic projectId instead of hardcoded 71
            assignedTo: selectedAssigneeId,
            dueDate: dueDateString,
            description: nil, // Make it optional
            isCompleted: false,
            priority: selectedPriority,
            statusId: statusId
        )
        
        print("📤 Creating task with request: \(request)")
        addTaskViewModel.createTask(request: request)
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
