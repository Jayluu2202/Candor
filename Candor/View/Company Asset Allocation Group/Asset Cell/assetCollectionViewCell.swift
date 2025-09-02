//
//  assetCollectionViewCell.swift
//  Candor
//
//  Created by mac on 02/09/25.
//

import UIKit

class assetCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var deviceAllocationStatus: UILabel!
    @IBOutlet weak var deviceLocation: UILabel!
    @IBOutlet weak var deviceAssignedTo: UILabel!
    @IBOutlet weak var systemOS: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var systemDeviceCode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
