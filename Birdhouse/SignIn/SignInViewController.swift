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

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signIn(_ sender: Any) {
        guard let userId = userIdTextField.text else { return }
        SendBirdCall.authenticate(with: .init(userId: userId)) { callUser, callError in
            SBDMain.connect(withUserId: userId) { chatUser, chatError in
                guard let callUser = callUser, callError == nil else { return }
                guard let chatUser = chatUser, chatError == nil else { return }
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
