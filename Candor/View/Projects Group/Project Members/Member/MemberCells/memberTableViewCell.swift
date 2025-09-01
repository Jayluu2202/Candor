//
//  memberTableViewCell.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import UIKit

protocol MemberCellDelegate: AnyObject {
    func removeMember(userId: Int)
}

class memberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var removeButtonOutlet: UIButton!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: MemberCellDelegate?
    private var userId: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI() {
        // Style the remove button
        removeButtonOutlet.layer.cornerRadius = 8
        removeButtonOutlet.backgroundColor = UIColor.systemRed
        removeButtonOutlet.setTitleColor(.black, for: .normal)
        removeButtonOutlet.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        
        innerView.layer.cornerRadius = 8
        innerView.clipsToBounds = true
        innerView.layer.borderColor = UIColor.black.cgColor
        innerView.layer.borderWidth = 2
    }
    
    func configure(with member: ProjectMember) {
        let user = member.user
        
        // Set name - use name if available, otherwise combine first and last name
        if let fullName = user.name, !fullName.isEmpty {
            nameLabel.text = fullName
        } else {
            nameLabel.text = "\(user.firstName) \(user.lastName)"
        }
        
        // Set role
        roleLabel.text = user.role.name
        
        // Store user ID for removal
        userId = user.id
        
        // Configure button appearance based on member status
        removeButtonOutlet.isEnabled = member.isActive
        removeButtonOutlet.alpha = member.isActive ? 1.0 : 0.5
        
        // Set button title
        removeButtonOutlet.setTitle("Remove", for: .normal)
    }
    
    @IBAction func removeButton(_ sender: Any) {
        guard let userId = userId else { return }
        delegate?.removeMember(userId: userId)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        roleLabel.text = nil
        userId = nil
        delegate = nil
    }
    
}
