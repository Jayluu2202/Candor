//
//  projectCollectionViewCell.swift
//  Candor
//
//  Created by mac on 01/08/25.
//

import UIKit

class projectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    let userInfoViewModel = LoggedInUserVM()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customUiElements()
    }
    
    func customUiElements(){
        bgView.layer.cornerRadius = 10
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.borderWidth = 2
        textImage.tintColor = .label
    }
    func configureCell(title: String, value: Int) {
        textLabel.text = title
        numberLabel.text = "\(value)"
        configureImage(for: title)
    }
    
    private func configureImage(for title: String) {
        let symbolName: String
        
        switch title {
        case "Total Projects":
            symbolName = "square.stack.3d.up"
        case "Completed":
            symbolName = "checkmark.seal.fill"
        case "Running":
            symbolName = "play.circle.fill"
        case "Overdue":
            symbolName = "clock.arrow.circlepath"
        default:
            symbolName = "questionmark.circle"
        }
        
        textImage.image = UIImage(systemName: symbolName)
    }
    
}
