//
//  commentsAndActivityCollectionViewCell.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import UIKit

class commentsAndActivityCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var activityInnerView: UIView!
    @IBOutlet weak var userNameInitials: UILabel!
    @IBOutlet weak var userProfilePhoto: UIImageView!
    @IBOutlet weak var taskUpdateDetails: UILabel!
    @IBOutlet weak var taskUpdateTime: UILabel!
    
    @IBOutlet weak var commentInnerView: UIView!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var userCommentsLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userNameInitialsLabel: UILabel!
    
    // Add date header outlets for activity
    @IBOutlet weak var dateHeaderView: UIView!
    @IBOutlet weak var dateHeaderLabel: UILabel!
    
    // Add these properties at the top of the class
    var onDeleteComment: (() -> Void)?
    var commentId: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        // Setup profile image views to be circular
        userProfilePhoto.layer.cornerRadius = userProfilePhoto.frame.width / 2
        userProfilePhoto.layer.masksToBounds = true
        
        userProfileImage.layer.cornerRadius = userProfileImage.frame.width / 2
        userProfileImage.layer.masksToBounds = true
        
        // Hide date header by default
        dateHeaderView?.isHidden = true
    }

    func configureForComment(_ comment: GetComment) {
        commentInnerView.isHidden = false
        activityInnerView.isHidden = true
        dateHeaderView?.isHidden = true
        
        userNameLabel.text = "\(comment.user.firstName) \(comment.user.lastName)"
        userCommentsLabel.text = comment.message
        commentId = comment.id
        
        // Handle profile image vs initials
        if !comment.user.profileImage.isEmpty {
            userProfileImage.isHidden = false
            userNameInitialsLabel.isHidden = true
            loadImage(from: comment.user.profileImage, into: userProfileImage)
        } else {
            userProfileImage.isHidden = true
            userNameInitialsLabel.isHidden = false
            let initials = "\(comment.user.firstName.prefix(1))\(comment.user.lastName.prefix(1))"
            userNameInitialsLabel.text = initials.uppercased()
        }
        
        // Show/hide delete button based on user permissions
        deleteButtonOutlet.isHidden = false
    }

    // UPDATED: Fixed activity configuration method
    func configureForActivity(_ activity: TaskActivity, showDateHeader: Bool = false, sectionDate: String = "") {
        commentInnerView.isHidden = true
        activityInnerView.isHidden = false
        
        // Show/hide date header
        dateHeaderView?.isHidden = !showDateHeader
        if showDateHeader && !sectionDate.isEmpty {
            dateHeaderLabel?.text = formatSectionDate(sectionDate)
        }
        
        // FIXED: Parse HTML content and create readable text with user name
        let userName = "\(activity.user.firstName) \(activity.user.lastName)"
        let readableActivity = parseActivityLogWithUserName(activity.activityLog, userName: userName)
        taskUpdateDetails.text = readableActivity
        
        // Format the time properly
        taskUpdateTime.text = formatActivityTime(activity.createdAt)
        
        // Handle profile image vs initials for activity
        if !activity.user.profileImage.isEmpty {
            userProfilePhoto.isHidden = false
            userNameInitials.isHidden = true
            loadImage(from: activity.user.profileImage, into: userProfilePhoto)
        } else {
            userProfilePhoto.isHidden = true
            userNameInitials.isHidden = false
            let initials = "\(activity.user.firstName.prefix(1))\(activity.user.lastName.prefix(1))"
            userNameInitials.text = initials.uppercased()
        }
    }

    // MARK: - FIXED Activity Log Parser
    private func parseActivityLogWithUserName(_ htmlContent: String, userName: String) -> String {
        var cleanText = htmlContent
        
        // Remove span tags but keep content
        cleanText = cleanText.replacingOccurrences(of: "<span>", with: "")
        cleanText = cleanText.replacingOccurrences(of: "</span>", with: "")
        
        // Replace strong tags with quotes for better readability
        cleanText = cleanText.replacingOccurrences(of: "<strong>", with: "\"")
        cleanText = cleanText.replacingOccurrences(of: "</strong>", with: "\"")
        
        // Clean up any remaining HTML tags
        cleanText = cleanText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        // Decode HTML entities
        cleanText = cleanText.replacingOccurrences(of: "&lt;", with: "<")
        cleanText = cleanText.replacingOccurrences(of: "&gt;", with: ">")
        cleanText = cleanText.replacingOccurrences(of: "&amp;", with: "&")
        cleanText = cleanText.replacingOccurrences(of: "&quot;", with: "\"")
        cleanText = cleanText.replacingOccurrences(of: "&#39;", with: "'")
        
        // Add user name at the beginning if not already present
        let finalText = "\(userName) \(cleanText)"
        
        return finalText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Date formatting for section headers
    private func formatSectionDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEEE, MMMM dd, yyyy" // e.g., "Thursday, August 29, 2025"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }

    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        
        // Set a placeholder or default image first
        imageView.image = UIImage(systemName: "person.circle.fill")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
                // Make the image circular
                imageView.layer.cornerRadius = imageView.frame.width / 2
                imageView.layer.masksToBounds = true
            }
        }.resume()
    }

    private func formatActivityTime(_ dateString: String) -> String {
        // Handle different date formats from the API
        let inputFormatters = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", // ISO format with milliseconds
            "yyyy-MM-dd HH:mm:ss",          // Standard format
            "yyyy-MM-dd'T'HH:mm:ss'Z'"      // ISO format without milliseconds
        ]
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a" // Just show time for activity items
        
        for inputFormat in inputFormatters {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = inputFormat
            inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
            
            if let date = inputFormatter.date(from: dateString) {
                return outputFormatter.string(from: date)
            }
        }
        
        // If no format matches, return the original string
        return dateString
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        onDeleteComment?()
    }
}
