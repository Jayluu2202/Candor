//
//  documentTableViewCell.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import UIKit

protocol DocumentCellDelegate: AnyObject {
    func deleteDocument(documentId: Int)
}

class documentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var uploadDateLabel: UILabel!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    
    weak var delegate: DocumentCellDelegate?
    var documentId: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        previewImageView.layer.cornerRadius = 8
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        deleteButtonOutlet.tintColor = .red
        
        innerView.layer.cornerRadius = 8
        innerView.clipsToBounds = true
        innerView.layer.borderColor = UIColor.black.cgColor
        innerView.layer.borderWidth = 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with document: DocumentData) {
        imageNameLabel.text = document.name
        
        // Format date
        if let date = formatDate(from: document.createdAt) {
            uploadDateLabel.text = "\(date)"
        } else {
            uploadDateLabel.text = "\(document.createdAt)"
        }
        
        // Set random placeholder image
        setRandomPlaceholderImage()
        
        documentId = document.id
    }
    
    private func formatDate(from dateString: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Important for .000Z
        
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd-MM-yyyy"  // Change to your desired format
            return displayFormatter.string(from: date)
        }
        return nil
    }
    
    private func setRandomPlaceholderImage() {
        let placeholderImages = [
            UIImage(systemName: "doc.fill"),
            UIImage(systemName: "doc.text.fill"),
            UIImage(systemName: "folder.fill"),
            UIImage(systemName: "paperclip"),
            UIImage(systemName: "doc.richtext.fill"),
            UIImage(systemName: "photo.fill"),
            UIImage(systemName: "film.fill"),
            UIImage(systemName: "music.note")
        ]
        
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .systemRed, .systemTeal, .systemIndigo
        ]
        
        let randomImage = placeholderImages.randomElement() ?? UIImage(systemName: "doc.fill")
        let randomColor = colors.randomElement() ?? .systemBlue
        
        previewImageView.image = randomImage
        previewImageView.tintColor = randomColor
        previewImageView.backgroundColor = randomColor.withAlphaComponent(0.1)
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        delegate?.deleteDocument(documentId: documentId)
    }
    
}
