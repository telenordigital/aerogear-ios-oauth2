//
//  HeTokenResponse.swift
//  TDConnectIosSdk
//
//  Created by Serhii Bovtriuk on 19/01/2021.
//

import Foundation

open class HeTokenResponse {
    public private(set) var token: String
    public private(set) var expiration: String
    public private(set) var gifUrl: String
    
    init(token: String, expiration: String, gifUrl: String) {
        self.token = token;
        self.expiration = expiration;
        self.gifUrl = gifUrl;
    }
}
