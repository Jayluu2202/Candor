//
//  addNoteViewController.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import UIKit

protocol AddNoteDelegate: AnyObject {
    func noteAdded()
}

class addNoteViewController: UIViewController {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: AddNoteDelegate?
    var projectId: Int = 0
    var noteToEdit: NoteData?
    
    private let noteViewModel = NoteVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNoteVM()
        setupForEditing()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerPopup()
    }
    
    private func setupForEditing() {
        if let note = noteToEdit {
            // We're editing an existing note
            titleLabel.text = "Edit Note"
            saveButton.setTitle("Update", for: .normal)
            titleTextField.text = note.title
            descriptionTextView.text = note.description
        } else {
            // We're adding a new note
            titleLabel.text = "Add Note"
            saveButton.setTitle("Save", for: .normal)
        }
    }
    
    private func setupNoteVM() {
        noteViewModel.noteAddSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.dismiss(animated: true) {
                    self?.delegate?.noteAdded()
                }
            }
        }
        
        noteViewModel.noteAddFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: error)
            }
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else {
                  showAlert(title: "Error", message: "Please fill in all fields")
                  return
              }
        
        if let noteToEdit = noteToEdit {
            // Update existing note
            let updateRequest = UpdateNoteRequest(
                project_note_id: noteToEdit.id,
                title: title,
                description: description
            )
            noteViewModel.updateNote(request: updateRequest)
        } else {
            // Add new note
            let addRequest = AddNoteRequest(
                project_id: projectId,
                title: title,
                description: description
            )
            noteViewModel.addNewNote(request: addRequest)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        innerView.layer.cornerRadius = 12
        innerView.clipsToBounds = true
        
        // Setup text view border
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 8
        
        // Setup text field
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.cornerRadius = 8
        
        // Add padding to text field
        titleTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: titleTextField.frame.height))
        titleTextField.leftViewMode = .always
    }
    
    private func centerPopup() {
        // Force popup size
        let popupWidth: CGFloat = 300
        let popupHeight: CGFloat = 300
        
        innerView.frame = CGRect(
            x: (view.bounds.width - popupWidth) / 2,
            y: (view.bounds.height - popupHeight) / 2,
            width: popupWidth,
            height: popupHeight
        )
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
