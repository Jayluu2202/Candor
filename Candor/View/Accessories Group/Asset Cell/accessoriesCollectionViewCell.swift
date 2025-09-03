//
//  accessoriesCollectionViewCell.swift
//  Candor
//
//  Created by mac on 02/09/25.
//

import UIKit

class accessoriesCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var deviceAllocationStatusLabel: UILabel!
    @IBOutlet weak var deviceLocationLabel: UILabel!
    @IBOutlet weak var deviceAssignedToLabel: UILabel!
    @IBOutlet weak var systemOSLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var systemDeviceCodeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
