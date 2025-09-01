//
//  clientAndLeadsCollectionViewCell.swift
//  Candor
//
//  Created by mac on 01/08/25.
//

import UIKit

class clientAndLeadsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
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
        case "Total Clients":
            symbolName = "building.2.fill"
        case "Total Leads":
            symbolName = "person.2.wave.2.fill"
        case "Open Leads":
            symbolName = "questionmark.circle.fill"
        case "Confirmed Leads":
            symbolName = "checkmark.circle.fill"
        default:
            symbolName = "questionmark.circle"
        }
        
        textImage.image = UIImage(systemName: symbolName)
    }
    
}
