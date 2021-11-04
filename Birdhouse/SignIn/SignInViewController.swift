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
    @IBOutlet var nicknameTextField: UITextField!
    var didSetNickname = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdTextField.addPadding(width: 8)
        nicknameTextField.addPadding(width: 8)
        
        userIdTextField.delegate = self
        nicknameTextField.delegate = self
    }

    @IBAction func signIn(_ sender: Any) {
        guard let userId = userIdTextField.text else { return }
        let nickname = nicknameTextField.text ?? userId
        
        // MARK: - Authenticate with Sendbird
        SendBirdCall.authenticate(with: .init(userId: userId)) { _, callError in
            SBDMain.connect(withUserId: userId) { _, chatError in
                guard callError == nil, chatError == nil else { return }
                
                URLSession.shared.dataTask(with: URL(string: "https://picsum.photos/200")!) { _, response, _ in
                    SBDMain.updateCurrentUserInfo(
                        withNickname: nickname,
                        profileUrl: response?.url?.absoluteString
                    ) { _ in
                        self.performSegue(withIdentifier: "login", sender: nil)
                    }
                }.resume()
            }
        }
    }
    
    @IBAction func userIdTextChanged(_ sender: UITextField) {
        if !didSetNickname {
            nicknameTextField.text = sender.text
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nicknameTextField {
            didSetNickname = true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
