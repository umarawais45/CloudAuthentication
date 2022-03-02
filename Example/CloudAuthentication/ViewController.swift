//
//  ViewController.swift
//  CloudAuthentication
//
//  Created by Umar Awais on 03/01/2022.
//  Copyright (c) 2022 Umar Awais. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        if !Auth.shared.isFirebaseLoggedIn {
            Auth.shared.firebaseSignIn { success in
                Auth.shared.getFirebaseToken { token in
                    if let token = token {
                        Auth.shared.awsSignIn(token: token) { success in
                            
                        }
                    }
                }
            }
        } else {
            Auth.shared.getFirebaseToken { token in
                if let token = token {
                    Auth.shared.awsSignIn(token: token) { success in
                        
                    }
                }
            }
        }
    }

}

