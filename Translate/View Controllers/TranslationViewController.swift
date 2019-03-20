//
//  TranslationViewController.swift
//  Translate
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class TranslationViewController: UIViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var textView: UITextView!
    
    
    // MARK: - Properties
    
    var alertCollection: GTAlertCollection!
    
    
    
    // MARK: - Default Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        alertCollection = GTAlertCollection(withHostViewController: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        textView.text = ""
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initiateTranslation()
    }
    
    
    deinit {
        alertCollection = nil
    }
    
    
    
    // MARK: - Custom Methods
    
    func initiateTranslation() {
        // Present a "Please wait..." alert.
        alertCollection.presentActivityAlert(withTitle: "Translation", message: "Your text is being translated...") { (presented) in
            if presented {
                
                TranslationManager.shared.translate(completion: { (translation) in
                    
                    // Dismiss the buttonless alert.
                    self.alertCollection.dismissAlert(completion: nil)
                    
                    if let translation = translation {
                        
                        DispatchQueue.main.async { [unowned self] in
                            self.textView.text = translation
                        }
                        
                    } else {
                        self.alertCollection.presentSingleButtonAlert(withTitle: "Translation", message: "Oops! It seems that something went wrong and translation cannot be done.", buttonTitle: "OK", actionHandler: {
                            
                        })
                    }
                    
                })
                
            }
        }
    }
    
    
}
