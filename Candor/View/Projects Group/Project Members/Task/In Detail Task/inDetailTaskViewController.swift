//
//  inDetailTaskViewController.swift
//  Candor
//
//  Created by mac on 28/08/25.
//

import UIKit

class inDetailTaskViewController: UIViewController {
    
    @IBOutlet weak var makeChangesButtonOutlet: UIButton!
    @IBOutlet weak var uploadDocumentButtonOutlet: UIButton!
    @IBOutlet weak var commentsAndActivityTextField: UITextField!
    @IBOutlet weak var commentsAndActivityCollectionView: UICollectionView!
    @IBOutlet weak var commentsAndActivitySegment: UISegmentedControl!
    @IBOutlet weak var subTaskButtonOutlet: UIButton!
    @IBOutlet weak var subTasksCollectionView: UICollectionView!
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var collectionViewOfTags: UICollectionView!
    @IBOutlet weak var assigneePullDownButton: UIButton!
    @IBOutlet weak var statusPullDownButton: UIButton!
    @IBOutlet weak var priorityPullDownButton: UIButton!
    @IBOutlet weak var dueDatePickerButtonOutlet: UIButton!
    @IBOutlet weak var dueDateLabelOutlet: UILabel!
    @IBOutlet weak var taskNameLabelOutlet: UILabel!
    @IBOutlet weak var editTaskButtonOutlet: UIButton!
    
    var taskId: Int = 0
    private var tags: [String] = []
    private var subTasks: [InnerSubTaskData] = []
    private var taskData: InnerTaskData?
    private var availableMembers: [InnerAssignedUser] = []
    private var availableStatuses: [InnerTaskStatus] = []
    
    // ViewModels
    private let taskDetailVM = GetInnerTaskDetailsVM()
    private let updateTaskVM = UpdateInnerTaskDetailsVM()
    private let membersVM = MembersVM()
    private let addSubTaskVM = AddSubTasksVM()
    private let updateSubTaskVM = UpdateSubTasksVM()
    
    // Current selections
    private var selectedAssigneeId: Int?
    private var selectedStatusId: Int?
    private var selectedPriority: String = ""
    private var selectedDueDate: String = ""
    private var isEditingTaskName = false
    
    // Track data loading
    private var isTaskDataLoaded = false
    private var isMembersDataLoaded = false
    
    // Comments and Activity data
    private var comments: [GetComment] = []
    private var activitySections: [ActivitySection] = []
    private var selectedSegmentIndex = 0
    private var selectedFiles: [URL] = []
    
