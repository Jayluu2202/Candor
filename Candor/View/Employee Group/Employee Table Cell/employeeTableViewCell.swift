//
//  employeeTableViewCell.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import UIKit

class employeeTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarLabel: UILabel!
    
    @IBOutlet weak var empIdView: UIView!
    
    @IBOutlet weak var employeeBranch: UILabel!
    
    @IBOutlet weak var employeeRole: UILabel!
    @IBOutlet weak var employeeId: UILabel!
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var employeeStatusLabel: UILabel!

    @IBOutlet weak var innerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        customUiElements()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        avatarLabel.text = ""
        avatarLabel.isHidden = false
        avatarImageView.isHidden = true
    }
    
    func customUiElements(){
        empIdView.layer.cornerRadius = 10
        empIdView.clipsToBounds = true
        
        avatarLabel.layer.cornerRadius = avatarLabel.frame.height/2
        avatarLabel.clipsToBounds = true
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.isHidden = true
        
        employeeRole.layer.cornerRadius = 10
        employeeRole.clipsToBounds = true
        
        // Round corners and add shadow
        self.innerView.layer.cornerRadius = 12
        self.innerView.layer.masksToBounds = true
        self.innerView.layer.borderWidth = 1
        self.innerView.layer.borderColor = UIColor.black.cgColor
        
        // Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarLabel.layer.cornerRadius = avatarLabel.frame.height/2
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
    }
    
    func configureStatus(_ status: String) {
        employeeStatusLabel.text = status.capitalized
        
        if status.lowercased() == "active" {
            employeeStatusLabel.backgroundColor = UIColor.systemGreen
            employeeStatusLabel.textColor = .black
        } else if status.lowercased() == "inactive" {
            employeeStatusLabel.backgroundColor = UIColor.systemRed
            employeeStatusLabel.textColor = .black
        } else {
            employeeStatusLabel.backgroundColor = UIColor.lightGray
            employeeStatusLabel.textColor = .black
        }
        
        employeeStatusLabel.layer.cornerRadius = 8
        employeeStatusLabel.clipsToBounds = true
    }

    
    // MARK: - Avatar Configuration
    func configureAvatar(profileImageURL: String?, fullName: String, loadImageFromURL: @escaping (String, @escaping (UIImage?) -> Void) -> Void) {
        
        // Set initials as default
        let initials = getInitials(from: fullName)
        avatarLabel.text = initials
        avatarLabel.backgroundColor = getRandomColor()
        avatarLabel.isHidden = false
        avatarImageView.isHidden = true
        
        // Try to load profile image if URL is available
        if let imageURL = profileImageURL, !imageURL.isEmpty {
            loadImageFromURL(imageURL) { [weak self] image in
                guard let self = self else { return }
                
                if let image = image {
                    // Show image, hide initials
                    self.avatarImageView.image = image
                    self.avatarImageView.isHidden = false
                    self.avatarLabel.isHidden = true
                } else {
                    // Keep showing initials if image loading failed
                    self.avatarLabel.isHidden = false
                    self.avatarImageView.isHidden = true
                }
            }
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined().uppercased()
    }
    
    private func getRandomColor() -> UIColor {
        let colors: [UIColor] = [
            .systemBlue,
            .systemOrange,
            .systemPurple,
            .systemYellow,
            .systemBrown,
            .systemIndigo
        ]
        return colors.randomElement() ?? .systemBlue
    }
    
}
