//
//  mainViewController.swift
//  Candor
//
//  Created by mac on 24/07/25.
//

import UIKit

class mainViewController: UIViewController {
    
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var sideMenuUserProfileImage: UIImageView!
    @IBOutlet weak var projectsTab: UITabBarItem!
    @IBOutlet weak var dashboardTab: UITabBarItem!
    @IBOutlet weak var employeeTab: UITabBarItem!
    @IBOutlet weak var sideMenuUserNameAvatarInitials: UILabel!
    @IBOutlet weak var sideMenuRole: UILabel!
    @IBOutlet weak var sideMenuEmailID: UILabel!
    @IBOutlet weak var sideMenuEMPID: UILabel!
    @IBOutlet weak var sideMenuName: UILabel!
    @IBOutlet var mainBGView: UIView!
    @IBOutlet weak var logoutButtonOutlet: UIButton!
    @IBOutlet weak var sideMenuMainView: UIView!
    @IBOutlet weak var constraintToShowTheSideMenu: NSLayoutConstraint!
    @IBOutlet weak var viewWithAllComponents: UIView!
    
    let viewModel = UserLoginFile()
    let viewModelUser = LoggedInUserVM()
    let empViewModel = EmployeeListVM()
    
    var tapGesture: UITapGestureRecognizer?
    
