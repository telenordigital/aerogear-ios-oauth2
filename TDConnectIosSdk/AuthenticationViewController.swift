//
//  AuthenticationViewController.swift
//  TelenorConnectIosHelloWorld
//
//  Created by Lars Solvoll Tønder on 15/11/2018.
//  Copyright © 2018 Telenor Digital. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {
    
    var callback: ((AnyObject?, NSError?) -> Void)?
    var oauth2Module: OAuth2Module?
    var localizedReasonString: String?
    var cameFrom: UIViewController?
    
    override func viewDidLoad() {
        //Closes the view and calls the callback if there is none, else does nothing
        let callbackWrapper: (AnyObject?, NSError?) -> Void = { token, error in
            //Ugly hack to support using a webview
            //TODO: find a better way of doing this
            DispatchQueue.main.async {
                let currentController = UIApplication.shared.tdcTopViewController
                //Check if you have already been dismissed and have been sent elsewhere
                if (currentController == self.cameFrom) {
                    self.callback?(token, error)
                    return
                }
                self.dismiss(animated: false, completion: {
                    self.callback?(token, error)
                })
                return
            }
        }
        
        //Calls the callbackwrapper unless the user chose to use fallback mechanism for logging in
        let biometricsCallback: (AnyObject?, NSError?) -> Void = { token, error in
            if (error != nil) {
                let laError = error as! LAError
                if ((laError.code) == LAError.userFallback) {
                    AuthenticationHandler.clearUserAndauthenticateWithConnectId(oauth2Module: self.oauth2Module!, callback: callbackWrapper)
                    return
                }
            }
            callbackWrapper(token, error)
        }
        
        AuthenticationHandler.authenticateWithBiometrics(oauth2Module: oauth2Module!, localizedReasonString: self.localizedReasonString!, completion: biometricsCallback)
        
    }
}
