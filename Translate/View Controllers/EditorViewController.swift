//
//  EditorViewController.swift
//  Translate
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var bottomTextViewConstraint: NSLayoutConstraint!
    
    
    // MARK: - Properties
    
    var alertCollection: GTAlertCollection!
    
    
    
    // MARK: - Default Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Initialize the alertCollection object that will display different kinds of alerts.
        alertCollection = GTAlertCollection(withHostViewController: self)
        
        // Observe for keyboard notifications.
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Custom Methods
    
    @objc func handleKeyboardWillAppear(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardSize.size.height
            bottomTextViewConstraint.constant = 20.0
            bottomTextViewConstraint.constant += keyboardHeight
        }
    }
    
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardSize.size.height
            bottomTextViewConstraint.constant -= keyboardHeight
        }
    }
 
    
    
    // MARK: - IBAction Methods
    
    @IBAction func detectLanguage(_ sender: Any) {
        if textView.text != "" {
            // Present a "Please wait..." buttonless alert with an activity indicator.
            alertCollection.presentActivityAlert(withTitle: "Detect Language", message: "Please wait while text language is being detected...", activityIndicatorColor: UIColor.blue, showLargeIndicator: false) { (presented) in
                if presented {
                    
                    TranslationManager.shared.detectLanguage(forText: self.textView.text) { (language) in
                        // Dismiss the buttonless alert.
                        self.alertCollection.dismissAlert(completion: nil)
                        
                        if let language = language {
                            // Present an alert with the detected language.
                            self.alertCollection.presentSingleButtonAlert(withTitle: "Detect Language", message: "The following language was detected:\n\n\(language)", buttonTitle: "OK", actionHandler: {
                                
                            })
                            
                        } else {
                            // Present an alert saying that an error occurred.
                            self.alertCollection.presentSingleButtonAlert(withTitle: "Detect Language", message: "Oops! It seems that something went wrong and language cannot be detected.", buttonTitle: "OK", actionHandler: {
                                
                            })
                        }
                    }
                    
                }
            }
            
        }
    }
    
    
    @IBAction func translate(_ sender: Any) {
        if textView.text != "" {
            TranslationManager.shared.textToTranslate = textView.text
            performSegue(withIdentifier: "LanguagesViewControllerSegue", sender: self)
        }
    }
    
    
}

