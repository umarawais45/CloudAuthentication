//
//  ViewController.swift
//  CloudAuthentication
//
//  Created by Umar Awais on 03/01/2022.
//  Copyright (c) 2022 Umar Awais. All rights reserved.
//

import UIKit
import CloudAuthentication
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func googleSignIn() {
        Auth.shared.googleSignIn { success in
            let alert = UIAlertController(title: nil
                                          , message: "Google signed in: \(success.description)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func appleSignin() {
        Auth.shared.delegate = self
        Auth.shared.appleSignIn()
    }

    
    @IBAction func firebaseAnonymousSignIn() {
        if !Auth.shared.isFirebaseLoggedIn {
            Auth.shared.firebaseSignIn { success in
                Auth.shared.getFirebaseToken { token in
                    if let token = token {
                        let alert = UIAlertController(title: nil
                                                      , message: "Firebase token: \(token)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        } else {
            Auth.shared.getFirebaseToken { token in
                if let token = token {
                    let alert = UIAlertController(title: "You can use firebase token to signIn in AWS(Federated)."
                                                  , message: "Do you wish to continue?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                        alert.dismiss(animated: true) {
                            Auth.shared.awsSignIn(token: token) { success in
                                let alert = UIAlertController(title: nil
                                                              , message: "AWS Sign in: \(success.description)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                DispatchQueue.main.async {
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    })
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }

}






extension ViewController: CloudAuthenticationDelegate {
    
    func appleSignInDidFail(withError error: Error) {
        print(error)
    }
    
    func appleSignInDidComplete(name: PersonNameComponents?, email: String?, OAuthCredential credential: AuthCredential?) {
        let alert = UIAlertController(title: email
                                      , message: "Apple signed in as: \(name?.givenName ?? "?")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
}
