//
//  taskTableViewCell.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
    func taskUpdated()
}

class taskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var assignedToPullDownButtonOutlet: UIButton!
    @IBOutlet weak var taskUrgencyPullDownButtonOutlet: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    
    var taskId: Int = 0
    private var selectedPriority: String?
    private var selectedAssigneeId: Int?
    private var selectedStatusId: Int?
    
    var availableMembers: [ProjectMember] = []
    var availableSections: [TaskSection] = []
    
    private let membersViewModel = MembersVM()
    private let updateTaskViewModel = UpdateTaskVM()
    
    weak var delegate: TaskCellDelegate?
    
    private let priorityOptions = ["Non Urgent", "Important", "Urgent"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        setupAssigneeMenu()
        setupPriorityMenu()
        setUpBindings()
    }
    private func setUpBindings(){
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
            }
        }
        
        // Bind Update Task ViewModel callbacks
        updateTaskViewModel.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                print("✅ Task updated successfully: \(message)")
                self?.delegate?.taskUpdated() // Notify parent to refresh
            }
        }
        
        updateTaskViewModel.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                print("❌ Failed to update task: \(error)")
                // Optionally show an alert or revert the UI changes
                self?.showErrorAlert(message: error)
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI() {
        // Style the buttons and labels
        taskNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dueDateLabel.font = UIFont.systemFont(ofSize: 10)
        dueDateLabel.textColor = .black
        
        // Setup pull-down buttons styling
        assignedToPullDownButtonOutlet.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        assignedToPullDownButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        assignedToPullDownButtonOutlet.titleLabel?.minimumScaleFactor = 0.5
        assignedToPullDownButtonOutlet.titleLabel?.lineBreakMode = .byTruncatingTail
        assignedToPullDownButtonOutlet.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        
        taskUrgencyPullDownButtonOutlet.layer.cornerRadius = 8
        taskUrgencyPullDownButtonOutlet.layer.borderWidth = 1
        taskUrgencyPullDownButtonOutlet.layer.borderColor = UIColor.systemGray4.cgColor
        
        innerView.layer.cornerRadius = 8
        innerView.clipsToBounds = true
        innerView.layer.borderColor = UIColor.black.cgColor
        innerView.layer.borderWidth = 2
    }
    
    /// due date
    func configure(with tasks: ProjectTask,projectId: Int){
        
        taskId = tasks.id
        // Task name
        taskNameLabel.text = tasks.title
        
        if let formattedDueDate = formatDate(from: tasks.due_date) {
            dueDateLabel.text = "Due: \(formattedDueDate)"
        } else if let formattedCreatedDate = formatDate(from: tasks.created_at) {
            dueDateLabel.text = "Created: \(formattedCreatedDate)"
        } else {
            dueDateLabel.text = "Date not available"
        }
        
    
        // Priority
        if let priority = tasks.priority, !priority.isEmpty {
            taskUrgencyPullDownButtonOutlet.setTitle(priority, for: .normal)
            selectedPriority = priority
        } else {
            taskUrgencyPullDownButtonOutlet.setTitle("No Priority", for: .normal)
            selectedPriority = nil
        }

        
        // Assignee
        if let assignee = tasks.assignee {
            let fullName = "\(assignee.first_name) \(assignee.last_name)"
            assignedToPullDownButtonOutlet.setTitle(fullName, for: .normal)
            selectedAssigneeId = assignee.id  // Store current assignee ID
        } else {
            assignedToPullDownButtonOutlet.setTitle("All", for: .normal)
            selectedAssigneeId = nil
        }
        selectedStatusId = tasks.task_status.id
        if availableMembers.isEmpty {
            membersViewModel.getProjectMembers(projectId: projectId)
        }
        setupAssigneeMenu()
        setupPriorityMenu()
        print("🔧 Configured cell with taskId: \(taskId)")
    }
    
    private func formatDate(from dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Detect if the date has milliseconds or not
        if dateString.contains(".") {
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        } else {
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd" // Output format
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    private func setupPriorityMenu() {
        let actions = priorityOptions.map { option in
            UIAction(title: option, state: option == selectedPriority ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                
                // Update UI immediately
                self.selectedPriority = option
                self.taskUrgencyPullDownButtonOutlet.setTitle(option, for: .normal)
                print("📌 Selected priority: \(option)")
                
                // Update task in backend
                self.updateTaskInBackend()
                
                // Refresh menu
                self.setupPriorityMenu()
            }
        }
        
        let menu = UIMenu(title: "Select Priority", options: .singleSelection, children: actions)
        taskUrgencyPullDownButtonOutlet.menu = menu
        taskUrgencyPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    private func setupAssigneeMenu() {
        var actions: [UIAction] = []
        
        // Add "Unassigned" option
        let unassignedAction = UIAction(title: "All", state: selectedAssigneeId == nil ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            
            // Update UI immediately
            self.selectedAssigneeId = nil
            self.assignedToPullDownButtonOutlet.setTitle("All", for: .normal)
            print("👤 Selected assignee: Unassigned")
            
            // Update task in backend
            self.updateTaskInBackend()
            
            // Refresh menu
            self.setupAssigneeMenu()
        }
        actions.append(unassignedAction)
        
        // Add members from API
        for member in availableMembers {
            let memberName = "\(member.user.firstName) \(member.user.lastName)"
            let isSelected = selectedAssigneeId == member.user.id
            let action = UIAction(title: memberName, state: isSelected ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                
                // Update UI immediately
                self.selectedAssigneeId = member.user.id
                self.assignedToPullDownButtonOutlet.setTitle(memberName, for: .normal)
                print("👤 Selected assignee: \(memberName) (ID: \(member.user.id))")
                
                // Update task in backend
                self.updateTaskInBackend()
                
                // Refresh menu
                self.setupAssigneeMenu()
            }
            actions.append(action)
        }
        
        // Build menu
        let menu = UIMenu(title: "Select Assignee", options: .singleSelection, children: actions)
        assignedToPullDownButtonOutlet.menu = menu
        assignedToPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    private func updateTaskInBackend() {
        guard taskId > 0 else {
            print("❌ Invalid task ID")
            return
        }
        
        print("🔄 Updating task \(taskId) - Assignee: \(selectedAssigneeId ?? -1), Priority: \(selectedPriority ?? "nil"), Status: \(selectedStatusId ?? -1)")
        
        updateTaskViewModel.updateTask(
            taskId: taskId,
            assignedTo: selectedAssigneeId,
            priority: selectedPriority,
            statusId: selectedStatusId
        )
    }
    private func showErrorAlert(message: String) {
        guard let parentVC = self.parentViewController else { return }
        
        let alert = UIAlertController(title: "Update Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        parentVC.present(alert, animated: true)
    }
    
}

extension UIView {
    var parentVC: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
