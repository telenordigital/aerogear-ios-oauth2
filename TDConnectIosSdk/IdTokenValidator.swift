//
//  IdTokenValidator.swift
//  Pods
//
//  Created by Jørund Fagerjord on 16/03/16.
//
//

import Foundation

public enum IdTokenValidationError: Error {
    case incorrectIssuer(String)
    case missingIssuer
    case missingAudience(String)
    case untrustedAudiences(String)
    case authorizedPartyMissing(String)
    case authorizedPartyMismatch(String)
    case experationTimeMissing
    case expired(String)
    case missingIssueTime(String)
}

public func validateIdToken(token: [String: AnyObject], expectedIssuer: String, expectedAudience: String, serverTime: Date?) -> IdTokenValidationError? {

    guard let issuer = token["iss"] as? String else {
        return IdTokenValidationError.missingIssuer
    }

    if issuer != expectedIssuer {
        return IdTokenValidationError.incorrectIssuer("Found issuer was: \(issuer)")
    }

    guard let audience = token["aud"] as? [String] else {
        return IdTokenValidationError.missingAudience("ID token audience was nil.")
    }

    if !audience.contains(expectedAudience) {
        return IdTokenValidationError.missingAudience("ID token audience list does not contain the configured client ID.")
    }

    let untrustedAudiences = audience.filter({ (s: String) -> Bool in
        s != expectedAudience
    })
    if untrustedAudiences.count != 0 {
        return IdTokenValidationError.untrustedAudiences("ID token audience list contains untrusted audiences.")
    }

    let authorizedParty: String? = token["azp"] as? String
    if audience.count > 1 && authorizedParty == nil {
        return IdTokenValidationError.authorizedPartyMissing("ID token contains multiple audiences but no azp claim is present.")
    }

    if audience.count > 1 && authorizedParty != expectedAudience {
        return IdTokenValidationError.authorizedPartyMismatch("ID token authorized party is not the configured client ID.")
    }

    guard let experationTime = token["exp"] as? TimeInterval ?? token["exp"]?.doubleValue as TimeInterval? else {
        return IdTokenValidationError.experationTimeMissing
    }

    let expirationDate = Date(timeIntervalSince1970: experationTime)
    if !isValidExpirationTime(expirationDate: expirationDate, serverDate: serverTime) {
        return IdTokenValidationError.expired("ID token has expired.")
    }

    guard let _ = token["iat"] else {
        return IdTokenValidationError.missingIssueTime("ID token is missing the \"iat\" claim.")
    }

    return nil
}

func isValidExpirationTime(expirationDate: Date, serverDate: Date?) -> Bool {
    if expirationDate.timeIntervalSinceNow.sign == FloatingPointSign.plus {
        return true
    }

    guard let serverDate = serverDate else {
        return false
    }

    let expired = expirationDate > serverDate
    return expired
}
