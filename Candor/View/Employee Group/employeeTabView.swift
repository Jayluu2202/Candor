//
//  employeeTab.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import UIKit

class employeeTab: UIView {
    
    
    @IBOutlet weak var searchEmployeeBar: UISearchBar!
    @IBOutlet weak var addButtonOutlet: UIButton!
    @IBOutlet weak var menuButtonOutlet: UIButton!
    @IBOutlet weak var employeeTableView: UITableView!
    @IBOutlet weak var logoBGGradientView: UIView!
    
    let employeeViewModel = EmployeeListVM()
    
    var isEditMode: Bool = false
    var isEditTitle: Bool = false
    
    var employeeInfo: SingleEmployeeData?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        employeeTableView.delegate = self
        employeeTableView.dataSource = self
        cellPresentation()
        
        customUiElements()
        
        employeeViewModel.fetchEmployees()
    }
    
    func customUiElements(){
        searchEmployeeBar.layer.cornerRadius = 10
        searchEmployeeBar.clipsToBounds = true
        searchEmployeeBar.backgroundColor = .clear
        employeeTableView.layer.cornerRadius = 10
        employeeTableView.clipsToBounds = true
        employeeTableView.backgroundColor = .clear
    }
    
    func cellPresentation(){
        let nib = UINib(nibName: "employeeTableViewCell", bundle: nil)
        employeeTableView.register(nib, forCellReuseIdentifier: "employeeTableViewCell")
        employeeViewModel.onSuccess = {
            DispatchQueue.main.async {
                self.employeeTableView.reloadData()
            }
        }
        
        employeeViewModel.onFailure = { errorMessage in
            print("Failed to fetch employees: \(errorMessage)")
        }
    }
    
    func loadImageFromURL(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined().uppercased()
    }

    @IBAction func addEmployeeButton(_ sender: UIButton){
        let addEmployeeVC = addEmployeeForm(nibName: "addEmployeeFormViewController", bundle: nil)
        
        addEmployeeVC.isEditMode = false
        addEmployeeVC.isEditTitle = false
        addEmployeeVC.editEmployeeData = self.employeeInfo
        
        addEmployeeVC.onAddCompleted = { [weak self] _ in
            self?.employeeViewModel.fetchEmployees()
        }
        
        if let topVC = self.newTopViewController() {
            if let navigationController = topVC.navigationController {
                navigationController.pushViewController(addEmployeeVC, animated: true)
            } else {
                topVC.present(addEmployeeVC, animated: true, completion: nil)
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if logoBGGradientView != nil && logoBGGradientView.bounds != .zero {
            let color1 = UIColor(named: "color8") ?? UIColor.systemBlue
            let color2 = UIColor(named: "color6") ?? UIColor.systemTeal
            
            logoBGGradientView.applyGradient(colors: [color1, color2], cornerRadius: 20)
        }
    }
}



// Mark:- DataSource
extension employeeTab: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employeeViewModel.employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "employeeTableViewCell", for: indexPath) as? employeeTableViewCell else{
            return UITableViewCell()
        }

        let employee = employeeViewModel.employees[indexPath.row]
        let fullName = "\(employee.first_name) \(employee.last_name)"
        
        cell.employeeName.text = "\(employee.first_name ) \(employee.last_name )"
        cell.employeeId.text = employee.employee_id
        cell.employeeBranch.text = employee.department?.department_name ?? "N/A"
        cell.employeeRole.text = employee.role?.name ?? "N/A"
        cell.configureStatus(employee.status ?? "Inactive")
        
        cell.configureAvatar(
            profileImageURL: employee.profile_image,
            fullName: fullName,
            loadImageFromURL: loadImageFromURL
        )
        
        let color = getRandomColor()
        cell.employeeRole.backgroundColor = color
        return cell
    }
        
    func getRandomColor() -> UIColor {
        let colors: [UIColor] = [
            .systemRed,
            .systemBlue,
            .systemGreen,
            .systemOrange,
            .systemPurple,
            .systemPink,
            .systemYellow
        ]
        return colors.randomElement() ?? .systemBlue
    }
}

// Mark:- Delegate
extension employeeTab: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEmployee = employeeViewModel.employees[indexPath.row]
        
        isEditMode = true
        isEditTitle = true
        
        let vm = SingleEmployeeInfoVM()
        vm.fetchEmployeeDetails(userId: selectedEmployee.id)
        
        vm.onFetchSuccess = { [weak self] in
            guard let self = self else { return }
            
            self.employeeInfo = vm.employeeData
            
            let infoVc = addEmployeeForm(nibName: "addEmployeeFormViewController", bundle: nil)
            infoVc.isEditMode = true
            infoVc.isEditTitle = true
            infoVc.editEmployeeData = vm.employeeData
            infoVc.isViewOnlyMode = true
            
            infoVc.onEditCompleted = { [weak self] _ in
                self?.employeeViewModel.fetchEmployees()
            }
            
            infoVc.onAddCompleted = { [weak self] _ in
                self?.employeeViewModel.fetchEmployees()
            }
            
            if let topVC = self.newTopViewController(){
                if let navController = topVC.navigationController{
                    navController.pushViewController(infoVc, animated: true)
                    
                }else{
                    topVC.present(infoVc, animated: true, completion: nil)
                }
            }else{
                print("There is some error in the viewDidselect part of the code")
            }
        }

        vm.onFetchFailure = { errorMessage in
            print("❌ Failed to fetch: \(errorMessage)")
        }
    }

}

extension UIView {
    func newTopViewController(controller: UIViewController? = UIApplication.shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {

        if let navigationController = controller as? UINavigationController {
            return newTopViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return newTopViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return newTopViewController(controller: presented)
        }
        return controller
    }
}