    // ViewModels for comments and activity
    private let getCommentsVM = GetCommentsVM()
    private let addCommentsVM = AddCommentsVM()
    private let deleteCommentsVM = DeleteCommentsVM()
    private let taskActivityVM = TaskActivityViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        setupViewModels()
        setupUI()
        subTaskButtonOutlet.isHidden = true
        if taskId > 0 {
            fetchTaskDetails()
        }
    }
    
    // MARK: - Setup Methods
    private func setupCollectionViews() {
        // Setup tags collection view
        collectionViewOfTags.delegate = self
        collectionViewOfTags.dataSource = self
        
        let tagsNib = UINib(nibName: "tagsCollectionViewCell", bundle: nil)
        collectionViewOfTags.register(tagsNib, forCellWithReuseIdentifier: "tagsCollectionViewCell")
        
        // Configure tags layout for horizontal flow
        if let tagsLayout = collectionViewOfTags.collectionViewLayout as? UICollectionViewFlowLayout {
            tagsLayout.scrollDirection = .horizontal
            tagsLayout.minimumLineSpacing = 8
            tagsLayout.minimumInteritemSpacing = 8
            tagsLayout.estimatedItemSize = CGSize(width: 80, height: 40)
        }
        
        // Setup subtasks collection view
        subTasksCollectionView.delegate = self
        subTasksCollectionView.dataSource = self
        
        let subTasksNib = UINib(nibName: "subTasksCollectionViewCell", bundle: nil)
        subTasksCollectionView.register(subTasksNib, forCellWithReuseIdentifier: "subTasksCollectionViewCell")
        
        // Configure layout for vertical subtasks
        if let layout = subTasksCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 0
        }
        
        // FIXED: Add missing delegate and dataSource setup for comments collection view
        commentsAndActivityCollectionView.delegate = self
        commentsAndActivityCollectionView.dataSource = self
        
        let commentsNib = UINib(nibName: "commentsAndActivityCollectionViewCell", bundle: nil)
        commentsAndActivityCollectionView.register(commentsNib, forCellWithReuseIdentifier: "commentsAndActivityCollectionViewCell")
        
        // ADDED: Configure layout for comments collection view
        if let commentsLayout = commentsAndActivityCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            commentsLayout.scrollDirection = .vertical
            commentsLayout.minimumLineSpacing = 8
            commentsLayout.minimumInteritemSpacing = 0
            commentsLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    private func setupViewModels() {
        // Setup task detail VM
        taskDetailVM.onSuccessWithDetails = { [weak self] taskData, availableMembers, availableStatuses in
            DispatchQueue.main.async {
                self?.taskData = taskData
                self?.availableMembers = availableMembers
                self?.availableStatuses = availableStatuses
                self?.isTaskDataLoaded = true
                self?.isMembersDataLoaded = true
                self?.populateAllData()
            }
        }
        
        taskDetailVM.onSuccess = { [weak self] taskData in
            DispatchQueue.main.async {
                self?.taskData = taskData
                self?.isTaskDataLoaded = true
                let projectId = taskData.project.id
                self?.fetchProjectMembers(projectId: projectId)
                self?.populateBasicData()
            }
        }
        
        taskDetailVM.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        
        // Setup members VM
        membersVM.onProjectMembersFetched = { [weak self] projectMembers in
            DispatchQueue.main.async {
                self?.availableMembers = projectMembers.map { member in
                    InnerAssignedUser(
                        profileImage: member.user.profileImage,
                        id: member.user.id,
                        firstName: member.user.firstName,
                        lastName: member.user.lastName,
                        name: member.user.name,
                        userType: member.user.userType
                    )
                }
                self?.isMembersDataLoaded = true
                self?.populateAllData()
            }
        }
        
        membersVM.onError = { [weak self] error in
            DispatchQueue.main.async {
                print("Error fetching project members: \(error)")
                self?.isMembersDataLoaded = true
                self?.populateAllData()
            }
        }
        
        // Setup update task VM
        updateTaskVM.onSuccess = { [weak self] response in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: response.message)
                self?.fetchTaskDetails()
                
            }
        }
        
        updateTaskVM.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        
        // Setup add subtask VM
        addSubTaskVM.onSuccess = { [weak self] response in
            DispatchQueue.main.async {
                if let subTaskData = response.data {
                    // Convert SubTaskData to InnerSubTaskData or modify your API to return InnerSubTaskData
                    // For now, just refetch the task details to get updated data
                    self?.fetchTaskDetails()
                } else {
                    // If API doesn't return the subtask, fetch again
                    self?.fetchTaskDetails()
                }
                self?.showAlert(title: "Success", message: response.message)
            }
        }

        
        addSubTaskVM.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        
        // Setup update subtask VM
        updateSubTaskVM.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message)
                self?.fetchTaskDetails()
            }
        }
        
        updateSubTaskVM.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        
        // FIXED: Setup comments ViewModels with proper UI updates
        getCommentsVM.onCommentsFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.comments = self?.getCommentsVM.comments ?? []
                print("📝 Comments loaded: \(self?.comments.count ?? 0)")
                // Only reload if we're currently showing comments
                if self?.selectedSegmentIndex == 0 {
                    self?.commentsAndActivityCollectionView.reloadData()
                }
            }
        }
        
        getCommentsVM.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        
        deleteCommentsVM.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message)
                // Refresh comments immediately after deletion
                self?.fetchComments()
            }
        }
        
        deleteCommentsVM.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        
        // FIXED: Add success handler for adding comments with immediate UI update
        addCommentsVM.onSuccess = { [weak self] response in
            DispatchQueue.main.async {
                // Clear the text field and selected files first
                self?.commentsAndActivityTextField.text = ""
                self?.selectedFiles.removeAll()
                
                // Show success message
                self?.showAlert(title: "Success", message: response.message)
                
                // Immediately refresh comments to show the new one
                self?.fetchComments()
            }
        }
        
        addCommentsVM.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
    }
    
    private func setupUI() {
        navigationItem.title = "Task Details"
        
        // Setup buttons
        editTaskButtonOutlet.layer.cornerRadius = 8
        makeChangesButtonOutlet.layer.cornerRadius = 8
        
        // Make task name label tappable for editing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editTaskNameTapped))
        taskNameLabelOutlet.addGestureRecognizer(tapGesture)
        taskNameLabelOutlet.isUserInteractionEnabled = true
        
        // Setup text view
        taskDescriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        taskDescriptionTextView.layer.borderWidth = 1
        taskDescriptionTextView.layer.cornerRadius = 8
        
        // Setup segment control
        commentsAndActivitySegment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        commentsAndActivitySegment.selectedSegmentIndex = 0
        
        // Setup text field
        commentsAndActivityTextField.delegate = self
        commentsAndActivityTextField.placeholder = "Add a comment..."
        
        // Setup collection view
        commentsAndActivityCollectionView.delegate = self
        commentsAndActivityCollectionView.dataSource = self
    }
    
    // MARK: - Segment Control
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        if selectedSegmentIndex == 0 {
            fetchComments()
        } else {
            fetchActivity()
        }
        commentsAndActivityCollectionView.reloadData()
    }
    
    // MARK: - Data Fetching for Comments and Activity
    private func fetchComments() {
        getCommentsVM.fetchComments(taskId: taskId)
    }
    
    // MARK: - Updated fetchActivity method
    private func fetchActivity() {
        guard let token = UserDefaults.standard.string(forKey: "token") else { return }
        taskActivityVM.fetchTaskActivity(taskID: taskId, token: token) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.processActivityData()
                    self?.commentsAndActivityCollectionView.reloadData()
                } else if let error = error {
                    self?.showAlert(title: "Error", message: error)
                }
            }
        }
    }
    
    // MARK: - FIXED Activity Data Processing
    private func processActivityData() {
        let activitiesDict = taskActivityVM.activitiesDict
        
        // Sort dates in descending order (newest first)
        let sortedDates = activitiesDict.keys.sorted { date1, date2 in
            return date1 > date2
        }
        
        activitySections = sortedDates.map { date in
            let activities = activitiesDict[date] ?? []
            // Sort activities within each date by time (newest first)
            let sortedActivities = activities.sorted { activity1, activity2 in
                return activity1.createdAt > activity2.createdAt
            }
            return ActivitySection(date: date, activities: sortedActivities)
        }
    }
    
    
    // MARK: - IMPROVED Add Comment Method with debugging
    private func addComment(message: String) {
        // Ensure we have a valid message
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "Error", message: "Please enter a comment")
            return
        }
        
        // Debug: Check if taskId is valid
        guard taskId > 0 else {
            showAlert(title: "Error", message: "Invalid task ID: \(taskId)")
            return
        }
        
        // Debug: Check if token exists
        guard UserDefaults.standard.string(forKey: "token") != nil else {
            showAlert(title: "Error", message: "No authentication token found")
            return
        }
        
        print("🔵 Adding comment for task ID: \(taskId)")
        print("💬 Comment message: \(message)")
        print("📁 Files count: \(selectedFiles.count)")
        
        addCommentsVM.addComment(
            taskId: String(taskId),
            message: message,
            files: selectedFiles,
            mentionUsers: []
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Comment added successfully: \(response.message)")
                    // The success will be handled in the VM success closure
                    break
                case .failure(let error):
                    print("❌ Failed to add comment: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - File Selection
    private func showDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf, .text])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
    // MARK: - Data Fetching
    private func fetchTaskDetails() {
        taskDetailVM.getTask(taskId: taskId)
    }
    
    private func fetchProjectMembers(projectId: Int) {
        membersVM.getProjectMembers(projectId: projectId)
    }
    
    // MARK: - Data Population
    private func populateBasicData() {
        guard let taskData = taskData else { return }
        
        // Set task name
        taskNameLabelOutlet.text = taskData.title
        
        // Set due date
        dueDateLabelOutlet.text = formatDate(taskData.dueDate)
        selectedDueDate = taskData.dueDate
        
        // Set description
        taskDescriptionTextView.text = taskData.description ?? ""
        
        // Set tags
        self.tags = taskData.tags
        collectionViewOfTags.reloadData()
        
        // Initialize subtasks (if available in your API response)
        // For now, keeping as empty array since subtasks aren't in the current model
        self.subTasks = taskData.subTasks
        subTasksCollectionView.reloadData()
        
        // Set current selections
        selectedAssigneeId = taskData.assignedTo
        selectedStatusId = taskData.taskStatus.id
        selectedPriority = taskData.priority
        
        // Setup priority dropdown
        setupPriorityDropdown()
        
        // Set priority button title
        priorityPullDownButton.setTitle(selectedPriority.isEmpty ? "No Priority" : selectedPriority, for: .normal)
        
        // Set status button title
        statusPullDownButton.setTitle(taskData.taskStatus.title, for: .normal)
        
        // Set assignee button title
        if let assignee = taskData.assignee {
            assigneePullDownButton.setTitle("\(assignee.firstName) \(assignee.lastName)", for: .normal)
        } else {
            assigneePullDownButton.setTitle("Unassigned", for: .normal)
        }
    }
    
    private func populateAllData() {
        guard isTaskDataLoaded && isMembersDataLoaded else { return }
        
        populateBasicData()
        setupAssigneeDropdown()
        setupStatusDropdown()
        fetchComments()
    }
    
    // MARK: - Dropdown Setup Methods
    private func setupAssigneeDropdown() {
        var actions: [UIAction] = []
        
        // Add "Unassigned" option
        let unassignedAction = UIAction(
            title: "Unassigned",
            state: selectedAssigneeId == nil ? .on : .off
        ) { [weak self] _ in
            self?.selectedAssigneeId = nil
            self?.assigneePullDownButton.setTitle("Unassigned", for: .normal)
            self?.setupAssigneeDropdown()
        }
        actions.append(unassignedAction)
        
        // Add available members
        for member in availableMembers {
            let memberName = "\(member.firstName) \(member.lastName)"
            let isSelected = selectedAssigneeId == member.id
            
            let action = UIAction(
                title: memberName,
                state: isSelected ? .on : .off
            ) { [weak self] _ in
                self?.selectedAssigneeId = member.id
                self?.assigneePullDownButton.setTitle(memberName, for: .normal)
                self?.setupAssigneeDropdown()
            }
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Assign To", options: .singleSelection, children: actions)
        assigneePullDownButton.menu = menu
        assigneePullDownButton.showsMenuAsPrimaryAction = true
    }
    
    private func setupStatusDropdown() {
        var actions: [UIAction] = []
        
        let statusesToUse: [InnerTaskStatus]
        if !availableStatuses.isEmpty {
            statusesToUse = availableStatuses
        } else if let currentStatus = taskData?.taskStatus {
            statusesToUse = [InnerTaskStatus(id: currentStatus.id, title: currentStatus.title)]
        } else {
            statusesToUse = []
        }
        
        for status in statusesToUse {
            let isSelected = selectedStatusId == status.id
            
            let action = UIAction(
                title: status.title,
                state: isSelected ? .on : .off
            ) { [weak self] _ in
                self?.selectedStatusId = status.id
                self?.statusPullDownButton.setTitle(status.title, for: .normal)
                self?.setupStatusDropdown()
            }
            actions.append(action)
        }
        
        if !actions.isEmpty {
            let menu = UIMenu(title: "Status", options: .singleSelection, children: actions)
            statusPullDownButton.menu = menu
            statusPullDownButton.showsMenuAsPrimaryAction = true
        }
    }
    
    private func setupPriorityDropdown() {
        let priorities = ["Urgent", "Important", "Non Urgent"]
        
        let actions: [UIAction] = priorities.map { priority in
            let isSelected = selectedPriority == priority
            
            return UIAction(
                title: priority,
                state: isSelected ? .on : .off
            ) { [weak self] _ in
                self?.selectedPriority = priority
                self?.priorityPullDownButton.setTitle(priority, for: .normal)
                self?.setupPriorityDropdown()
            }
        }
        
        let menu = UIMenu(title: "Priority", options: .singleSelection, children: actions)
        priorityPullDownButton.menu = menu
        priorityPullDownButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: - Action Methods
    @IBAction func uploadDocumentButton(_ sender: UIButton) {
        showDocumentPicker()
    }
    
    @IBAction func makeChangesButton(_ sender: UIButton) {
        saveTaskChanges()
    }
    
    @IBAction func subTaskButton(_ sender: UIButton) {
        showAddSubTaskAlert()
    }
    
    @IBAction func dueDatePickerButton(_ sender: UIButton) {
        showDatePicker()
    }
    
    @IBAction func editTaskButton(_ sender: UIButton) {
        toggleTaskNameEdit()
    }
    
    @objc private func editTaskNameTapped() {
        toggleTaskNameEdit()
    }
    
    // MARK: - SubTask Methods
    private func showAddSubTaskAlert() {
        let alert = UIAlertController(title: "Add Sub Task", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Sub task title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Description (optional)"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty else { return }
            let description = alert.textFields?[1].text ?? ""
            
            self?.addSubTask(title: title, description: description)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func addSubTask(title: String, description: String) {
        guard let statusId = selectedStatusId else {
            showAlert(title: "Error", message: "Status ID not available")
            return
        }
        
        let request = AddSubTaskRequest(
            title: title,
            taskId: taskId,
            dueDate: selectedDueDate.isEmpty ? "" : selectedDueDate,
            description: description,
            statusId: statusId,
            isCompleted: false
        )
        
        addSubTaskVM.addSubTask(request: request)
    }
    
    private func deleteSubTask(at index: Int) {
        guard index < subTasks.count else { return }
        let subTaskToDelete = subTasks[index]
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Sub Task",
            message: "Are you sure you want to delete '\(subTaskToDelete.title)'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performSubTaskDeletion(subTaskId: subTaskToDelete.id, at: index)
        })
        
        present(alert, animated: true)
    }
    
    private func performSubTaskDeletion(subTaskId: Int, at index: Int) {
        // Initialize DeleteTaskVM if not already done
        let deleteTaskVM = DeleteTaskVM()
        
        // Setup callbacks
        deleteTaskVM.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                // Remove from local array only after successful API call
                if index < (self?.subTasks.count ?? 0) {
                    self?.subTasks.remove(at: index)
                    self?.subTasksCollectionView.reloadData()
                }
                self?.showAlert(title: "Success", message: message)
            }
        }
        
        deleteTaskVM.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: "Failed to delete subtask: \(error)")
            }
        }
        
        // Call the delete API with subtask ID
        deleteTaskVM.deleteTask(taskId: subTaskId)
    }
    
    private func updateSubTaskCompletion(at index: Int) {
        guard index < subTasks.count else { return }
        let subTask = subTasks[index]
        let newCompletionStatus = !subTask.isCompleted
        
        // Update UI immediately for better UX
        subTasks[index] = subTask.withUpdatedCompletion(newCompletionStatus)
        subTasksCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        
        // Create update request
        let request = UpdateSubTaskRequest(
            taskId: String(subTask.id),
            title: subTask.title,
            assignedTo: subTask.assignedTo ?? 0,
            dueDate: subTask.dueDate ?? "",
            priority: subTask.priority ?? "",
            description: subTask.description ?? "",
            status: newCompletionStatus ? "Completed" : "In Progress",
            tags: subTask.tags,
            statusId: String(selectedStatusId ?? 1)
        )
        
        // Call API
        updateSubTaskVM.updateSubTask(request: request)
    }
    
    // MARK: - Helper Methods
    private func showDatePicker() {
        let datePickerVC = UIViewController()
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        if !selectedDueDate.isEmpty {
            datePicker.date = parseDate(selectedDueDate) ?? Date()
        }
        
        datePickerVC.view = datePicker
        
        let alert = UIAlertController(title: "Select Due Date", message: nil, preferredStyle: .actionSheet)
        alert.setValue(datePickerVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Select", style: .default) { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self?.selectedDueDate = formatter.string(from: datePicker.date)
            self?.dueDateLabelOutlet.text = self?.formatDate(self?.selectedDueDate ?? "")
        })
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = dueDatePickerButtonOutlet
            popover.sourceRect = dueDatePickerButtonOutlet.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func toggleTaskNameEdit() {
        if isEditingTaskName {
            // Save mode
            if let textField = taskNameLabelOutlet.superview?.subviews.first(where: { $0 is UITextField }) as? UITextField {
                let newTitle = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !newTitle.isEmpty {
                    taskNameLabelOutlet.text = newTitle
                    // Update the taskData locally
                    // Note: You might want to save this change immediately
                }
                textField.removeFromSuperview()
                taskNameLabelOutlet.isHidden = false
                editTaskButtonOutlet.setTitle("Edit", for: .normal)
                isEditingTaskName = false
            }
        } else {
            // Edit mode
            let textField = UITextField(frame: taskNameLabelOutlet.frame)
            textField.text = taskNameLabelOutlet.text
            textField.borderStyle = .roundedRect
            textField.font = taskNameLabelOutlet.font
            textField.delegate = self
            
            taskNameLabelOutlet.superview?.addSubview(textField)
            taskNameLabelOutlet.isHidden = true
            textField.becomeFirstResponder()
            
            editTaskButtonOutlet.setTitle("Save", for: .normal)
            isEditingTaskName = true
        }
    }
    
    private func saveTaskChanges() {
        guard let taskData = taskData else {
            showAlert(title: "Error", message: "Task data not available")
            return
        }
        
        // Validate required fields
        let title = taskNameLabelOutlet.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else {
            showAlert(title: "Error", message: "Task title cannot be empty")
            return
        }
        
        let statusId = selectedStatusId ?? taskData.taskStatus.id
        let statusTitle = availableStatuses.first(where: { $0.id == statusId })?.title ?? taskData.taskStatus.title
        
        let request = UpdateInnerTaskRequest(
            taskId: String(taskId),
            title: title,
            assignedTo: (selectedAssigneeId ?? taskData.assignedTo) ?? 0,
            dueDate: selectedDueDate.isEmpty ? taskData.dueDate : selectedDueDate,
            priority: selectedPriority.isEmpty ? taskData.priority : selectedPriority,
            description: taskDescriptionTextView.text ?? "",
            status: statusTitle, // ✅ Fixed
            tags: tags,
            statusId: String(statusId)
        )
        
        updateTaskVM.updateTask(request: request)
    }
    
    private func formatDate(_ dateString: String) -> String {
        guard !dateString.isEmpty else { return "No due date" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func formatActivityTime(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, h:mm a"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private func deleteComment(commentId: Int) {
        let alert = UIAlertController(title: "Delete Comment", message: "Are you sure you want to delete this comment?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteCommentsVM.deleteComment(commentId: commentId)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        // Check if there's already a presentation in progress
        if presentedViewController != nil {
            // Dismiss current presentation first
            dismiss(animated: false) { [weak self] in
                self?.presentAlert(title: title, message: message)
            }
        } else {
            presentAlert(title: title, message: message)
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension inDetailTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == commentsAndActivityTextField {
            guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return true
            }
            addComment(message: text)
            return true
        }
        
        toggleTaskNameEdit() // This will save the changes
        return true
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension inDetailTaskViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == commentsAndActivityCollectionView && selectedSegmentIndex == 1 {
            return activitySections.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewOfTags {
            return tags.count + 1 // extra cell for "+ Add Tag"
        } else if collectionView == subTasksCollectionView {
            return subTasks.count + 1 // extra cell for "+ Add Task"
        }else if collectionView == commentsAndActivityCollectionView {
            if selectedSegmentIndex == 0 {
                return comments.count
            } else {
                return section < activitySections.count ? activitySections[section].activities.count : 0
            }
        }
        return 0
    }
    
    // MARK: - FIXED Collection View Methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewOfTags {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagsCollectionViewCell", for: indexPath) as! tagsCollectionViewCell
            
            if indexPath.item < tags.count {
                cell.configureForExistingTag(tags[indexPath.item])
                
                cell.onTagDeleted = { [weak self] in
                    self?.tags.remove(at: indexPath.item)
                    collectionView.reloadData()
                }
            } else {
                cell.configureForAddButton()
                
                cell.addTagButtonAction = { [weak self] in
                    cell.showTextField()
                    cell.tagTextField.becomeFirstResponder()
                }
                
                cell.onTagEntered = { [weak self] newTag in
                    if let text = newTag, !text.isEmpty, !(self?.tags.contains(text) ?? false) {
                        self?.tags.append(text)
                        collectionView.reloadData()
                    }
                }
            }
            
            return cell
        }
        
        else if collectionView == subTasksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subTasksCollectionViewCell", for: indexPath) as! subTasksCollectionViewCell
            
            if indexPath.item < subTasks.count {
                let subTask = subTasks[indexPath.item]
                cell.configureForExistingSubTask(subTask)
                
                cell.onCheckmarkTapped = { [weak self] in
                    self?.updateSubTaskCompletion(at: indexPath.item)
                }
                
                cell.onDeleteTapped = { [weak self] in
                    self?.deleteSubTask(at: indexPath.item)
                }
                
                cell.onEditTapped = { [weak self] in
                    self?.showEditSubTaskAlert(for: indexPath.item)
                }
                
                cell.onCalendarTapped = { [weak self] in
                    self?.showSubTaskDatePicker(for: indexPath.item)
                }
                
            } else {
                cell.configureForAddButton()
                
                cell.onAddTaskTapped = { [weak self] in
                    self?.showAddSubTaskAlert()
                }
            }
            
            return cell
        }
        // FIXED: Comments and Activity Collection View
        else if collectionView == commentsAndActivityCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentsAndActivityCollectionViewCell", for: indexPath) as! commentsAndActivityCollectionViewCell
            
            if selectedSegmentIndex == 0 {
                // Comments
                if indexPath.item < comments.count {
                    let comment = comments[indexPath.item]
                    cell.configureForComment(comment)
                    
                    cell.onDeleteComment = { [weak self] in
                        self?.deleteComment(commentId: comment.id)
                    }
                }
            } else {
                // Activity - using sections
                if indexPath.section < activitySections.count {
                    let section = activitySections[indexPath.section]
                    if indexPath.item < section.activities.count {
                        let activity = section.activities[indexPath.item]
                        
                        // Show date header only for first item in section
                        let showDateHeader = indexPath.item == 0
                        cell.configureForActivity(activity, showDateHeader: showDateHeader, sectionDate: section.date)
                    }
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: - FIXED Collection View Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionViewOfTags {
            if indexPath.item < tags.count {
                let tag = tags[indexPath.item]
                let size = (tag as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                return CGSize(width: max(size.width + 30, 60), height: 35)
            } else {
                return CGSize(width: 100, height: 35)
            }
        } else if collectionView == subTasksCollectionView {
            let width = collectionView.frame.width - 32
            return CGSize(width: max(width, 300), height: 60)
        } else if collectionView == commentsAndActivityCollectionView {
            // FIXED: Use proper width calculation for comments
            let width = collectionView.frame.width - 16 // account for margins
            
            if selectedSegmentIndex == 0 {
                // Comments - calculate height based on content
                let comment = comments[indexPath.item] // your model for comments
                
                if !comment.taskCommFiles.isEmpty {
                    return CGSize(width: width, height: 120) // with docs
                } else {
                    return CGSize(width: width, height: 80)  // no docs
                }
            } else {
                
                return CGSize(width: width, height: 80)
            }
        }
        
        return CGSize(width: 100, height: 40)
    }
    
    private func showSubTaskDatePicker(for index: Int) {
        guard index < subTasks.count else { return }
        let subTask = subTasks[index]
        
        let datePickerVC = UIViewController()
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        // Set current date if available
        if !(subTask.dueDate?.isEmpty ?? false) {
            datePicker.date = parseDate(subTask.dueDate ?? "") ?? Date()
        }
        
        datePickerVC.view = datePicker
        
        let alert = UIAlertController(title: "Update Due Date", message: "Current: \(formatDate(subTask.dueDate ?? ""))", preferredStyle: .actionSheet)
        alert.setValue(datePickerVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let newDueDate = formatter.string(from: datePicker.date)
            
            self?.updateSubTaskDueDate(at: index, newDueDate: newDueDate)
        })
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func updateSubTaskDueDate(at index: Int, newDueDate: String) {
        guard index < subTasks.count else { return }
        let subTask = subTasks[index]
        
        // Update UI immediately
        subTasks[index] = subTask.withUpdatedDueDate(newDueDate)
        subTasksCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        
        // Create update request
        let request = UpdateSubTaskRequest(
            taskId: String(subTask.id),
            title: subTask.title,
            assignedTo: subTask.assignedTo ?? 0,
            dueDate: newDueDate,
            priority: subTask.priority ?? "",
            description: subTask.description ?? "",
            status: subTask.isCompleted ? "Completed" : "In Progress",
            tags: subTask.tags,
            statusId: String(selectedStatusId ?? 1)
        )
        
        // Call API
        updateSubTaskVM.updateSubTask(request: request)
    }
    
    // MARK: - SubTask Helper Methods
    private func showEditSubTaskAlert(for index: Int) {
        
        guard index < subTasks.count else { return }
        let subTask = subTasks[index]
        
        let alert = UIAlertController(title: "Edit Sub Task", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = subTask.title
            textField.placeholder = "Sub task title"
        }
        alert.addTextField { textField in
            textField.text = subTask.description
            textField.placeholder = "Description (optional)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty else { return }
            let description = alert.textFields?[1].text ?? ""
            
            // Update locally first using the extension methods
            self?.subTasks[index] = self?.subTasks[index]
                .withUpdatedTitle(title)
                .withUpdatedDescription(description) ?? subTask
            self?.subTasksCollectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}



// MARK: - Mutable SubTaskData Extension
extension SubTaskData {
    func withUpdatedCompletion(_ isCompleted: Bool) -> SubTaskData {
        return SubTaskData(
            id: self.id,
            title: self.title,
            parentId: self.parentId,
            assignedTo: self.assignedTo,
            assignedBy: self.assignedBy,
            dueDate: self.dueDate,
            description: self.description,
            taskType: self.taskType,
            isCompleted: isCompleted,
            statusId: self.statusId,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
    
    func withUpdatedTitle(_ title: String) -> SubTaskData {
        return SubTaskData(
            id: self.id,
            title: title,
            parentId: self.parentId,
            assignedTo: self.assignedTo,
            assignedBy: self.assignedBy,
            dueDate: self.dueDate,
            description: self.description,
            taskType: self.taskType,
            isCompleted: self.isCompleted,
            statusId: self.statusId,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
    
    func withUpdatedDescription(_ description: String) -> SubTaskData {
        return SubTaskData(
            id: self.id,
            title: self.title,
            parentId: self.parentId,
            assignedTo: self.assignedTo,
            assignedBy: self.assignedBy,
            dueDate: self.dueDate,
            description: description,
            taskType: self.taskType,
            isCompleted: self.isCompleted,
            statusId: self.statusId,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
// MARK: - Mutable InnerSubTaskData Extension
extension InnerSubTaskData {
    func withUpdatedCompletion(_ isCompleted: Bool) -> InnerSubTaskData {
        return InnerSubTaskData(
            tags: self.tags,
            id: self.id,
            title: self.title,
            assignedTo: self.assignedTo,
            projectId: self.projectId,
            priority: self.priority,
            dueDate: self.dueDate,
            createdAt: self.createdAt,
            description: self.description,
            isCompleted: isCompleted,
            internId: self.internId,
            taskOwnerId: self.taskOwnerId,
            taskType: self.taskType
        )
    }
    
    func withUpdatedTitle(_ title: String) -> InnerSubTaskData {
        return InnerSubTaskData(
            tags: self.tags,
            id: self.id,
            title: title,
            assignedTo: self.assignedTo,
            projectId: self.projectId,
            priority: self.priority,
            dueDate: self.dueDate,
            createdAt: self.createdAt,
            description: self.description,
            isCompleted: self.isCompleted,
            internId: self.internId,
            taskOwnerId: self.taskOwnerId,
            taskType: self.taskType
        )
    }
    
    func withUpdatedDescription(_ description: String) -> InnerSubTaskData {
        return InnerSubTaskData(
            tags: self.tags,
            id: self.id,
            title: self.title,
            assignedTo: self.assignedTo,
            projectId: self.projectId,
            priority: self.priority,
            dueDate: self.dueDate,
            createdAt: self.createdAt,
            description: description,
            isCompleted: self.isCompleted,
            internId: self.internId,
            taskOwnerId: self.taskOwnerId,
            taskType: self.taskType
        )
    }
    
    func withUpdatedDueDate(_ dueDate: String) -> InnerSubTaskData {
        return InnerSubTaskData(
            tags: self.tags,
            id: self.id,
            title: self.title,
            assignedTo: self.assignedTo,
            projectId: self.projectId,
            priority: self.priority,
            dueDate: dueDate,
            createdAt: self.createdAt,
            description: self.description,
            isCompleted: self.isCompleted,
            internId: self.internId,
            taskOwnerId: self.taskOwnerId,
            taskType: self.taskType
        )
    }
}
// MARK: - UIDocumentPickerDelegate
extension inDetailTaskViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        selectedFiles.append(contentsOf: urls)
        // Update UI to show selected files if needed
    }
}
