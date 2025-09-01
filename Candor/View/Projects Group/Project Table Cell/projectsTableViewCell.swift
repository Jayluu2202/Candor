//
//  projectsTableViewCell.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import UIKit

class projectsTableViewCell: UITableViewCell {

    var projectID: String?
    var onStatusChange: ((String, String, String) -> Void)?
    
    @IBOutlet weak var changeStatusPullDownOutlet: UIButton!
    @IBOutlet weak var taskAssignedBy: UILabel!
    @IBOutlet weak var statusBGView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var projectStartDate: UILabel!
    @IBOutlet weak var projectDeadLine: UILabel!
    @IBOutlet weak var projectStatus: UILabel!
    @IBOutlet weak var projectName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupStatusMenu()
    }

    private func setupUI() {
        self.backgroundColor = .clear
        
        // Inner view styling
        self.innerView.layer.cornerRadius = 12
        self.innerView.layer.borderWidth = 1
        self.innerView.layer.borderColor = UIColor.black.cgColor
        self.innerView.layer.masksToBounds = true
        
        // Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
        
        // Selection style
        self.selectionStyle = .none
        
        // Status background view
        statusBGView.layer.cornerRadius = 10
        statusBGView.layer.borderWidth = 1
        statusBGView.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func changeStatusButton(_ sender: Any) {
    }
    
    
    
    func setupStatusMenu() {
        let statusOptions = ["In Progress", "On Hold", "Complete", "Cancelled"]
        
        let actions = statusOptions.map { status in
            UIAction(title: status, handler: { [weak self] _ in
                
                guard let self = self,
                      let projectID = self.projectID else {
                          return
                      }
                
                // Get status code
                let statusCode = self.projectStatusChange(status: status)
                
                // Call the callback
                self.onStatusChange?(status, statusCode, projectID)
            })
        }
        
        let menu = UIMenu(title: "Change Status", options: .displayInline, children: actions)
        changeStatusPullDownOutlet.menu = menu
        changeStatusPullDownOutlet.showsMenuAsPrimaryAction = true
    }

    
    func projectStatusChange(status: String) -> String{
        switch status{
        case "On Hold": return "On Hold"
        case "Complete": return "Complete"
        case "Cancelled": return "Cancelled"
        case "In Progress": return "In Progress"
        default: return "Not Started"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        projectID = nil
        onStatusChange = nil
        projectName.text = nil
        projectStatus.text = nil
        projectDeadLine.text = nil
        projectStartDate.text = nil
        taskAssignedBy.text = nil
    }
    
}
