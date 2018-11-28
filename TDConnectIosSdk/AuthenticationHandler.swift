//
//  BiometricsHandler.swift
//  TDConnectIosSdk
//
//  Created by Lars Solvoll Tønder on 09/11/2018.
//  Copyright © 2018 aerogear. All rights reserved.
//

import LocalAuthentication

public enum BiometricType: String {
    case faceID = "Face Id"
    case touchID = "Touch Id"
    case none = "None"
}

class AuthenticationHandler {
    
    static func getAvailableBiometrics() -> BiometricType {
        let context = LAContext()
        
        var authError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            return BiometricType.none
        }
        if #available(iOS 11.0, *) {
            let type = context.biometryType
            switch type {
            case LABiometryType.faceID:
                return BiometricType.faceID
            case LABiometryType.touchID:
                return BiometricType.touchID
            default:
                return BiometricType.none
            }
        }
        return BiometricType.touchID
        
    }
    
    static func authenticate(viewController: UIViewController, localizedReasonString: String, oauth2Module: OAuth2Module, callback: @escaping (AnyObject?, NSError?) -> Void){
        let bundle = Bundle(for: AuthenticationViewController.self)
        let newViewController = AuthenticationViewController(nibName: "AuthenticationViewController" , bundle: bundle)
        newViewController.callback = callback
        newViewController.oauth2Module = oauth2Module
        newViewController.localizedReasonString = localizedReasonString
        newViewController.cameFrom = viewController
            
        viewController.present(newViewController, animated: true, completion: nil)
        return
    }
    
    static func authenticateWithBiometrics(oauth2Module: OAuth2Module, localizedReasonString: String, completion: @escaping (AnyObject?, NSError?) -> Void){
        let context = LAContext()
        let bundle = Bundle(for: AuthenticationViewController.self)
        
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = NSLocalizedString("cancel", bundle: bundle, comment: "Text to be shown on the cancel button")
        }
        
        context.localizedFallbackTitle = NSLocalizedString("use_connect_id", bundle: bundle, comment: "Text to be shown on the fallback button")
        
        var authError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            completion(nil, authError)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReasonString) { success, evaluateError in
            guard success else {
                completion(nil, evaluateError as! NSError)
                return
            }
            if (oauth2Module.oauth2Session.accessToken != nil && oauth2Module.oauth2Session.tokenIsNotExpired()) {
                // we already have a valid access token, nothing more to be done
                completion(oauth2Module.oauth2Session.accessToken as AnyObject, nil)
            } else if (oauth2Module.oauth2Session.refreshToken != nil && oauth2Module.oauth2Session.refreshTokenIsNotExpired()) {
                // need to refresh token
                oauth2Module.refreshAccessToken(completionHandler: completion)
            }else{
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Tried to authenticate using biometrics but where was no pre-existing access or refresh token"]))

            }
        }
    }
    
    static func clearUserAndauthenticateWithConnectId(oauth2Module: OAuth2Module, callback: @escaping (AnyObject?, NSError?) -> Void){
        if (oauth2Module.oauth2Session.accessToken != nil) {
            signOut(oauth2Module: oauth2Module, callback: {success,error in
                guard error == nil else {
                    callback(nil,error)
                    return
                }
                oauth2Module.requestAuthorizationCode {(accessToken: AnyObject?, error: NSError?) -> Void in
                    guard let accessToken = accessToken else {
                        callback(nil,error)
                        return
                    }
                    callback(accessToken, error)
                    return
                }
            })
            return
        }
        oauth2Module.requestAuthorizationCode(completionHandler: { (accessToken: AnyObject?, error:NSError?) in
            guard let accessToken = accessToken else {
                callback(nil, error)
                return
            }
            callback(accessToken, error)
            return
        })
    }
    
    static func signOut(oauth2Module: OAuth2Module, callback: ((AnyObject?,NSError?) -> Void)?) {
        // having an exclamation mark at the end of callback here is just stupid. Either make the callback
        // a non optional or make revokeAccess accept an optional callback
        oauth2Module.revokeAccess(completionHandler: callback!)
    }
}
