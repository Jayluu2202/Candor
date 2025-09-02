//
//  dashboardTab.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import UIKit

class dashboardTab: UIView {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var viewInScrollView: UIView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var logoBGGradientView: UIView!
    @IBOutlet weak var menuButtonOutlet: UIButton!
    @IBOutlet weak var welcomeTextLabel: UILabel!
    ///project part
    @IBOutlet weak var projectTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var projectUnderLine: UIView!
    @IBOutlet weak var dashboardProjectCollectionView: UICollectionView!
    ///employee part
    @IBOutlet weak var employeeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var employeeTitleLabel: UILabel!
    @IBOutlet weak var employeeUnderLine: UIView!
    @IBOutlet weak var dashboardEmployeesCollectionView: UICollectionView!
    ///clientAndLead part
    @IBOutlet weak var clientAndLeadTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var clientAndLeadTitleLabel: UILabel!
    @IBOutlet weak var clientAndLeadLine: UIView!
    @IBOutlet weak var dashboardClientAndLeadCollectionView: UICollectionView!
    
    
    
    let dashBoardViewModel = DashboardVM()
    var singleEmployeeDashboardViewModel = SingleEmployeeInfoVM()
    
    var tabChange = mainViewController()
    
    let userInfoViewModel = LoggedInUserVM()
    
    var projectItems: [(title: String, value: Int)] = []
    var employeeItems: [(title: String, value: Int)] = []
    var clientLeadItems: [(title: String, value: Int)] = []
    private let refreshControl = UIRefreshControl()
    
    //NIB scope
    override func awakeFromNib() {
        super.awakeFromNib()
        userInfoViewModel.fetchUserProfile()
        customUiElement()
        setupCollectionViews()
        setupRefreshControl()
        fetchDashboard()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if logoBGGradientView != nil && logoBGGradientView.bounds != .zero {
            let color1 = UIColor(named: "color8") ?? UIColor.systemBlue
            let color2 = UIColor(named: "color6") ?? UIColor.systemTeal
            logoBGGradientView.applyGradient(colors: [color1, color2], cornerRadius: 20)
        }
    }
    
    func customUiElement(){
        userInfoViewModel.onProfileFetchSuccess = { profile in
            DispatchQueue.main.async {
                self.welcomeTextLabel.text = "Welcome, \(profile.first_name)"
            }
        }
        userInfoViewModel.onProfileFetchFailure = { error in
            print("❌ Failed to fetch user profile: \(error)")
        }
        
        dashboardProjectCollectionView.backgroundColor = .clear
        dashboardEmployeesCollectionView.backgroundColor = .clear
        dashboardClientAndLeadCollectionView.backgroundColor = .clear
        
        if let role = UserDefaults.standard.string(forKey: "userRole") {
            print("📌 User role in dashboardTab: \(role)")
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Dashboard...")
        refreshControl.addTarget(self, action: #selector(refreshDashboardData), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
    }
    @objc private func refreshDashboardData() {
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.fetchDashboard()
        }
    }
    
    private func fetchDashboard() {
        dashBoardViewModel.onSucces = { [weak self] in
            guard let self = self, let data = self.dashBoardViewModel.dashboardData else { return }
            
            self.projectItems = [
                ("Total Projects", data.project_list.total_project),
                ("Completed", data.project_list.complete_project),
                ("Running", data.project_list.running_project),
                ("Overdue", data.project_list.over_due_project)
            ]
            
            self.employeeItems = [
                ("Total Employees", data.employee_list.total_employee),
                ("Active", data.employee_list.active_employee),
                ("Inactive", data.employee_list.inactive_employee),
                ("On Termination", data.employee_list.on_termination_employee)
            ]
            
            self.clientLeadItems = [
                ("Total Clients", data.client_list.total_client),
                ("Total Leads", data.project_lead_list.total_project_lead),
                ("Open Leads", data.project_lead_list.open_project_lead),
                ("Confirmed Leads", data.project_lead_list.confirm_sale_project_lead)
            ]
            
            DispatchQueue.main.async {
                self.applyRoleUIChanges()
                self.dashboardProjectCollectionView.reloadData()
                self.dashboardEmployeesCollectionView.reloadData()
                self.dashboardClientAndLeadCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        
        dashBoardViewModel.onFailure = { error in
            self.refreshControl.endRefreshing()
        }
        
        dashBoardViewModel.fetchDashboardDetails()
    }
    
    private func applyRoleUIChanges() {
        if let role = UserDefaults.standard.string(forKey: "userRole") {
            if role == "HR" {
                dashboardProjectCollectionView.isHidden = true
                projectTitleLabel.isHidden = true
                projectUnderLine.isHidden = true
                
                dashboardClientAndLeadCollectionView.isHidden = true
                clientAndLeadTitleLabel.isHidden = true
                clientAndLeadLine.isHidden = true
                
                employeeTopConstraint.constant = -275
                scrollViewHeightConstraint.constant = 0
                
                
            }else if role == "Accountant"{
                dashboardEmployeesCollectionView.isHidden = true
                employeeTitleLabel.isHidden = true
                employeeUnderLine.isHidden = true
                
                clientAndLeadTopConstraint.constant = -250
                scrollViewHeightConstraint.constant = 0
                
            }
        }
    }

    
    func setupCollectionViews() {
        let projectNib = UINib(nibName: "projectCollectionViewCell", bundle: nil)
        dashboardProjectCollectionView.register(projectNib, forCellWithReuseIdentifier: "projectCollectionViewCell")
        
        let employeeNib = UINib(nibName: "employeeCollectionViewCell", bundle: nil)
        dashboardEmployeesCollectionView.register(employeeNib, forCellWithReuseIdentifier: "employeeCollectionViewCell")
        
        let clientNib = UINib(nibName: "clientAndLeadsCollectionViewCell", bundle: nil)
        dashboardClientAndLeadCollectionView.register(clientNib, forCellWithReuseIdentifier: "clientAndLeadsCollectionViewCell")
        
        let collectionvViewLayout = UICollectionViewFlowLayout()
        collectionvViewLayout.minimumLineSpacing = 10
        collectionvViewLayout.minimumInteritemSpacing = 10
        
        [dashboardProjectCollectionView, dashboardEmployeesCollectionView, dashboardClientAndLeadCollectionView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.collectionViewLayout = collectionvViewLayout
        }
        
    }
    
}

// MARK: - UICollectionViewDataSource
extension dashboardTab: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case dashboardProjectCollectionView:
            return projectItems.count
        case dashboardEmployeesCollectionView:
            return employeeItems.count
        case dashboardClientAndLeadCollectionView:
            return clientLeadItems.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case dashboardProjectCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "projectCollectionViewCell", for: indexPath) as! projectCollectionViewCell
            let item = projectItems[indexPath.item]
            cell.configureCell(title: item.title, value: item.value)
            return cell
            
        case dashboardEmployeesCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "employeeCollectionViewCell", for: indexPath) as! employeeCollectionViewCell
            let item = employeeItems[indexPath.item]
            cell.configureCell(title: item.title, value: item.value)
            return cell
            
        case dashboardClientAndLeadCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clientAndLeadsCollectionViewCell", for: indexPath) as! clientAndLeadsCollectionViewCell
            let item = clientLeadItems[indexPath.item]
            cell.configureCell(title: item.title, value: item.value)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension dashboardTab: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped item at \(indexPath) in \(collectionView)")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension dashboardTab: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
