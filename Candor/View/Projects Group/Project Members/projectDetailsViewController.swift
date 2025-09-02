//
//  projectDetailsViewController.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import UIKit
import UniformTypeIdentifiers
import QuickLook

class projectDetailsViewController: UIViewController,QLPreviewControllerDataSource {
    
    @IBOutlet weak var priorityPullDownButtonOutlet: UIButton!
    @IBOutlet weak var assignedToPullDownButtonOutlet: UIButton!
    @IBOutlet weak var createdByPullDownButtonOutlet: UIButton!
    @IBOutlet weak var addSectionButtonOutlet: UIButton!
    @IBOutlet weak var addTaskButtonOutlet: UIButton!
    @IBOutlet weak var addNotesbuttonOutlet: UIButton!
    @IBOutlet weak var menuSegmentOutlet: UISegmentedControl!
    @IBOutlet weak var pullDownButtonStackView: UIStackView!
    @IBOutlet weak var documentsTableView: UITableView!
    
    private let deleteSectionVM = DeleteTaskStatusSectionVM()
    
    private let sectionViewModel = GetProjectTaskSectionNameVM()
    private var sectionsNames: [TaskSection] = []
    private var sectionedTasks: [Int: [ProjectTask]] = [:]
    
    private let taskViewModel = GetTaskVM()
    private var tasks: [ProjectTask] = []
    private var allTasks: [ProjectTask] = []
    private let deleteTaskVM = DeleteTaskVM()
    
    private let documentViewModel = DocumentVM()
    private var documents: [DocumentData] = []
    
    private let noteViewModel = NoteVM()
    private var notes: [NoteData] = []
    
    private let membersViewModel = MembersVM()
    private var projectMembers: [ProjectMember] = []
    
    private var selectedAssignedToFilter: Int? = nil
    private var selectedCreatedByFilter: Int? = nil
    private var selectedPriorityFilter: String? = nil
    
    var projectId: Int = 0
    var fileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNotesbuttonOutlet.isHidden = true
        setupTableView()
        setupDocumentVM()
        setupNoteVM()
        setupMembersVM()
        fetchProjectMembers()
        documentsTableView.separatorStyle = .none
        
        addNotesbuttonOutlet.layer.cornerRadius = 10
        addNotesbuttonOutlet.clipsToBounds = true
        addNotesbuttonOutlet.layer.borderWidth = 2
        addNotesbuttonOutlet.layer.borderColor = UIColor.black.cgColor
        
        sectionViewModel.onSuccess = { [weak self] sections in
            DispatchQueue.main.async {
                self?.sectionsNames = sections
                self?.documentsTableView.reloadData()
            }
        }
        sectionViewModel.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        print("🚀 ProjectDetailsVC loaded with projectId: \(projectId)")
        
        guard projectId > 0 else {
            showAlert(title: "Error", message: "Invalid project ID")
            navigationController?.popViewController(animated: true)
            return
        }
        
        //tasks part
        taskViewModel.onSuccess = { [weak self] fetchedTasks in
            DispatchQueue.main.async {
                self?.tasks = fetchedTasks
                // Group tasks by task_status.id instead of sectionId
                self?.sectionedTasks = Dictionary(grouping: fetchedTasks, by: { $0.task_status.id })
                self?.documentsTableView.reloadData()
            }
        }
        taskViewModel.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
        
        //delete tasks
        setupDeleteTaskVM()
        setupFilterButtons()
        
        // Create actions for the pull-down menu
        let projectInfoAction = UIAction(title: "Project Info", image: UIImage(systemName: "doc.text")) { _ in
            self.showAlert(title: "Project Info", message: "Details about the project")
        }
        
        let documentsAction = UIAction(title: "Documents", image: UIImage(systemName: "folder")) { _ in
            self.menuSegmentOutlet.selectedSegmentIndex = 1
            self.menuSegment(self.menuSegmentOutlet)
        }
        
        let membersAction = UIAction(title: "Members", image: UIImage(systemName: "person.3")) { _ in
            print("Members tapped")
            self.menuSegmentOutlet.selectedSegmentIndex = 2
            self.menuSegment(self.menuSegmentOutlet)
        }
        
        let notesAction = UIAction(title: "Notes", image: UIImage(systemName: "note.text")) { _ in
            print("Notes tapped")
            self.menuSegmentOutlet.selectedSegmentIndex = 3
            self.menuSegment(self.menuSegmentOutlet)
        }
        
