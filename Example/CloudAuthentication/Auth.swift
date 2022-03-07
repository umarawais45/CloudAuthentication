//
//  Auth.swift
//  Quick Backup
//
//  Created by uMmaRr on 01/03/2022.
//

import Foundation
import CloudAuthentication

class Auth {
    
    private var _auth: CloudAuthentication!
    
    weak var delegate: CloudAuthenticationDelegate?
    
    static var shared = Auth()
    
    func initialize() {
        _auth = CloudAuthentication()
    }
    
    func firebaseSignIn(completion: @escaping ((Bool) -> Void)) {
        _auth.firebaseSignin_Anonymous { success in
            print("firebase sign in: " + success.description)
            completion(success)
        }
    }
    
    func getFirebaseToken(completion: @escaping ((String?) -> Void)) {
        _auth.getFirebaseToken { token in
            print("firebase token is: " + (token ?? "nil"))
            completion(token)
        }
    }
    
    func awsSignIn(token: String, completion: @escaping ((Bool) -> Void)) {
        _auth.federatedSignin_AWS(with: token, providerName: Constants.awsProviderName) { success in
            print("federated sign in: " + success.description)
            completion(success)
        }
    }
    
    func appleSignIn() {
        _auth.delegate = delegate
        _auth.signInWithApple()
    }
    
    func googleSignIn(completion: @escaping ((Bool) -> Void)) {
        _auth.signinWithGoogle(googleClientID: Constants.googleClientID) { success, credential in
            completion(success)
        }
    }
    
    var isFirebaseLoggedIn: Bool {
        return _auth.firebaseUser != nil
    }
    
}

