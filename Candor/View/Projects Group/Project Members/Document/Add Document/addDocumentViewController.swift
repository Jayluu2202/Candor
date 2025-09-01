//
//  addDocumentViewController.swift
//  Candor
//
//  Created by mac on 20/08/25.
//

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

protocol AddDocumentDelegate: AnyObject {
    func documentUploaded()
}

class addDocumentViewController: UIViewController {
    
    @IBOutlet weak var documentLabel: UITextField!
    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var uploadFileButton: UIButton!
    @IBOutlet weak var submitButtonOutlet: UIButton!
    
    
    weak var delegate: AddDocumentDelegate?
    var projectId: Int = 0
    private var selectedFileData: Data?
    private var selectedFileName: String?
    private var selectedFileMimeType: String?
    private let documentVM = DocumentVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDocumentVM()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        innerView.layer.cornerRadius = 15
        innerView.layer.shadowColor = UIColor.black.cgColor
        innerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        innerView.layer.shadowOpacity = 0.25
        innerView.layer.shadowRadius = 8
        
        // Style the close button
        closeButtonOutlet.layer.cornerRadius = closeButtonOutlet.frame.width / 2
        closeButtonOutlet.backgroundColor = UIColor.systemGray5
        
        // Style the upload button
        uploadFileButton.layer.cornerRadius = 8
        uploadFileButton.backgroundColor = UIColor.systemBlue
        uploadFileButton.setTitleColor(.white, for: .normal)
        
        // Style the submit button
        submitButtonOutlet.layer.cornerRadius = 8
        submitButtonOutlet.backgroundColor = UIColor.systemGreen
        submitButtonOutlet.setTitleColor(.white, for: .normal)
        submitButtonOutlet.isEnabled = true
        submitButtonOutlet.alpha = 0.5
        
        // Style the text field
        documentLabel.layer.cornerRadius = 8
        documentLabel.layer.borderWidth = 1
        documentLabel.layer.borderColor = UIColor.systemGray4.cgColor
        documentLabel.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: documentLabel.frame.height))
        documentLabel.leftViewMode = .always
    }
    
    private func setupTextFieldDelegate() {
        documentLabel.delegate = self
        documentLabel.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        updateSubmitButtonState()
    }
    
    private func setupDocumentVM() {
        documentVM.documentUploadSuccess = { [weak self] message in
            DispatchQueue.main.async {
                self?.showSuccessAndDismiss(message: message)
            }
        }
        
        documentVM.documentUploadFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.resetSubmitButton()
                self?.showAlert(title: "Upload Failed", message: error)
            }
        }
    }
    
    private func showSuccessAndDismiss(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.delegate?.documentUploaded()
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func resetSubmitButton() {
        submitButtonOutlet.isEnabled = true
        submitButtonOutlet.setTitle("Submit", for: .normal)
        submitButtonOutlet.backgroundColor = UIColor.systemGreen
        updateSubmitButtonState()
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    
    @IBAction func uploadFileButton(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [
            UTType.pdf,
            UTType.text,
            UTType.rtf,
            UTType.image,
            UTType.movie,
            UTType.audio,
            UTType.data,
            UTType.spreadsheet,
            UTType.presentation
        ])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    
    @IBAction func submitButton(_ sender: UIButton) {
        guard let documentName = documentLabel.text, !documentName.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter a document name")
            return
        }
        
        guard let fileData = selectedFileData,
              let fileName = selectedFileName,
              let mimeType = selectedFileMimeType else {
                  showAlert(title: "No File Selected", message: "Please select a file to upload")
                  return
              }
        
        // Show loading state
        submitButtonOutlet.isEnabled = true
        submitButtonOutlet.setTitle("Uploading...", for: .normal)
        submitButtonOutlet.backgroundColor = UIColor.systemGray3
        
        documentVM.uploadDocument(
            projectId: projectId,
            name: documentName,
            documentData: fileData,
            fileName: fileName,
            mimeType: mimeType
        )
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateSubmitButtonState() {
        let hasFile = selectedFileData != nil
        let hasName = !(documentLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        let shouldEnable = hasFile && hasName && submitButtonOutlet.isEnabled
        
        UIView.animate(withDuration: 0.2) {
            self.submitButtonOutlet.alpha = shouldEnable ? 1.0 : 0.5
        }
        
        if submitButtonOutlet.titleLabel?.text != "Uploading..." {
            submitButtonOutlet.isEnabled = shouldEnable
        }
    }
    
}


// MARK: - UIDocumentPickerDelegate
extension addDocumentViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        // Start accessing security-scoped resource
        guard selectedURL.startAccessingSecurityScopedResource() else {
            showAlert(title: "Access Denied", message: "Cannot access the selected file")
            return
        }
        
        defer {
            selectedURL.stopAccessingSecurityScopedResource()
        }
        
        do {
            selectedFileData = try Data(contentsOf: selectedURL)
            selectedFileName = selectedURL.lastPathComponent
            selectedFileMimeType = getMimeType(for: selectedURL)
            
            // Update UI
            UIView.animate(withDuration: 0.3) {
                
                self.uploadFileButton.setTitle("Change File", for: .normal)
                self.uploadFileButton.backgroundColor = UIColor.systemOrange
            }
            
            updateSubmitButtonState()
            
        } catch {
            showAlert(title: "File Error", message: "Could not read the selected file: \(error.localizedDescription)")
        }
    }
    
    private func getMimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "rtf":
            return "application/rtf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "bmp":
            return "image/bmp"
        case "tiff", "tif":
            return "image/tiff"
        case "mp4":
            return "video/mp4"
        case "mov":
            return "video/quicktime"
        case "avi":
            return "video/x-msvideo"
        case "wmv":
            return "video/x-ms-wmv"
        case "mp3":
            return "audio/mpeg"
        case "wav":
            return "audio/wav"
        case "flac":
            return "audio/flac"
        case "aac":
            return "audio/aac"
        case "zip":
            return "application/zip"
        case "rar":
            return "application/x-rar-compressed"
        case "7z":
            return "application/x-7z-compressed"
        default:
            return "application/octet-stream"
        }
    }
}

// MARK: - UITextFieldDelegate
extension addDocumentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Update button state after the text change
        DispatchQueue.main.async {
            self.updateSubmitButtonState()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
