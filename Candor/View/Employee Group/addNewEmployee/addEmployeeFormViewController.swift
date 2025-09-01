//
//  addEmployeeForm.swift
//  Candor
//
//  Created by mac on 31/07/25.
//

import UIKit

class addEmployeeForm: UIViewController {
    
    @IBOutlet weak var statusPullDownButtonOutlet: UIButton!
    @IBOutlet weak var initiateExitButtonOutlet: UIButton!
    @IBOutlet weak var disableButtonOutlet: UIButton!
    @IBOutlet weak var newPasswordTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerViewOfScrollView: UIView!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var joiningDateLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var addEmployeeButtonOutlet: UIButton!
    @IBOutlet weak var joiningDatePicker: UIDatePicker!
    @IBOutlet weak var salaryTF: UITextField!
    @IBOutlet weak var branchButtonOutlet: UIButton!
    @IBOutlet weak var departmentButtonOutlet: UIButton!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var officialEmailTF: UITextField!
    @IBOutlet weak var roleButtonOutlet: UIButton!
    @IBOutlet weak var employeeIdTF: UITextField!
    @IBOutlet weak var emergencyNumberTF: UITextField!
    @IBOutlet weak var emergencyContactNameTF: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var personalContactNumberTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    
    var onAddCompleted: ((AddEmployeeRequest) -> Void)?
    var onEditCompleted: ((EditEmployeeRequest) -> Void)?
    
    let viewModelUser = LoggedInUserVM()
    let passwordViewModel = EmployeePasswordVM()
    var currentUserData: LoggedInUserData?
    
    let forgetPassVm = UserForgetPassword()
    
    let addViewModel = addEmployeeVM()
    let editViewModel = EditEmployeeVM()
    let statusViewModel = EmployeeStatusVM()
    
    var editEmployeeData: SingleEmployeeData?
    
    var isEditMode: Bool = false
    var isEditTitle: Bool = false
    var isViewOnlyMode: Bool = false
    var isPasswordChangeMode: Bool = false
    
