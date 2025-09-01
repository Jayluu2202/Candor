//
//  tabViewController.swift
//  Candor
//
//  Created by mac on 25/07/25.
//

import UIKit

class tabViewController: UITabBarController {
    var userloggedinfile = LoggedInUserVM()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        userloggedinfile.fetchUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let role = UserDefaults.standard.string(forKey: "userRole"),
           var vcs = self.viewControllers {
            
            // Example: Remove tab at index 2 for HR
            if role == "HR", vcs.indices.contains(2) {
                vcs.remove(at: 2)
                self.viewControllers = vcs
            }
            if role == "Accountant", vcs.indices.contains(0){
                vcs.remove(at: 0)
                self.viewControllers = vcs
            }
        }
    }
}
