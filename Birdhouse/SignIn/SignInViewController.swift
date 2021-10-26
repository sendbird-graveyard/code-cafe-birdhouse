//
//  SignInViewController.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/14.
//

import UIKit
import SendBirdCalls
import SendBirdSDK

class SignInViewController: UIViewController {

    @IBOutlet var userIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: userIdTextField.frame.height))
        userIdTextField.leftView = paddingView
        userIdTextField.leftViewMode = .always
    }

    @IBAction func signIn(_ sender: Any) {
        guard let userId = userIdTextField.text else { return }
        // MARK: - Authenticate with Sendbird
        SendBirdCall.authenticate(with: .init(userId: userId)) { _, callError in
            SBDMain.connect(withUserId: userId) { _, chatError in
                guard callError == nil, chatError == nil else { return }
                
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        }
    }
}