    var employeeUserID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressViewModifications()
        buttonOutletModifications()
        setupRoleMenu()
        setupDepartmentMenu()
        setupBranchMenu()
        setUpStatus()
        navigationBarTitleNameEdit()
        viewModeFunc()
        addressTextView.delegate = self
        setupBindings()
        fetchUserProfile()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        if isEditMode == false{
            addEmployee()
            
        }else{
            editEmployee()
        }
    }
    
    
    @IBAction func disableButton(_ sender: UIButton) {
    }
    
    @IBAction func initiateExitButton(_ sender: UIButton) {
    }
    
    @IBAction func statusPullDownButton(_ sender: UIButton) {
    }
    
    
    func setupBindings(){
        //user profile fetch bindings
        
        forgetPassVm.onPasswordUpdateSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Success", message: message)
            }
        }
        
        forgetPassVm.onPasswordUpdateFailure = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: errorMessage)
            }
        }
    }
    
    func fetchUserProfile(){
        viewModelUser.fetchUserProfile()
    }
    
    func addEmployee(){
        guard let employeeID = employeeIdTF.text,
              let firstName = firstNameTF.text,
              let lastName = lastNameTF.text,
              let email = officialEmailTF.text,
              let departmentName = departmentButtonOutlet.title(for: .normal),
              let roleName = roleButtonOutlet.title(for: .normal),
              let branchName = branchButtonOutlet.title(for: .normal),
              let contactNumber = personalContactNumberTF.text,
              let emergencyName = emergencyContactNameTF.text,
              let emergencyNumber = emergencyNumberTF.text,
              let address = addressTextView.text, address != "Address"
        else {
            showAlert(title: "Incomplete Form", message: "Please fill out all fields.")
            return
        }
        
        let departmentID = mapDepartmentToID(name: departmentName)
        let roleID = mapRoleToID(name: roleName)
        let branchIDs = [mapBranchToID(name: branchName)]
                
        let birthDateStr = formatDate(birthDatePicker.date)
        let joiningDateStr = formatDate(joiningDatePicker.date)
        
        ///checkmark

        let newEmployee = AddEmployeeRequest(
            employee_id: employeeID,
            first_name: firstName,
            last_name: lastName,
            email: email,
            password: "",
            department_id: departmentID,
            role_id: roleID,
            branch_ids: branchIDs,
            birth_date: birthDateStr,
            joining_date: joiningDateStr,
            contact_number: contactNumber,
            emergency_contact_name: emergencyName,
            emergency_contact_no: emergencyNumber,
            address: address
        )
        
        addViewModel.onSuccess = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self?.onAddCompleted?(newEmployee)
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true)
            }
        }
        
        addViewModel.onError = { error in
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: error)
            }
        }
        
        addViewModel.addEmployee(newEmployee)
    }
    
    func editEmployee(){
        
        guard let employeeID = employeeIdTF.text,
              let firstName = firstNameTF.text,
              let lastName = lastNameTF.text,
              let email = officialEmailTF.text,
              let departmentName = departmentButtonOutlet.title(for: .normal),
              let roleName = roleButtonOutlet.title(for: .normal),
              let branchName = branchButtonOutlet.title(for: .normal),
              let contactNumber = personalContactNumberTF.text,
              let emergencyName = emergencyContactNameTF.text,
              let emergencyNumber = emergencyNumberTF.text,
              let address = addressTextView.text, address != "Address"
        else {
            showAlert(title: "Incomplete Form", message: "Please fill out all fields.")
            return
        }
        
        let departmentID = mapDepartmentToID(name: departmentName)
        let roleID = mapRoleToID(name: roleName)
        let branchIDs = [mapBranchToID(name: branchName)]
                
        let birthDateStr = formatDate(birthDatePicker.date)
        let joiningDateStr = formatDate(joiningDatePicker.date)
        
        guard let userID = editEmployeeData?.id else {
            showAlert(title: "Missing ID", message: "Employee ID is required for update.")
            return
        }
        
        let technologyID = editEmployeeData?.technology_id
        
        let updatedEmployee = EditEmployeeRequest(
            user_id: userID,
            first_name: firstName,
            last_name: lastName,
            birth_date: birthDateStr,
            contact_number: contactNumber,
            emergency_contact_name: emergencyName,
            emergency_contact_no: emergencyNumber,
            address: address,
            department_id: departmentID,
            branch_ids: branchIDs,
            joining_date: joiningDateStr,
            role_id: roleID,
            reporting_person_id: editEmployeeData?.reporting_person_id,
            password: "",
            technology_id: technologyID
        )
        
        editViewModel.editEmployee(updatedEmployee)
        
        editViewModel.onSuccess = { [weak self] message in
            
            DispatchQueue.main.async {
                
                if self?.shouldUpdatePassword() == true {
                    self?.updateEmployeePassword()
                }else{
                    let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self?.onEditCompleted?(updatedEmployee)
                        self?.navigationController?.popViewController(animated: true)
                    }))
                    self?.present(alert, animated: true)
                }
            }
        }
        
        editViewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
    }

    func shouldUpdatePassword() -> Bool {
        let passwordText = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPasswordText = confirmPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return !passwordText.isEmpty || !confirmPasswordText.isEmpty
    }
    
    func updateEmployeePassword(){
        guard validatePasswordFields() else { return }
        
        guard let newPassword = passwordTF.text,
              let selecetedEmployeeUserID = editEmployeeData?.id else{
                  showAlert(title: "Error", message: "Unable to update the password")
                  return
              }
        
        forgetPassVm.updatePassword(userId: String(selecetedEmployeeUserID), newPassword: newPassword)
        
        forgetPassVm.onPasswordUpdateSuccess = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Employee and password updated successfully", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self?.onEditCompleted?(EditEmployeeRequest(
                        user_id: self?.editEmployeeData?.id ?? 0,
                        first_name: self?.firstNameTF.text ?? "",
                        last_name: self?.lastNameTF.text ?? "",
                        birth_date: self?.formatDate(self?.birthDatePicker.date ?? Date()) ?? "",
                        contact_number: self?.personalContactNumberTF.text ?? "",
                        emergency_contact_name: self?.emergencyContactNameTF.text ?? "",
                        emergency_contact_no: self?.emergencyNumberTF.text ?? "",
                        address: self?.addressTextView.text ?? "",
                        department_id: self?.mapDepartmentToID(name: self?.departmentButtonOutlet.title(for: .normal) ?? "") ?? 0,
                        branch_ids: [self?.mapBranchToID(name: self?.branchButtonOutlet.title(for: .normal) ?? "") ?? 0],
                        joining_date: self?.formatDate(self?.joiningDatePicker.date ?? Date()) ?? "",
                        role_id: self?.mapRoleToID(name: self?.roleButtonOutlet.title(for: .normal) ?? "") ?? 0,
                        reporting_person_id: self?.editEmployeeData?.reporting_person_id,
                        password: "",
                        technology_id: self?.editEmployeeData?.technology_id
                    ))
                    self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true)
            }
        }
    }
    
    func validatePasswordFields() -> Bool {
        let passwordText = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPasswordText = confirmPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // If both fields are empty, no password update needed (this is valid)
        if passwordText.isEmpty && confirmPasswordText.isEmpty {
            return false // Don't proceed with password update
        }
        
        // If any field has content, both must be filled
        guard !passwordText.isEmpty else {
            showAlert(title: "Error", message: "Please enter new password")
            return false
        }
        
        guard !confirmPasswordText.isEmpty else {
            showAlert(title: "Error", message: "Please confirm new password")
            return false
        }
        
        guard passwordText == confirmPasswordText else {
            showAlert(title: "Error", message: "New password and confirm password don't match")
            return false
        }
        
        guard passwordText.count >= 6 else {
            showAlert(title: "Error", message: "The new password must be at least 6 characters long")
            return false
        }
        
        return true
    }
    
    func showAlert(title: String = "Notice", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func setupEditForm() {
        guard let emp = editEmployeeData else { return }

        employeeUserID = emp.id
        
        firstNameTF.text = emp.first_name
        lastNameTF.text = emp.last_name
        employeeIdTF.text = emp.employee_id
        officialEmailTF.text = emp.email
        personalContactNumberTF.text = emp.contact_number
        emergencyContactNameTF.text = emp.emergency_contact_name
        emergencyNumberTF.text = emp.emergency_contact_no
        addressTextView.text = emp.address
        birthDatePicker.date = emp.birth_date?.toDate() ?? Date()
        joiningDatePicker.date = emp.joining_date?.toDate() ?? Date()
        
        firstNameTF.textColor = .gray
        lastNameTF.textColor = .gray
        personalContactNumberTF.textColor = .gray
        emergencyContactNameTF.textColor = .gray
        emergencyNumberTF.textColor = .gray
        addressTextView.textColor = .gray
        employeeIdTF.textColor = .gray
        officialEmailTF.textColor = .gray
        
        if let departmentName = emp.department?.department_name {
            departmentButtonOutlet.setTitle(departmentName, for: .normal)
        }
        if let roleName = emp.role?.name {
            roleButtonOutlet.setTitle(roleName, for: .normal)
        }
        if let branchName = emp.user_branches?.first?.branch.branch_name {
            branchButtonOutlet.setTitle(branchName, for: .normal)
        }
        if let statusName = emp.status{
            statusPullDownButtonOutlet.setTitle(statusName, for: .normal)
        }
    }
    
    func viewModeFunc(){
        if isViewOnlyMode {
            self.title = "Employee Info"
            setFormEditable(false)
            setupEditNavButton()
            addEmployeeButtonOutlet.isHidden = true
            hideFieldsforViewOnlyMode()
            
            heightViewConstraint.constant = -120
            view.layoutIfNeeded()
        }
    }
    
    func hideFieldsforViewOnlyMode(){
        
        passwordLabel.isHidden = true
        passwordTF.isHidden = true
        
        confirmPasswordLabel.isHidden = true
        confirmPasswordTF.isHidden = true
        
        salaryLabel.isHidden = true
        salaryTF.isHidden = true
        
        joiningDateLabel.isHidden = true
        joiningDatePicker.isHidden = true
        
        disableButtonOutlet.isHidden = true
        initiateExitButtonOutlet.isHidden = true
        statusPullDownButtonOutlet.isHidden = true
        
    }
    
    func setupEditNavButton() {
        let editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        self.navigationItem.rightBarButtonItem = editBtn
    }

    @objc func editButtonTapped() {
        setFormEditable(true)
        
        isPasswordChangeMode = false
        isViewOnlyMode = false
        
        self.title = "Edit Employee"
        self.navigationItem.rightBarButtonItem = nil
        
        passwordTF.placeholder = "New Password"
        passwordTF.text = ""
        
        confirmPasswordTF.placeholder = "Confirm Password"
        confirmPasswordTF.text = ""
        
        
        addEmployeeButtonOutlet.isHidden = false
        addEmployeeButtonOutlet.setTitle("Update Employee", for: .normal)
        
        editButtonUiChanges()
        
        newPasswordTopConstraint.constant = -50
        heightViewConstraint.constant = 50
        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    func editButtonUiChanges(){
        ///hiding text fields , buttons and all that
        passwordLabel.isHidden = false
        passwordTF.isHidden = false
        
        confirmPasswordLabel.isHidden = false
        confirmPasswordTF.isHidden = false
        
        disableButtonOutlet.isHidden = false
        initiateExitButtonOutlet.isHidden = false
        statusPullDownButtonOutlet.isHidden = false
        
        salaryLabel.isHidden = true
        salaryTF.isHidden = true
        
        joiningDateLabel.isHidden = true
        joiningDatePicker.isHidden = true
        
        ///making the gray text black
        firstNameTF.textColor = .black
        lastNameTF.textColor = .black
        personalContactNumberTF.textColor = .black
        emergencyContactNameTF.textColor = .black
        emergencyNumberTF.textColor = .black
        addressTextView.textColor = .black
        employeeIdTF.textColor = .black
        officialEmailTF.textColor = .black
    }
    
    func setFormEditable(_ isEditable: Bool) {
        [firstNameTF, lastNameTF, personalContactNumberTF,
         emergencyContactNameTF, emergencyNumberTF, officialEmailTF,
         passwordTF, confirmPasswordTF, employeeIdTF, salaryTF, passwordTF, confirmPasswordTF].forEach {
            $0?.isUserInteractionEnabled = isEditable
        }

        addressTextView.isEditable = isEditable
        birthDatePicker.isEnabled = isEditable
        joiningDatePicker.isEnabled = isEditable
        
        departmentButtonOutlet.isUserInteractionEnabled = isEditable
        roleButtonOutlet.isUserInteractionEnabled = isEditable
        branchButtonOutlet.isUserInteractionEnabled = isEditable

        statusPullDownButtonOutlet.isUserInteractionEnabled = isEditable
        
        addEmployeeButtonOutlet.isHidden = !isEditable
    }
    
    func navigationBarTitleNameEdit(){
        if isEditMode == true {
            setupEditForm()
            addEmployeeButtonOutlet.setTitle("Update Employee", for: .normal)
            self.title = "Edit Employee"
            
        } else {
            addEmployeeButtonOutlet.setTitle("Add Employee", for: .normal)
            self.title = "Add Employee"
        }
    }
    
    func buttonOutletModifications(){
        roleButtonOutlet.layer.cornerRadius = 20
        roleButtonOutlet.clipsToBounds = true
        
        departmentButtonOutlet.layer.cornerRadius = 20
        departmentButtonOutlet.clipsToBounds = true
        
        branchButtonOutlet.layer.cornerRadius = 20
        branchButtonOutlet.clipsToBounds = true
        
        addEmployeeButtonOutlet.layer.cornerRadius = 20
        addEmployeeButtonOutlet.clipsToBounds = true
        
        disableButtonOutlet.layer.cornerRadius = 20
        disableButtonOutlet.clipsToBounds = true
        
        initiateExitButtonOutlet.layer.cornerRadius = 20
        initiateExitButtonOutlet.clipsToBounds = true
        
        statusPullDownButtonOutlet.layer.cornerRadius = 20
        statusPullDownButtonOutlet.clipsToBounds = true
    }
    
    func addressViewModifications(){
        addressTextView.delegate = self
        addressTextView.text = "Address"
        addressTextView.textColor = .lightGray
        addressTextView.layer.borderWidth = 1
        addressTextView.layer.borderColor = UIColor.lightGray.cgColor
        addressTextView.layer.cornerRadius = 10
        addressTextView.clipsToBounds = true
    }
    
    func mapDepartmentToID(name: String) -> Int {
        switch name {
        case "Administrative": return 1
        case "Marketing": return 2
        default: return 0
        }
    }
    
    func mapRoleToID(name: String) -> Int {
        switch name {
        case "CFO": return 2
        case "HR": return 3
        case "Admin": return 4
        case "Accountant": return 5
        case "Receptionist": return 6
        case "Nursing": return 7
        case "Embryologist": return 8
        case "RMO": return 9
        case "Center Head": return 10
        case "Center Incharge": return 11
        case "Doctor": return 12
        case "Telecaller": return 13
        case "B2B": return 14
        case "Marketing": return 15
        case "COO": return 16
        default: return 0
        }
    }
    
    func mapBranchToID(name: String) -> Int {
        switch name {
        case "Surat": return 1
        case "Bharuch": return 2
        case "Mahuva": return 3
        case "Jamnagar": return 4
        case "Amreli": return 5
        case "Nandurbar": return 6
        case "Veraval": return 7
        case "Vadodara": return 8
        case "Bhavnagar": return 9
        case "Wadhwan": return 10
        default: return 0
        }
    }
    
    func statusToId(name: String) -> String{
        switch name {
        case "active" : return "active"
        case "inactive" : return "inactive"
        default : return ""
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func setupRoleMenu() {
        let role = ["Nursing", "Telecaller", "Marketing", "Receptionist","Admin", "Doctor", "Accountant", "HR", "Centre Incharge", "Centre Head", "CFO", "COO"]
        
        let roleActions = role.map { roleName in
            UIAction(title: roleName, handler: { [weak self] action in
                self?.roleButtonOutlet.setTitle(roleName, for: .normal)
            })
        }
        let menu = UIMenu(title: "Select Branch", options: .displayInline, children: roleActions)
        
        roleButtonOutlet.menu = menu
        roleButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    func setupDepartmentMenu() {
        let department = ["Administrative", "Marketing"]  // Example data
        
        let departmentActions = department.map { departmentName in
            UIAction(title: departmentName, handler: { [weak self] action in
                self?.departmentButtonOutlet.setTitle(departmentName, for: .normal)

            })
        }
        let menu = UIMenu(title: "Select Branch", options: .displayInline, children: departmentActions)
        
        departmentButtonOutlet.menu = menu
        departmentButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    func setupBranchMenu() {
        let branches = [ "Wadhwan","Veraval","Vadodara", "Surat",  "Nandurbar", "Mahuva", "Jamnagar","Bhavnagar", "Bharuch", "Amreli"]
        
        let branchActions = branches.map { branchName in
            UIAction(title: branchName, handler: { [weak self] action in
                self?.branchButtonOutlet.setTitle(branchName, for: .normal)
            })
        }
        
        let menu = UIMenu(title: "Select Branch", options: .displayInline, children: branchActions)
        
        branchButtonOutlet.menu = menu
        branchButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    func setUpStatus(){
        let status = ["active", "inactive"]
        let statusAction = status.map{ statusName in
            UIAction(title: statusName, handler: {[weak self] action in
                self?.statusPullDownButtonOutlet.setTitle(statusName, for: .normal)
                
                if let userId = self?.editEmployeeData?.id{
                    let request = EmployeeStatusRequest(user_id: "\(userId)", status: statusName)
                    self?.callStatusChangeAPI(request: request)
                }else{
                    self?.showAlert(title: "Error", message: "Missing Employee Id")
                }
            })
        }
        
        let menu = UIMenu(title: "Employee Status", options: .displayInline, children: statusAction)
        statusPullDownButtonOutlet.menu = menu
        statusPullDownButtonOutlet.showsMenuAsPrimaryAction = true
    }
    
    func callStatusChangeAPI(request: EmployeeStatusRequest) {
        statusViewModel.statusChange(request)
    }
}

extension addEmployeeForm: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == addressTextView && addressTextView.text == "Address" {
            addressTextView.text = ""
            addressTextView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == addressTextView && addressTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addressTextView.text = "Address"
            addressTextView.textColor = .lightGray
        }
    }
}


extension String {
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}


