//
//  companyAssetAllocationTab.swift
//  Candor
//
//  Created by mac on 02/09/25.
//

import UIKit

class companyAssetAllocationTab: UIView {

    @IBOutlet weak var logoBGGradientView: UIView!
    @IBOutlet weak var menuButtonOutlet: UIButton!
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if logoBGGradientView != nil && logoBGGradientView.bounds != .zero {
            let color1 = UIColor(named: "color8") ?? UIColor.systemBlue
            let color2 = UIColor(named: "color6") ?? UIColor.systemTeal
            logoBGGradientView.applyGradient(colors: [color1, color2], cornerRadius: 20)
        }
    }

}
