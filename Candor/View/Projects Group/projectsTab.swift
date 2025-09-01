//
//  projectsTab.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import UIKit

class projectsTab: UIView {
    
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var menuButtonOutlet: UIButton!
    @IBOutlet weak var projectTableView: UITableView!
    @IBOutlet weak var logoBGGradientView: UIView!
    
    let projectsViewModel = ProjectsVM()
    let checkVar = MembersVM()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
        setupViewModelCallbacks()
        setupUI()
        projectsViewModel.fetchProjects()
        
    }

    private func setupTableView() {
        projectTableView.delegate = self
        projectTableView.dataSource = self
        let nib = UINib(nibName: "projectsTableViewCell", bundle: nil)
        projectTableView.register(nib, forCellReuseIdentifier: "projectsTableViewCell")
        
        projectTableView.layer.cornerRadius = 10
        projectTableView.backgroundColor = .clear
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshProjects), for: .valueChanged)
        projectTableView.refreshControl = refreshControl
    }
    
    private func setupUI() {
        // Any additional UI setup
    }
    
    @objc private func refreshProjects() {
        projectsViewModel.fetchProjects()
    }
    
    private func setupViewModelCallbacks() {
        projectsViewModel.onDataFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.projectTableView.reloadData()
                self?.projectTableView.refreshControl?.endRefreshing()
            }
        }
        
        projectsViewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.projectTableView.refreshControl?.endRefreshing()
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }
    
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.projectsViewModel.fetchProjects()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        topViewController()?.present(alert, animated: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if logoBGGradientView != nil && logoBGGradientView.bounds != .zero {
            let color1 = UIColor(named: "color8") ?? UIColor.systemBlue
            let color2 = UIColor(named: "color6") ?? UIColor.systemTeal
            
            logoBGGradientView.applyGradient(colors: [color1, color2], cornerRadius: 20)
        }
    }
    
    @IBAction func addProjectButton(_ sender: UIButton) {
        
        let formVC = addProjectForm(nibName: "addProjectFormViewController", bundle: nil)
        formVC.modalPresentationStyle = .overCurrentContext
        formVC.modalTransitionStyle = .crossDissolve
        formVC.reloadDelegate = self
        topViewController()?.present(formVC, animated: true)

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

    func reloadingData() {
        projectsViewModel.onDataFetched = { [weak self] in
            self?.projectTableView.reloadData()
            
        }
        projectsViewModel.fetchProjects()
    }
}

extension projectsTab:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = projectsViewModel.projects.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "projectsTableViewCell", for: indexPath) as? projectsTableViewCell else {
            return UITableViewCell()
        }
        
        guard indexPath.row < projectsViewModel.projects.count else {
            return UITableViewCell()
        }
        
        let project = projectsViewModel.projects[indexPath.row]
        
        cell.projectName.text = project.name
        cell.projectStatus.text = project.status
        
        cell.projectDeadLine.text = project.deadline
        
        cell.projectStartDate.text = "\(project.startDate)"
        cell.taskAssignedBy.text = "\(project.user.firstName) " + "\(project.user.lastName)"
        
        
        switch project.status {
        case "In Progress":
            cell.statusBGView.backgroundColor = .systemOrange
        case "Complete":
            cell.statusBGView.backgroundColor = .systemGreen
        case "On Hold":
            cell.statusBGView.backgroundColor = .systemPurple
        case "Cancelled":
            cell.statusBGView.backgroundColor = .systemRed
        default:
            cell.statusBGView.backgroundColor = .systemGray
        }
        cell.projectID = ("\(project.id)")  // Pass project ID
        cell.onStatusChange = { [weak self] newStatus, statusCode, projectID in
            
            self?.projectsViewModel.updateProjectStatus(projectID: projectID, status: newStatus) { success in
            }
        }
        return cell
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            
            guard let self = self else { return }
            let project = self.projectsViewModel.projects[indexPath.row]
            let projectID = "\(project.id)"
            
            // Confirm deletion
            let alert = UIAlertController(title: "Delete Project", message: "Are you sure you want to delete \"\(project.name)\"?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                // Call ViewModel method
                self.projectsViewModel.deleteProject(with: projectID) { success in
                    if success {
                        self.projectsViewModel.fetchProjects()
                    } else {
                        self.showErrorAlert(message: "Failed to delete project")
                    }
                }
            }))
            self.topViewController()?.present(alert, animated: true)
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    
}


extension projectsTab: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProject = projectsViewModel.projects[indexPath.row]
        
        let storyboard = UIStoryboard(name: "projectDetailsViewController", bundle: nil)
        
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "projectDetailsViewController") as? projectDetailsViewController{
            detailVC.projectId = selectedProject.id
            
            topViewController()?.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension projectsTab: DataReload {
    func dataReloading() {
        projectsViewModel.fetchProjects()
    }
}
