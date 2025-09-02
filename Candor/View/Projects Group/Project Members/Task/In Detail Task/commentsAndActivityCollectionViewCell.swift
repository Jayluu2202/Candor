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
    
    
    // NEW: Add outlets for file attachments
    @IBOutlet weak var fileAttachmentsStackView: UIStackView!
    @IBOutlet weak var fileAttachmentsHeightConstraint: NSLayoutConstraint!
    
    // Add these properties at the top of the class
    var onDeleteComment: (() -> Void)?
    var commentId: Int = 0
    var onFileDownload: ((TaskCommFile) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        activityInnerView.layer.cornerRadius = 8
        activityInnerView.layer.borderColor = UIColor.black.cgColor
        activityInnerView.layer.borderWidth = 1
        
        commentInnerView.layer.cornerRadius = 8
        commentInnerView.layer.borderColor = UIColor.black.cgColor
        commentInnerView.layer.borderWidth = 1
    }
    
    private func setupUI() {
        // Setup profile image views to be circular
        userProfilePhoto.layer.cornerRadius = userProfilePhoto.frame.width / 2
        userProfilePhoto.layer.masksToBounds = true
        
        userProfileImage.layer.cornerRadius = userProfileImage.frame.width / 2
        userProfileImage.layer.masksToBounds = true
        
        // Setup file attachments stack view
        fileAttachmentsStackView?.axis = .vertical
        fileAttachmentsStackView?.spacing = 8
        fileAttachmentsStackView?.distribution = .fill
        fileAttachmentsStackView?.alignment = .fill
        fileAttachmentsStackView?.isHidden = true
    }

    func configureForComment(_ comment: GetComment) {
        commentInnerView.isHidden = false
        activityInnerView.isHidden = true
        
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
        
        // NEW: Configure file attachments
        configureFileAttachments(comment.taskCommFiles)
    }

    // NEW: Configure file attachments
    private func configureFileAttachments(_ files: [TaskCommFile]) {
        // Clear existing file views
        fileAttachmentsStackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard !files.isEmpty else {
            fileAttachmentsStackView?.isHidden = true
            fileAttachmentsHeightConstraint?.constant = 0
            return
        }
        
        fileAttachmentsStackView?.isHidden = false
        
        for file in files {
            let fileView = createFileAttachmentView(for: file)
            fileAttachmentsStackView?.addArrangedSubview(fileView)
        }
        
        // Update height constraint based on number of files
        let fileHeight: CGFloat = 44 // Height per file
        let spacing: CGFloat = 8 * CGFloat(max(0, files.count - 1)) // Spacing between files
        fileAttachmentsHeightConstraint?.constant = CGFloat(files.count) * fileHeight + spacing
    }
    
    // NEW: Create individual file attachment view
    private func createFileAttachmentView(for file: TaskCommFile) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // File icon
        let fileIconImageView = UIImageView()
        fileIconImageView.image = getFileIcon(for: file.name)
        fileIconImageView.contentMode = .scaleAspectFit
        fileIconImageView.tintColor = UIColor.systemBlue
        fileIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // File name label
        let fileNameLabel = UILabel()
        fileNameLabel.text = file.name
        fileNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        fileNameLabel.textColor = UIColor.label
        fileNameLabel.numberOfLines = 1
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Download button
        let downloadButton = UIButton(type: .system)
        downloadButton.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        downloadButton.tintColor = UIColor.systemBlue
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add tap gesture to the entire container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fileAttachmentTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.tag = file.id // Store file ID in tag
        
        // Add subviews
        containerView.addSubview(fileIconImageView)
        containerView.addSubview(fileNameLabel)
        containerView.addSubview(downloadButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 44),
            
            fileIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            fileIconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            fileIconImageView.widthAnchor.constraint(equalToConstant: 20),
            fileIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            fileNameLabel.leadingAnchor.constraint(equalTo: fileIconImageView.trailingAnchor, constant: 8),
            fileNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            fileNameLabel.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -8),
            
            downloadButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            downloadButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 24),
            downloadButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return containerView
    }
    
    // NEW: Get appropriate file icon based on file extension
    private func getFileIcon(for fileName: String) -> UIImage? {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "jpg", "jpeg", "png", "gif", "bmp", "tiff":
            return UIImage(systemName: "photo")
        case "pdf":
            return UIImage(systemName: "doc.richtext")
        case "doc", "docx":
            return UIImage(systemName: "doc.text")
        case "xls", "xlsx":
            return UIImage(systemName: "tablecells")
        case "ppt", "pptx":
            return UIImage(systemName: "rectangle.on.rectangle")
        case "txt":
            return UIImage(systemName: "doc.plaintext")
        case "zip", "rar", "7z":
            return UIImage(systemName: "archivebox")
        default:
            return UIImage(systemName: "doc")
        }
    }
    
    // NEW: Handle file attachment tap
    @objc private func fileAttachmentTapped(_ sender: UITapGestureRecognizer) {
        guard let containerView = sender.view,
              let files = getCurrentFiles() else { return }
        
        let fileId = containerView.tag
        if let file = files.first(where: { $0.id == fileId }) {
            onFileDownload?(file)
        }
    }
    
    // NEW: Helper to get current files (you might need to store this in the cell)
    private var currentFiles: [TaskCommFile] = []
    
    private func getCurrentFiles() -> [TaskCommFile]? {
        return currentFiles
    }
    
    // Update configureForComment to store files
    private func storeCurrentFiles(_ files: [TaskCommFile]) {
        currentFiles = files
    }

    // UPDATED: Fixed activity configuration method
    func configureForActivity(_ activity: TaskActivity, showDateHeader: Bool = false, sectionDate: String = "") {
        commentInnerView.isHidden = true
        activityInnerView.isHidden = false
        
        // Hide file attachments for activity
        fileAttachmentsStackView?.isHidden = true
        fileAttachmentsHeightConstraint?.constant = 0
        
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
