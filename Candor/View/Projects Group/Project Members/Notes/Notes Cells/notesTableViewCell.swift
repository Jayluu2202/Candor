//
//  notesTableViewCell.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import UIKit

protocol NoteCellDelegate: AnyObject {
    func editNote(note: NoteData)
    func deleteNote(noteId: Int)
}

class notesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var noteDescriptionLabel: UILabel!
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    
    weak var delegate: NoteCellDelegate?
    private var currentNote: NoteData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpUi(){
        innerView.layer.cornerRadius = 8
        innerView.clipsToBounds = true
        innerView.layer.borderColor = UIColor.black.cgColor
        innerView.layer.borderWidth = 2
    }
    
    func configure(with note: NoteData, serialNumber: Int) {
        currentNote = note
        serialNumberLabel.text = "\(serialNumber)"
        noteTitleLabel.text = note.title
        noteDescriptionLabel.text = note.description
        
        // Optional: Set line limits for description if it's too long
        noteDescriptionLabel.numberOfLines = 2
        noteDescriptionLabel.lineBreakMode = .byTruncatingTail
    }
    
    @IBAction func editButton(_ sender: UIButton) {
        guard let note = currentNote else { return }
        delegate?.editNote(note: note)
    }
    
    @IBAction func deletedButton(_ sender: UIButton) {
        guard let note = currentNote else { return }
        delegate?.deleteNote(noteId: note.id)
    }
    
}
