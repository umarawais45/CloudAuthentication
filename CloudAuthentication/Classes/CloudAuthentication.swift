//
//  File.swift
//  CloudAuthentication
//
//  Created by uMmaRr on 26/02/2022.
//

import Foundation
import Amplify
import AmplifyPlugins
import FirebaseAuth
import GoogleSignIn
import UIKit
import AuthenticationServices

public class CloudAuthentication: NSObject {
    
    private var currentNonce: String?
    private var _googleUser: GIDGoogleUser?
    
    public weak var delegate: CloudAuthenticationDelegate?
    
    //MARK: Initializer
    public override init() {
        super.init()
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
        } catch {
            debugPrint(error)
        }
    }
    
    
    //MARK: Firebase User
    public var firebaseUser: User? {
        get {
            return Auth.auth().currentUser
        }
    }
    
    
    //MARK: Get Firebase Token
    public func getFirebaseToken(_ completion: @escaping ((String?) -> ())) {
        firebaseUser?.getIDToken(completion: { token, err in
            if let err = err { debugPrint(err) }
            completion(token)
        })
    }
    
    
    //MARK: Firebase Anonymous Signin
    public func firebaseSignin_Anonymous(_ completion: @escaping ((Bool) -> ())) {
        Auth.auth().signInAnonymously { result, err in
            if let err = err { debugPrint(err) }
            completion(result?.user != nil)
        }
    }
    
    
    //MARK: Firebase Signin with OAuth Credentials
    public func firebaseSignin_WithCredentials(_ credentials: AuthCredential,_ completion: @escaping((Bool) -> ())) {
        Auth.auth().signIn(with: credentials) { result, err in
            if let err = err { debugPrint(err) }
            completion(result != nil)
        }
    }
    
}






//MARK: Google Signin
extension CloudAuthentication {
    
    public var googleUser: GIDGoogleUser? {
        return _googleUser
    }
    
    public func signinWithGoogle(googleClientID: String, _ completion: @escaping ((Bool, AuthCredential?) -> ())) {
        let configuration = GIDConfiguration(clientID: googleClientID)
        guard let topVC = UIApplication.getTopViewController() else {
            completion(false, nil)
            return
        }
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: topVC) { user, error in
            self._googleUser = user
            DispatchQueue.main.async {
                guard error == nil, let user = user, let idToken = user.authentication.idToken else {
                    completion(false, nil)
                    return
                }
                let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)
                completion(true, credentials)
            }
        }
    }
    
}









//MARK: Apple Signin
extension CloudAuthentication: ASAuthorizationControllerDelegate {
    
    public func signInWithApple() {
        let nonce = Utils.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Utils.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        delegate?.appleSignInDidFail(withError: error)
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            delegate?.appleSignInDidComplete(name: nil, email: nil, OAuthCredential : nil)
            return
        }
        guard let nonce = currentNonce, let appleIDToken = appleIDCredential.identityToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            delegate?.appleSignInDidComplete(name: appleIDCredential.fullName, email: appleIDCredential.email, OAuthCredential : nil)
            return
        }
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        delegate?.appleSignInDidComplete(name: appleIDCredential.fullName, email: appleIDCredential.email, OAuthCredential : credential)
    }
    
}









//MARK: AWS Federated Signin
extension CloudAuthentication {
    
    public func federatedSignin_AWS(with token: String, providerName: String, completion: @escaping ((Bool) -> ())) {
        guard let plugin = try? Amplify.Auth.getPlugin(for: AWSCognitoAuthPlugin().key) as? AWSCognitoAuthPlugin,
           case let .awsMobileClient(client) = plugin.getEscapeHatch() else {
          debugPrint("Failed to fetch escape hatch")
          completion(false)
          return
        }
        client.federatedSignIn(providerName: providerName, token: token) { (userState, error) in
            guard error == nil, let userState = userState else {
                debugPrint("Error in federatedSignIn: \(error!)")
                completion(false)
                return
            }
            debugPrint("Current userState: \(userState)")
            client.getIdentityId().continueWith { task in
                guard task.error == nil, let result = task.result else {
                    debugPrint(task.error ?? "")
                  completion(false)
                  return task
                }
                debugPrint("AWS token is: " + String(result))
                completion(true)
                return task
            }
        }
    }
    
}