        // Create the UIMenu
        let menu = UIMenu(title: "Options", children: [projectInfoAction, membersAction, documentsAction, notesAction])
        
        // Create UIBarButtonItem with menu
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), menu: menu)
        
        // Set title and right bar button
        navigationItem.title = "Project Details"
        navigationItem.rightBarButtonItem = infoButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        print("🔍 ViewWillAppear - Current segment: \(menuSegmentOutlet.selectedSegmentIndex)")
        
        switch menuSegmentOutlet.selectedSegmentIndex {
        case 0:
            print("🔍 Fetching tasks for project: \(projectId)")
            if projectMembers.isEmpty {
                fetchProjectMembers()
            }
            fetchTasks()
        case 1:
            fetchDocuments()
        case 2:
            fetchProjectMembers()
        case 3:
            fetchNotes()
        default:
            break
        }
    }
    private func setupDeleteTaskVM() {
        deleteTaskVM.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message)
                self?.fetchTasks() // Refresh the task list
            }
        }
        
        deleteTaskVM.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
    }
    
    private func setupTableView() {
        documentsTableView.delegate = self
        documentsTableView.dataSource = self
        documentsTableView.register(UINib(nibName: "taskTableViewCell", bundle: nil),
                                    forCellReuseIdentifier: "taskTableViewCell")
        documentsTableView.register(UINib(nibName: "documentTableViewCell", bundle: nil),
                                    forCellReuseIdentifier: "documentTableViewCell")
        documentsTableView.register(UINib(nibName: "memberTableViewCell", bundle: nil),
                                    forCellReuseIdentifier: "memberTableViewCell")
        documentsTableView.register(UINib(nibName: "notesTableViewCell", bundle: nil),
                                    forCellReuseIdentifier: "notesTableViewCell")
        
        documentsTableView.isHidden = false
    }
    
    private func setupFilterButtons() {
        // Set default titles
        assignedToPullDownButtonOutlet.setTitle("Assigned to", for: .normal)
        createdByPullDownButtonOutlet.setTitle("Created by", for: .normal)
        priorityPullDownButtonOutlet.setTitle("Priority", for: .normal)
        
        // Setup menus (will be updated when project members are loaded)
        setupAssignedToFilterMenu()
        setupCreatedByFilterMenu()
        setupPriorityFilterMenu()
    }
    
    private func setupAssignedToFilterMenu() {
        var actions: [UIAction] = []
        
        // Add "All" option
        let allAction = UIAction(title: "All", state: selectedAssignedToFilter == nil ? .on : .off) { [weak self] _ in
            self?.selectedAssignedToFilter = nil
            self?.assignedToPullDownButtonOutlet.setTitle("Assigned to", for: .normal)
            self?.applyFilters()
            self?.setupAssignedToFilterMenu()
        }
        actions.append(allAction)
        
        // Add project members
        for member in projectMembers {
            let memberName = "\(member.user.firstName) \(member.user.lastName)"
            let isSelected = selectedAssignedToFilter == member.user.id
            let action = UIAction(title: memberName, state: isSelected ? .on : .off) { [weak self] _ in
                self?.selectedAssignedToFilter = member.user.id
                self?.assignedToPullDownButtonOutlet.setTitle(memberName, for: .normal)
                self?.applyFilters()
                self?.setupAssignedToFilterMenu()
            }
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Filter by Assigned To", options: .singleSelection, children: actions)
        assignedToPullDownButtonOutlet.menu = menu
        assignedToPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    private func setupCreatedByFilterMenu() {
        var actions: [UIAction] = []
        
        // Add "All" option
        let allAction = UIAction(title: "All", state: selectedCreatedByFilter == nil ? .on : .off) { [weak self] _ in
            self?.selectedCreatedByFilter = nil
            self?.createdByPullDownButtonOutlet.setTitle("All Created", for: .normal)
            self?.applyFilters()
            self?.setupCreatedByFilterMenu()
        }
        actions.append(allAction)
        
        // Add project members
        for member in projectMembers {
            let memberName = "\(member.user.firstName) \(member.user.lastName)"
            let isSelected = selectedCreatedByFilter == member.user.id
            let action = UIAction(title: memberName, state: isSelected ? .on : .off) { [weak self] _ in
                self?.selectedCreatedByFilter = member.user.id
                self?.createdByPullDownButtonOutlet.setTitle(memberName, for: .normal)
                self?.applyFilters()
                self?.setupCreatedByFilterMenu()
            }
            actions.append(action)
        }
        
        let menu = UIMenu(title: "Filter by Created By", options: .singleSelection, children: actions)
        createdByPullDownButtonOutlet.menu = menu
        createdByPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    private func setupPriorityFilterMenu() {
        let priorityOptions = ["All", "Urgent", "Important", "Non Urgent"]
        
        let actions = priorityOptions.map { option -> UIAction in  // Added missing return type
            let isSelected = (option == "All" && selectedPriorityFilter == nil) ||
            (option == selectedPriorityFilter)
            
            return UIAction(title: option, state: isSelected ? .on : .off) { [weak self] _ in
                if option == "All" {
                    self?.selectedPriorityFilter = nil
                    self?.priorityPullDownButtonOutlet.setTitle("All", for: .normal)
                } else {
                    self?.selectedPriorityFilter = option
                    self?.priorityPullDownButtonOutlet.setTitle(option, for: .normal)
                }
                self?.applyFilters()
                self?.setupPriorityFilterMenu()
            }
        }
        
        let menu = UIMenu(title: "Filter by Priority", options: .singleSelection, children: actions)
        priorityPullDownButtonOutlet.menu = menu
        priorityPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    private func applyFilters() {
        var filteredTasks = allTasks
        
        // Filter by assigned to
        if let assignedToId = selectedAssignedToFilter {
            if assignedToId == -1 {
                // Show unassigned tasks
                filteredTasks = filteredTasks.filter { $0.assignee == nil }
            } else {
                // Show tasks assigned to specific person
                filteredTasks = filteredTasks.filter { $0.assignee?.id == assignedToId }
            }
        }
        
        // Filter by created by
        if let createdById = selectedCreatedByFilter {
            filteredTasks = filteredTasks.filter { $0.assignor.id == createdById }
        }
        
        // Filter by priority
        if let priority = selectedPriorityFilter {
            filteredTasks = filteredTasks.filter { $0.priority == priority }
        }
        
        // Update tasks and sectioned tasks
        self.tasks = filteredTasks
        self.sectionedTasks = Dictionary(grouping: filteredTasks, by: { $0.task_status.id })
        
        DispatchQueue.main.async {
            self.documentsTableView.reloadData()
        }
    }
    
    private func setupDocumentVM() {
        documentViewModel.documentUploadSuccess = { [weak self] message in
            print("Document uploaded: \(message)")
            self?.fetchDocuments()
        }
        
        documentViewModel.documentUploadFailure = { [weak self] error in
            self?.showAlert(title: "Upload Failed", message: error)
        }
        
        documentViewModel.onDocumentsFetchedSuccess = { [weak self] data in
            self?.documents = data.page_data
            self?.documentsTableView.reloadData()
        }
        
        documentViewModel.onDocumentsFetchedFailure = { [weak self] error in
            self?.showAlert(title: "Fetch Failed", message: error)
        }
    }
    
    private func setupNoteVM() {
        noteViewModel.noteAddSuccess = { [weak self] message in
            print("Note added: \(message)")
            self?.fetchNotes()
        }
        
        noteViewModel.noteAddFailure = { [weak self] error in
            self?.showAlert(title: "Add Note Failed", message: error)
        }
        
        noteViewModel.onNotesFetchedSuccess = { [weak self] data in
            self?.notes = data
            self?.documentsTableView.reloadData()
        }
        
        noteViewModel.onNotesFetchedFailure = { [weak self] error in
            self?.showAlert(title: "Fetch Notes Failed", message: error)
        }
    }
    
    private func setupMembersVM() {
        membersViewModel.onProjectMembersFetched = { [weak self] members in
            DispatchQueue.main.async {
                self?.projectMembers = members
                self?.setupAssignedToFilterMenu()
                self?.setupCreatedByFilterMenu()
                self?.documentsTableView.reloadData()
            }
        }
        
        membersViewModel.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message)
                self?.fetchProjectMembers() // Refresh members list
            }
        }
        
        membersViewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
    }
    
    private func fetchTasks(){
        print("📋 Fetching tasks for projectId: \(projectId)")
        taskViewModel.onSuccess = { [weak self] fetchedTasks in
            DispatchQueue.main.async {
                self?.allTasks = fetchedTasks  // Store all tasks for filtering
                self?.tasks = fetchedTasks     // Display tasks
                self?.sectionedTasks = Dictionary(grouping: fetchedTasks, by: { $0.task_status.id })
                
                // Update filter menus after tasks are loaded
                self?.setupAssignedToFilterMenu()
                self?.setupCreatedByFilterMenu()
                self?.setupPriorityFilterMenu()
                
                self?.documentsTableView.reloadData()
            }
        }
        
        taskViewModel.getTasks(
            projectId: projectId,
            assignedTo: nil,
            priority: nil
        )
        sectionViewModel.getSections(projectId: projectId)
    }
    
    private func fetchDocuments() {
        print("📄 Fetching documents for projectId: \(projectId)")
        documentViewModel.fetchDocuments(projectId: projectId)
    }
    
    private func fetchNotes() {
        print("📝 Fetching notes for projectId: \(projectId)")
        noteViewModel.fetchNote(projectId: projectId)
    }
    
    private func fetchProjectMembers() {
        print("👥 Fetching members for projectId: \(projectId)")
        membersViewModel.getProjectMembers(projectId: projectId)
    }
    
    // MARK: - QuickLook DataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileURL == nil ? 0 : 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL! as QLPreviewItem
    }
    
    func topViewController(controller: UIViewController? = UIApplication.shared
        .connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?
        .windows
        .first { $0.isKeyWindow }?
        .rootViewController) -> UIViewController? {
            
            if let nav = controller as? UINavigationController {
                return topViewController(controller: nav.visibleViewController)
            }
            if let tab = controller as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
    
    @IBAction func addSectionButton(_ sender: UIButton) {
        let addSectionVC = addTaskSectionViewController(nibName: "addTaskSectionViewController", bundle: nil)
        addSectionVC.modalPresentationStyle = .overCurrentContext
        addSectionVC.modalTransitionStyle = .crossDissolve
        addSectionVC.projectId = self.projectId
        addSectionVC.onSectionAdded = { [weak self] in
            self?.fetchTasks() // refresh tasks after section added
        }
        self.present(addSectionVC, animated: true)
    }
    
    @IBAction func addTaskButton(_ sender: UIButton) {
        if projectMembers.isEmpty {
            membersViewModel.onProjectMembersFetched = { [weak self] members in
                DispatchQueue.main.async {
                    self?.projectMembers = members
                    self?.presentAddTaskScreen()
                }
            }
            fetchProjectMembers()
        } else {
            presentAddTaskScreen()
        }
    }
    
    @IBAction func menuSegment(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            pullDownButtonStackView.isHidden = false
            addNotesbuttonOutlet.isHidden = true
            documentsTableView.isHidden = false
            addTaskButtonOutlet.isHidden = false
            addSectionButtonOutlet.isHidden = false
            fetchTasks()
        case 1:
            pullDownButtonStackView.isHidden = true
            addNotesbuttonOutlet.isHidden = false
            documentsTableView.isHidden = false
            addTaskButtonOutlet.isHidden = true
            addSectionButtonOutlet.isHidden = true
            addNotesbuttonOutlet.setTitle("  Add Document", for: .normal)
            fetchDocuments() // Fetch documents when switching to documents tab
        case 2:
            pullDownButtonStackView.isHidden = true
            addNotesbuttonOutlet.isHidden = false
            documentsTableView.isHidden = false
            addTaskButtonOutlet.isHidden = true
            addSectionButtonOutlet.isHidden = true
            addNotesbuttonOutlet.setTitle("  Add Member", for: .normal)
            fetchProjectMembers() // Fetch members when switching to members tab
        case 3:
            pullDownButtonStackView.isHidden = true
            addNotesbuttonOutlet.isHidden = false
            documentsTableView.isHidden = false
            addTaskButtonOutlet.isHidden = true
            addSectionButtonOutlet.isHidden = true
            addNotesbuttonOutlet.setTitle("  Add Note", for: .normal)
            fetchNotes() // Fetch notes when switching to notes tab
        default:
            break
        }
    }
    
    @IBAction func addNotesButton(_ sender: UIButton) {
        if menuSegmentOutlet.selectedSegmentIndex == 1 {
            // Show add document view controller
            let addDocumentVC = addDocumentViewController(nibName: "addDocumentViewController", bundle: nil)
            addDocumentVC.modalPresentationStyle = .overCurrentContext
            addDocumentVC.modalTransitionStyle = .crossDissolve
            addDocumentVC.delegate = self
            addDocumentVC.projectId = self.projectId
            
            self.present(addDocumentVC, animated: true)
        } else if menuSegmentOutlet.selectedSegmentIndex == 2 {
            // Show add member view controller
            let addMemberVC = addMemberViewController(nibName: "addMemberViewController", bundle: nil)
            addMemberVC.modalPresentationStyle = .overCurrentContext
            addMemberVC.modalTransitionStyle = .crossDissolve
            addMemberVC.delegate = self
            addMemberVC.projectId = self.projectId
            
            self.present(addMemberVC, animated: true)
        } else if menuSegmentOutlet.selectedSegmentIndex == 3 {
            // Show add note view controller
            let notesVC = addNoteViewController(nibName: "addNoteViewController", bundle: nil)
            notesVC.modalPresentationStyle = .overCurrentContext
            notesVC.modalTransitionStyle = .crossDissolve
            notesVC.delegate = self
            notesVC.projectId = self.projectId
            
            self.present(notesVC, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension projectDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch menuSegmentOutlet.selectedSegmentIndex {
        case 0:
            return sectionsNames.count
        case 1: // Documents
            return max(1, documents.count)
        case 2: // Members
            return max(1, projectMembers.count)
        case 3: // Notes
            return max(1, notes.count)
        default:
            return 1
        }
    }
    // MARK: - Fixed didSelectRowAt method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch menuSegmentOutlet.selectedSegmentIndex {
        case 0: // Tasks
            let sectionId = sectionsNames[indexPath.section].id
            let tasksInSection = sectionedTasks[sectionId] ?? []
            
            // Check if there are tasks in this section and if the row is valid
            guard !tasksInSection.isEmpty && indexPath.row < tasksInSection.count else {
                print("No task found at section \(indexPath.section), row \(indexPath.row)")
                return
            }
            
            let selectedTask = tasksInSection[indexPath.row]
            let detailVC = inDetailTaskViewController(nibName: "inDetailTaskViewController", bundle: nil)
            detailVC.taskId = selectedTask.id
            navigationController?.pushViewController(detailVC, animated: true)
            
        case 1: // Documents
            guard !documents.isEmpty && indexPath.section < documents.count else {
                print("No document found at section \(indexPath.section)")
                return
            }
            
            let document = documents[indexPath.section]
            
            guard let remoteURL = URL(string: document.document) else {
                showAlert(title: "Error", message: "Invalid document URL")
                return
            }
            
            // Download to a local temp file
            let task = URLSession.shared.downloadTask(with: remoteURL) { [weak self] localURL, response, error in
                guard let self = self else { return }
                
                if let localURL = localURL, error == nil {
                    // Save to temp directory with original filename
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(remoteURL.lastPathComponent)
                    
                    // Remove if already exists
                    try? FileManager.default.removeItem(at: tempURL)
                    try? FileManager.default.moveItem(at: localURL, to: tempURL)
                    
                    DispatchQueue.main.async {
                        self.fileURL = tempURL
                        let previewController = QLPreviewController()
                        previewController.dataSource = self
                        self.present(previewController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to load document")
                    }
                }
            }
            task.resume()
            
        case 2: // Members
            guard !projectMembers.isEmpty && indexPath.section < projectMembers.count else {
                print("No member found at section \(indexPath.section)")
                return
            }
            // Handle member selection if needed
            
        case 3: // Notes
            guard !notes.isEmpty && indexPath.section < notes.count else {
                print("No note found at section \(indexPath.section)")
                return
            }
            // Handle note selection if needed
            
        default:
            break
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch menuSegmentOutlet.selectedSegmentIndex {
        case 0: // Tasks
            guard indexPath.section < sectionsNames.count else {
                print("Section index out of range: \(indexPath.section)")
                return UITableViewCell()
            }
            let sectionId = sectionsNames[indexPath.section].id
            let tasksInSection = sectionedTasks[sectionId] ?? []
            
            if tasksInSection.isEmpty {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "emptyCell")
                cell.textLabel?.text = "No tasks in this section"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .lightGray
                cell.selectionStyle = .none
                return cell
            } else {
                guard indexPath.row < tasksInSection.count else {
                    print("Row index out of range: \(indexPath.row) for section with \(tasksInSection.count) tasks")
                    return UITableViewCell()
                }
                
                let task = tasksInSection[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableViewCell", for: indexPath) as! taskTableViewCell
                
                cell.configure(with: task, projectId: projectId)
                cell.delegate = self // Add this line to set the delegate
                cell.selectionStyle = .none
                return cell
            }
        case 1: // Documents tab
            if documents.isEmpty {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "emptyCell")
                cell.textLabel?.text = "No documents uploaded yet"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .lightGray
                cell.selectionStyle = .none
                return cell
            } else {
                guard indexPath.section < documents.count else {
                    print("Document section index out of range: \(indexPath.section)")
                    return UITableViewCell()
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "documentTableViewCell", for: indexPath) as! documentTableViewCell
                
                let document = documents[indexPath.section]
                cell.configure(with: document)
                cell.delegate = self
                cell.selectionStyle = .none
                
                return cell
            }
            
        case 2: // Members tab
            if projectMembers.isEmpty {
                
                let cell = UITableViewCell(style: .default, reuseIdentifier: "emptyCell")
                cell.textLabel?.text = "No members added yet"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .lightGray
                cell.selectionStyle = .none
                return cell
            } else {
                guard indexPath.section < projectMembers.count else {
                    print("Member section index out of range: \(indexPath.section)")
                    return UITableViewCell()
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "memberTableViewCell", for: indexPath) as! memberTableViewCell
                
                let member = projectMembers[indexPath.section]
                cell.configure(with: member)
                cell.delegate = self
                cell.selectionStyle = .none
                
                return cell
            }
            
        case 3: // Notes tab
            if notes.isEmpty {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "emptyCell")
                cell.textLabel?.text = "No notes added yet"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .lightGray
                cell.selectionStyle = .none
                return cell
            } else {
                guard indexPath.section < notes.count else {
                    print("Note section index out of range: \(indexPath.section)")
                    return UITableViewCell()
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "notesTableViewCell", for: indexPath) as! notesTableViewCell
                
                let note = notes[indexPath.section]
                cell.configure(with: note, serialNumber: indexPath.section + 1)
                cell.delegate = self
                cell.selectionStyle = .none
                
                return cell
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch menuSegmentOutlet.selectedSegmentIndex {
        case 0: // Tasks
            let sectionId = sectionsNames[section].id
            let tasksInSection = sectionedTasks[sectionId] ?? []
            return max(1, tasksInSection.count)
        case 1: // Documents
            return 1
        case 2: // Members
            return 1
        case 3: // Notes
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if menuSegmentOutlet.selectedSegmentIndex == 0 {
            return sectionsNames[section].title
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard menuSegmentOutlet.selectedSegmentIndex == 0 else {
            return nil
        }
        // Add bounds check
        guard section < sectionsNames.count else {
            print("Section index out of range in header: \(section)")
            return nil
        }
        
        let sectionData = sectionsNames[section]
        
        // Container view
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6
        
        // Label for section title
        let titleLabel = UILabel()
        titleLabel.text = sectionData.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Delete button
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.tag = sectionData.id  // store sectionId for deletion
        deleteButton.addTarget(self, action: #selector(deleteSectionTapped(_:)), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(deleteButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    @objc private func deleteSectionTapped(_ sender: UIButton) {
        let sectionId = sender.tag
        
        let alert = UIAlertController(title: "Delete Section",
                                      message: "Are you sure you want to delete this section and its tasks?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.deleteSectionVM.deleteTaskStatus(taskStatusId: sectionId)
            
            self.deleteSectionVM.onSuccess = { message in
                DispatchQueue.main.async {
                    self.showAlert(title: "Deleted", message: message)
                    self.fetchTasks() // reload tasks & sections
                }
            }
            
            self.deleteSectionVM.onFailure = { error in
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error)
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return menuSegmentOutlet.selectedSegmentIndex == 0 ? 44 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch menuSegmentOutlet.selectedSegmentIndex {
        case 0:
            return 0
        case 1: // Documents
            return (!documents.isEmpty && section < documents.count - 1) ? 16 : 0
        case 2: // Members
            return (!projectMembers.isEmpty && section < projectMembers.count - 1) ? 16 : 0
        case 3: // Notes
            return (!notes.isEmpty && section < notes.count - 1) ? 16 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Only show swipe actions for tasks (segment 0)
        guard menuSegmentOutlet.selectedSegmentIndex == 0 else {
            return nil
        }
        
        // Validate section index
        guard indexPath.section < sectionsNames.count else {
            print("Section index out of range in swipe actions: \(indexPath.section)")
            return nil
        }
        
        // Get the task for this row
        let sectionId = sectionsNames[indexPath.section].id
        let tasksInSection = sectionedTasks[sectionId] ?? []
        
        // Make sure there's a task at this index
        guard !tasksInSection.isEmpty && indexPath.row < tasksInSection.count else {
            print("No task found for swipe action at section \(indexPath.section), row \(indexPath.row)")
            return nil
        }
        
        let task = tasksInSection[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            // Show confirmation alert
            let alert = UIAlertController(
                title: "Delete Task",
                message: "Are you sure you want to delete?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                // Call the delete API
                self.deleteTaskVM.deleteTask(taskId: task.id)
                completionHandler(true)
            })
            
            self.present(alert, animated: true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false // Prevents accidental deletion
        
        return configuration
    }
    
}

// MARK: - AddDocumentDelegate
extension projectDetailsViewController: AddDocumentDelegate {
    func documentUploaded() {
        fetchDocuments() // Reload documents after upload
        // this is the function of the protocol
    }
}

// MARK: - AddNoteDelegate
extension projectDetailsViewController: AddNoteDelegate {
    func noteAdded() {
        fetchNotes() // Reload notes after adding
    }
}
extension projectDetailsViewController: AddMemberDelegate {
    func memberAdded() {
        fetchProjectMembers() // Refresh members list after adding
    }
}

// MARK: - DocumentCellDelegate
extension projectDetailsViewController: DocumentCellDelegate {
    func deleteDocument(documentId: Int) {
        let alert = UIAlertController(title: "Delete Document",
                                      message: "Are you sure you want to delete this document?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.documentViewModel.deleteDocument(documentId: documentId)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - NoteCellDelegate
extension projectDetailsViewController: NoteCellDelegate {
    func editNote(note: NoteData) {
        let editNoteVC = addNoteViewController(nibName: "addNoteViewController", bundle: nil)
        editNoteVC.modalPresentationStyle = .overCurrentContext
        editNoteVC.modalTransitionStyle = .crossDissolve
        editNoteVC.delegate = self
        editNoteVC.projectId = self.projectId
        editNoteVC.noteToEdit = note // Pass the note to edit
        
        self.present(editNoteVC, animated: true)
    }
    
    func deleteNote(noteId: Int) {
        let alert = UIAlertController(title: "Delete Note",
                                      message: "Are you sure you want to delete this note?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.noteViewModel.deleteNote(noteId: noteId)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - MemberCellDelegate
extension projectDetailsViewController: MemberCellDelegate {
    func removeMember(userId: Int) {
        let alert = UIAlertController(title: "Remove Member",
                                      message: "Are you sure you want to remove this member from the project?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.membersViewModel.removeProjectMember(projectId: self.projectId, userId: userId)
        })
        
        present(alert, animated: true)
    }
}

extension projectDetailsViewController: AddTaskDelegate {
    func taskAdded() {
        fetchTasks() // ✅ Reload task list
    }
}

extension projectDetailsViewController {
    
    private func presentAddTaskScreen() {
        let addTaskVC = addTaskViewController(nibName: "addTaskViewController", bundle: nil)
        addTaskVC.modalPresentationStyle = .overCurrentContext
        addTaskVC.modalTransitionStyle = .crossDissolve
        
        addTaskVC.projectId = self.projectId // Pass the actual project ID
        addTaskVC.availableMembers = self.projectMembers
        addTaskVC.availableSections = self.sectionsNames // Pass available sections
        addTaskVC.delegate = self
        
        self.present(addTaskVC, animated: true)
    }
}

// MARK: - TaskCellDelegate implementation
extension projectDetailsViewController: TaskCellDelegate {
    func taskUpdated() {
        // Refresh the tasks when a task is updated from the cell
        fetchTasks()
    }
}
