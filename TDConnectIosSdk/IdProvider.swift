//
//  IdProvider.swift
//  TDConnectIosSdk
//
//  Created by Serhii Bovtriuk on 29/04/2019.
//  Copyright © 2019 aerogear. All rights reserved.
//

import Foundation

public enum IdProvider {
    
    case connectId, telenorId, gpId, dtacId
    
    func getName() -> String {
        switch self {
        case .connectId:
            return "CONNECT";
        case .telenorId:
            return "Telenor ID";
        case .gpId:
            return "GP ID";
        case .dtacId:
            return "DTAC ID";
        }
    }
    
    func getInstantVerificationUrl(useStaging: Bool) -> String {
        switch self {
            case .connectId:
                return useStaging ? "https://connect.staging.telenordigital.com" : "https://connect.telenordigital.com";
            case .telenorId:
                return useStaging ? "https://signin.telenorid-staging.com" : "https://signin.telenorid.com";
            case .gpId:
                return useStaging ? "https://signin.gp-id-staging.com" : "https://signin.gp-id.com";
            case .dtacId:
                return useStaging ? "https://signin.dtac-id-staging.com" : "https://signin.dtac-id.com";
        }
    }
    
    func getUrl(useStaging: Bool) -> String {
        switch self {
            case .connectId:
                return useStaging ? "https://connect.staging.telenordigital.com/oauth" : "https://connect.telenordigital.com/oauth";
            case .telenorId:
                return useStaging ? "https://signin.telenorid-staging.com/oauth" : "https://signin.telenorid.com/oauth";
            case .gpId:
                return useStaging ? "https://signin.gp-id-staging.com/oauth" : "https://signin.gp-id.com/oauth";
            case .dtacId:
                return useStaging ? "https://signin.dtac-id-staging.com/oauth" : "https://signin.dtac-id.com/oauth";
        }
    }
    
}
