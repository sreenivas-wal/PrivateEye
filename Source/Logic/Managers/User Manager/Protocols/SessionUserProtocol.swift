//
//  UserManagerProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

protocol SessionUserProtocol: class {
    var currentUser: User? { get set }
    var hostname: Hostname? { get }
    var doximityUser: DoximityUser? { get }
    
    func saveUserInfo(_ user: User)
    func clearUserInfo()
    func updateUserPassword(_ password: String)
    func retrieveUserPassword() -> String?
    
    func saveDoximityUserInfo(_ user: DoximityUser)
    
    func saveProfile(_ profile: Profile)
    func retriveProfile() -> Profile?

    func updateHostDomain(withHostname hostname: Hostname)
    func saveTouchIDInfo(for email: String, password: String)
    func touchIDInfo() -> (email: String, password: String)?
}
