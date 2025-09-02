//
//  subTasksCollectionViewCell.swift
//  Candor
//
//  Created by mac on 29/08/25.
//

import UIKit

class subTasksCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkMarkButtonOutlet: UIButton!
    @IBOutlet weak var addTaskButtonOutlet: UIButton!
    @IBOutlet weak var subTaskNameLabel: UILabel!
    @IBOutlet weak var editCalenderTrashButtonStack: UIStackView!
    
    // Closures for handling actions
    var onAddTaskTapped: (() -> Void)?
    var onCheckmarkTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onCalendarTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Setup cell appearance
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = UIColor.systemBackground
        
        // Setup shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        
        // Configure checkmark button
        checkMarkButtonOutlet.layer.cornerRadius = 12
        checkMarkButtonOutlet.layer.borderWidth = 2
        checkMarkButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
        checkMarkButtonOutlet.clipsToBounds = true
        
        // Configure add task button
        addTaskButtonOutlet.layer.cornerRadius = 8
        addTaskButtonOutlet.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        addTaskButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
        addTaskButtonOutlet.layer.borderWidth = 1
        addTaskButtonOutlet.setTitleColor(.systemBlue, for: .normal)
        addTaskButtonOutlet.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        // Configure subtask label
        subTaskNameLabel.font = UIFont.systemFont(ofSize: 14)
        subTaskNameLabel.numberOfLines = 2
        subTaskNameLabel.lineBreakMode = .byTruncatingTail
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset all closures
        onAddTaskTapped = nil
        onCheckmarkTapped = nil
        onEditTapped = nil
        onDeleteTapped = nil
        onCalendarTapped = nil
        
        // Reset visibility
        checkMarkButtonOutlet.isHidden = false
        addTaskButtonOutlet.isHidden = false
        subTaskNameLabel.isHidden = false
        editCalenderTrashButtonStack.isHidden = false
        
        // Reset state
        checkMarkButtonOutlet.isSelected = false
        updateCheckmarkAppearance(isCompleted: false)
        subTaskNameLabel.text = ""
        subTaskNameLabel.attributedText = nil
        
        // Reset styling
        backgroundColor = UIColor.systemBackground
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
    }
    
    // MARK: - Configuration Methods
    
    func configureForExistingSubTask(_ subTask: InnerSubTaskData) {
        // Show subtask components, hide add button
        checkMarkButtonOutlet.isHidden = false
        subTaskNameLabel.isHidden = false
        editCalenderTrashButtonStack.isHidden = false
        addTaskButtonOutlet.isHidden = true
        
        // Set subtask data
        subTaskNameLabel.text = subTask.title
        updateCheckmarkAppearance(isCompleted: subTask.isCompleted)
        
        // Update cell styling for existing task
        backgroundColor = UIColor.systemBackground
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
        
        // Add subtle background color for completed tasks
        if subTask.isCompleted {
            backgroundColor = UIColor.systemGray6
        }
    }
    
    func configureForAddButton() {
        // Show only add button, hide other components
        addTaskButtonOutlet.isHidden = false
        checkMarkButtonOutlet.isHidden = true
        subTaskNameLabel.isHidden = true
        editCalenderTrashButtonStack.isHidden = true
        
        // Update styling for add button
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 1
        
        // Create dashed border effect (since iOS doesn't have native dashed borders)
//        layer.borderStyle = .solid // Keep solid for now, or implement custom dashed border
        
        // Set add button title and styling
        addTaskButtonOutlet.setTitle("+ Add Sub Task", for: .normal)
        addTaskButtonOutlet.setTitleColor(.systemBlue, for: .normal)
        addTaskButtonOutlet.backgroundColor = UIColor.clear
    }
    
    private func updateCheckmarkAppearance(isCompleted: Bool) {
        checkMarkButtonOutlet.isSelected = isCompleted
        
        if isCompleted {
            // Completed state
            checkMarkButtonOutlet.backgroundColor = UIColor.systemGreen
            checkMarkButtonOutlet.setTitle("✓", for: .normal)
            checkMarkButtonOutlet.setTitleColor(.white, for: .normal)
            checkMarkButtonOutlet.layer.borderColor = UIColor.systemGreen.cgColor
            checkMarkButtonOutlet.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            
            // Strike through text
            if let text = subTaskNameLabel.text {
                let attributedString = NSMutableAttributedString(string: text)
                let range = NSRange(location: 0, length: text.count)
                attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray2, range: range)
                subTaskNameLabel.attributedText = attributedString
            }
        } else {
            // Uncompleted state
            checkMarkButtonOutlet.backgroundColor = UIColor.clear
            checkMarkButtonOutlet.setTitle("", for: .normal)
            checkMarkButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
            
            // Remove strike through
            if let text = subTaskNameLabel.text {
                let attributedString = NSMutableAttributedString(string: text)
                let range = NSRange(location: 0, length: text.count)
                attributedString.removeAttribute(.strikethroughStyle, range: range)
                attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: range)
                subTaskNameLabel.attributedText = attributedString
            }
        }
        
        // Add subtle animation
        UIView.animate(withDuration: 0.2) {
            self.checkMarkButtonOutlet.transform = isCompleted ?
                CGAffineTransform(scaleX: 1.1, y: 1.1) : CGAffineTransform.identity
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.checkMarkButtonOutlet.transform = CGAffineTransform.identity
            }
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func deleteButton(_ sender: UIButton) {
        // Add confirmation haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        onDeleteTapped?()
    }
    
    @IBAction func calenderButton(_ sender: UIButton) {
        onCalendarTapped?()
    }
    
    @IBAction func editSubTaskButton(_ sender: UIButton) {
        onEditTapped?()
    }
    
    @IBAction func checkMarkButton(_ sender: UIButton) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        onCheckmarkTapped?()
    }
    
    @IBAction func addTaskButton(_ sender: UIButton) {
        onAddTaskTapped?()
    }
    
    // MARK: - Helper Methods
    
    func setSubTaskCompleted(_ isCompleted: Bool, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.updateCheckmarkAppearance(isCompleted: isCompleted)
                self.backgroundColor = isCompleted ? UIColor.systemGray6 : UIColor.systemBackground
            }
        } else {
            updateCheckmarkAppearance(isCompleted: isCompleted)
            backgroundColor = isCompleted ? UIColor.systemGray6 : UIColor.systemBackground
        }
    }
}
