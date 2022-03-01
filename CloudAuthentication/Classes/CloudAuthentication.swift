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

public class CloudAuthentication {
    
    public init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
        } catch {
            debugPrint(error)
        }
    }
    
    public var firebaseUser: User? {
        get {
            return Auth.auth().currentUser
        }
    }
    
    public func getFirebaseToken(_ completion: @escaping ((String?) -> ())) {
        firebaseUser?.getIDToken(completion: { token, err in
            if let err = err { debugPrint(err) }
            completion(token)
        })
    }
    
    public func firebaseSignin_Anonymous(_ completion: @escaping ((Bool) -> ())) {
        Auth.auth().signInAnonymously { result, err in
            if let err = err { debugPrint(err) }
            completion(result?.user != nil)
        }
    }
    
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