    private var cachedUserData: LoggedInUserData?
    private var cachedProfileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuModifications()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimissSideMenu))
        if let tapGesture = tapGesture {
            tapGesture.isEnabled = false
            mainBGView.addGestureRecognizer(tapGesture)
        }
        editButtonOutlet.layer.cornerRadius = 10
        logoutButtonOutlet.layer.cornerRadius = 10
        
        preloadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        styleAvatarInitialsLabel()
        styleProfileImageView()
        styleCircularLevitatingLabel(sideMenuName)
        styleCircularLevitatingLabel(sideMenuEmailID)
        styleCircularLevitatingLabel(sideMenuEMPID)
        applyGradientToAvatarLabel()
    }
    
    
    @objc func dimissSideMenu(){
        constraintToShowTheSideMenu.constant = -310
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        viewWithAllComponents.alpha = 1.0
        tapGesture?.isEnabled = false
    }
    
    @IBAction func editButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "editUserViewController") as! editUserViewController
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "token")
        cachedUserData = nil
        cachedProfileImage = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuButton(_ sender: UIButton) {
        sideMenuMainView.isHidden = false
        constraintToShowTheSideMenu.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        viewWithAllComponents.alpha = 0.6
        tapGesture?.isEnabled = true
        
        if let userData = cachedUserData {
            displayUserData(userData)
        } else {
            fetchLoggedInUserDetails()
        }
    }
    
    private func preloadUserData() {
        viewModelUser.fetchUserProfile()
        
        viewModelUser.onProfileFetchSuccess = { [weak self] userData in
            guard let self = self else { return }
            
            // ✅ IMPORTANT: Cache the user data
            self.cachedUserData = userData
        }
        
        viewModelUser.onProfileFetchFailure = { errorMessage in
            print("🚫 Failed to preload user profile: \(errorMessage)")
        }
    }
    
    private func fetchLoggedInUserDetails() {
        guard cachedUserData == nil else {
            displayUserData(cachedUserData!)
            return
        }
        
        viewModelUser.fetchUserProfile()
        
        viewModelUser.onProfileFetchSuccess = { [weak self] userData in
            guard let self = self else { return }
            
            self.cachedUserData = userData
            
            DispatchQueue.main.async {
                self.displayUserData(userData)
            }
        }
        
        viewModelUser.onProfileFetchFailure = { errorMessage in
            print("🚫 Failed to fetch user: \(errorMessage)")
        }
    }
    
    
    private func displayUserData(_ userData: LoggedInUserData) {
        let fullName = "\(userData.first_name) \(userData.last_name)"
        sideMenuName.text = fullName
        sideMenuEmailID.text = userData.email
        sideMenuRole.text = userData.role.name
        sideMenuEMPID.text = "\(userData.id)"
        
        configureSideMenuAvatar(
            profileImageURL: userData.profile_image,
            fullName: fullName
        )
    }
    
    // MARK: - Avatar Configuration (matching employeeTab style)
    func configureSideMenuAvatar(profileImageURL: String?, fullName: String) {
        
        let initials = getInitials(from: fullName)
        sideMenuUserNameAvatarInitials.text = initials
        sideMenuUserNameAvatarInitials.isHidden = false
        sideMenuUserProfileImage.isHidden = true
                        
        if let imageURL = profileImageURL, !imageURL.isEmpty {
            loadImageFromURL(imageURL) { [weak self] image in
                guard let self = self else { return }
                
                if let image = image {
                    self.sideMenuUserProfileImage.image = image
                    self.sideMenuUserProfileImage.isHidden = false
                    self.sideMenuUserNameAvatarInitials.isHidden = true
                    
                    if let gradientView = self.sideMenuUserNameAvatarInitials.superview?.viewWithTag(999) {
                        gradientView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func loadImageFromURL(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        var finalURLString = urlString
        if urlString.hasPrefix("/") {
            finalURLString = "\(APIEndpoints.baseURL)\(urlString)"
        }
        
        guard let url = URL(string: finalURLString) else {
            print("❌ Invalid URL: \(finalURLString)")
            completion(nil)
            return
        }
        
        print("🔄 Loading image from: \(finalURLString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Image loading error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to create image from data")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined().uppercased()
    }
    
    func styleAvatarInitialsLabel() {
        sideMenuUserNameAvatarInitials.layer.cornerRadius = sideMenuUserNameAvatarInitials.frame.height / 2
        sideMenuUserNameAvatarInitials.clipsToBounds = true
        sideMenuUserNameAvatarInitials.layer.borderWidth = 2
        sideMenuUserNameAvatarInitials.layer.borderColor = UIColor.black.cgColor
        sideMenuUserNameAvatarInitials.textColor = .white
        sideMenuUserNameAvatarInitials.textAlignment = .center
        sideMenuUserNameAvatarInitials.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    func styleProfileImageView() {
        sideMenuUserProfileImage.layer.cornerRadius = sideMenuUserProfileImage.frame.height / 2
        sideMenuUserProfileImage.clipsToBounds = true
        sideMenuUserProfileImage.contentMode = .scaleAspectFill
        sideMenuUserProfileImage.layer.borderWidth = 2
        sideMenuUserProfileImage.layer.borderColor = UIColor.black.cgColor
        sideMenuUserProfileImage.isHidden = true // Initially hidden
    }
    
    func applyGradientToAvatarLabel() {
        if let oldGradientView = sideMenuUserNameAvatarInitials.superview?.viewWithTag(999) {
            oldGradientView.removeFromSuperview()
        }
        // Create the gradient layer
        let gradientView = UIView(frame: sideMenuUserNameAvatarInitials.frame)
        gradientView.tag = 999
        gradientView.layer.cornerRadius = sideMenuUserNameAvatarInitials.frame.height / 2
        gradientView.clipsToBounds = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = gradientView.layer.cornerRadius
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Insert behind the label
        sideMenuUserNameAvatarInitials.superview?.insertSubview(gradientView, belowSubview: sideMenuUserNameAvatarInitials)
    }
    
    func styleCircularLevitatingLabel(_ label: UILabel) {
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.layer.borderWidth = 1.5
        label.layer.borderColor = UIColor.black.cgColor
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowRadius = 5
        
        label.backgroundColor = .white
        
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    func sideMenuModifications(){
        sideMenuMainView.layer.cornerRadius = 10
        sideMenuMainView.clipsToBounds = true
    }
}

extension UIView {
    func applyGradient(colors: [UIColor], cornerRadius: CGFloat = 0.0) {
    
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = cornerRadius
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
