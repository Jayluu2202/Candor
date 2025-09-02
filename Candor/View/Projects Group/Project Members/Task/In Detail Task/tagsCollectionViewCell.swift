//
//  tagsCollectionViewCell.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import UIKit

class tagsCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var tagNameLabelOutlet: UILabel!
    @IBOutlet weak var addTagButtonOutlet: UIButton!
    
    lazy var tagTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter tag"
        tf.borderStyle = .roundedRect
        tf.isHidden = true
        tf.delegate = self
        tf.returnKeyType = .done
        tf.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tf)
        
        NSLayoutConstraint.activate([
            tf.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tf.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            tf.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        return tf
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("×", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        button.layer.cornerRadius = 10
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            button.widthAnchor.constraint(equalToConstant: 20),
            button.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return button
    }()
    
    var addTagButtonAction: (() -> Void)?
    var onTagEntered: ((String?) -> Void)?
    var onTagDeleted: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Setup cell appearance
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemBlue.cgColor
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        
        // Initialize delete button
        _ = deleteButton
        
        // Add long press gesture for delete
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
        
        // Configure add tag button
        addTagButtonOutlet.layer.cornerRadius = 8
        addTagButtonOutlet.setTitle("+ Add Tag", for: .normal)
        addTagButtonOutlet.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        addTagButtonOutlet.setTitleColor(.systemBlue, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset all views to default state
        tagNameLabelOutlet.isHidden = false
        addTagButtonOutlet.isHidden = false
        tagTextField.isHidden = true
        deleteButton.isHidden = true
        tagTextField.text = ""
        
        // Reset closures
        addTagButtonAction = nil
        onTagEntered = nil
        onTagDeleted = nil
        
        // Reset styling to default
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 1
        
        // Reset attributed text
        tagNameLabelOutlet.attributedText = nil
        tagNameLabelOutlet.text = ""
        tagNameLabelOutlet.textColor = .label
    }
    
    // MARK: - Configuration Methods
    
    func configureForExistingTag(_ tag: String) {
        // Show tag label, hide add button and text field
        tagNameLabelOutlet.isHidden = false
        addTagButtonOutlet.isHidden = true
        tagTextField.isHidden = true
        deleteButton.isHidden = true
        
        // Set tag text
        tagNameLabelOutlet.text = tag
        
        // Style for existing tags
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 1
        
        // Make text color more prominent
        tagNameLabelOutlet.textColor = UIColor.black
        tagNameLabelOutlet.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        tagNameLabelOutlet.textAlignment = .center
    }
    
    func configureForAddButton() {
        // Show only add button, hide other components
        addTagButtonOutlet.isHidden = false
        tagNameLabelOutlet.isHidden = true
        tagTextField.isHidden = true
        deleteButton.isHidden = true
        
        // Style for add button
        backgroundColor = .clear
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
        
        // Configure add button appearance
        addTagButtonOutlet.setTitleColor(.systemBlue, for: .normal)
        addTagButtonOutlet.backgroundColor = UIColor.clear
        addTagButtonOutlet.setTitle("+ Add Tag", for: .normal)
    }
    
    func showTextField() {
        // Show text field, hide everything else
        tagTextField.isHidden = false
        addTagButtonOutlet.isHidden = true
        tagNameLabelOutlet.isHidden = true
        deleteButton.isHidden = true
        
        // Style for text input mode
        backgroundColor = UIColor.systemBackground
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 2
        
        // Focus the text field
        tagTextField.becomeFirstResponder()
    }
    
    // MARK: - Action Methods
    
    @IBAction func addTagButton(_ sender: UIButton) {
        addTagButtonAction?()
    }
    
    @objc private func deleteButtonTapped() {
        onTagDeleted?()
    }
    
    @objc private func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
        // Only show delete button for existing tags
        if gesture.state == .began &&
           !tagNameLabelOutlet.isHidden &&
           !(tagNameLabelOutlet.text?.isEmpty ?? true) {
            
            deleteButton.isHidden = false
            
            // Hide delete button after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.deleteButton.isHidden = true
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let text = trimmedText, !text.isEmpty {
            onTagEntered?(text)
        } else {
            // If empty, revert to add button state
            configureForAddButton()
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If no text was entered, reset to add button state
        if trimmedText?.isEmpty ?? true {
            DispatchQueue.main.async { [weak self] in
                self?.configureForAddButton()
            }
        } else {
            // If text was entered, trigger the callback
            onTagEntered?(trimmedText)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Ensure proper styling when editing begins
        backgroundColor = UIColor.systemBackground
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 2
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit tag length to reasonable size
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        return newLength <= 30 // Reasonable tag length limit
    }
}
