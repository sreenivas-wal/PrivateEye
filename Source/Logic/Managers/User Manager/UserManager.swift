//
//  UserManager.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

class UserManager: NSObject {
    
    fileprivate let encryptionPassword = "DataEncryptDecryptPassword"
    
    fileprivate let kUserSessionName = "UserSessionName"
    fileprivate let kUserSessionID = "UserSessionID"
    fileprivate let kUserToken = "UserToken"
    fileprivate let kUserID = "UserID"
    fileprivate let kDoximityID = "DoximityID"
    fileprivate let kUserPassword = "UserPassword"
    fileprivate let kUserHostLink = "UserHostlink"
    fileprivate let kProfile = "Profile"
    fileprivate let kUserRole = "UserRole"
    fileprivate let kEmail = "Email"

    fileprivate let kDoximityUserAccessToken = "DoximityUserAccessToken"
    
    fileprivate let defaults = UserDefaults.standard
    
    var currentUser: User?
    var doximityUser: DoximityUser?
    var hostname: Hostname?
    var profile: Profile?
    
    override init() {
        super.init()
        
        initializeHostDomainLink()
    }
    
    private func initializeHostDomainLink() {
        guard let defaultHostnameData = defaults.data(forKey: kUserHostLink) else { return }
        let hostname = NSKeyedUnarchiver.unarchiveObject(with: defaultHostnameData) as? Hostname
        
        self.hostname = hostname
    }
    
    func retriveUserInfo() -> User? {
        guard let sessionName = defaults.string(forKey: kUserSessionName),
            let sessionID = defaults.string(forKey: kUserSessionID),
            let token = defaults.string(forKey: kUserToken),
            let userID = defaults.string(forKey: kUserID) else { return nil }
        let userRole = defaults.string(forKey: kUserRole)
        let doximityID = defaults.string(forKey: kDoximityID)
        let user = User(sessionName: sessionName, sessionID: sessionID, token: token, userID: userID, doximityID: doximityID, userRole: userRole)        
        return user
    }
    
    func retrieveDoximityUserInfo() -> DoximityUser? {
        guard let doximityAccessToken = defaults.string(forKey: kDoximityUserAccessToken) else { return nil }
        
        let doximityUser = DoximityUser(accessToken: doximityAccessToken)
        
        return doximityUser
    }
}

// MARK: -
// MARK: SessionUserProtocol
extension UserManager : SessionUserProtocol {
    func saveUserInfo(_ user: User) {
        self.currentUser = user
        defaults.set(currentUser?.userRole, forKey: kUserRole)
        defaults.set(currentUser?.sessionName, forKey: kUserSessionName)
        defaults.set(currentUser?.sessionID, forKey: kUserSessionID)
        defaults.set(currentUser?.token, forKey: kUserToken)
        defaults.set(currentUser?.userID, forKey: kUserID)
        defaults.set(currentUser?.doximityID, forKey: kDoximityID)
    }

    func clearUserInfo() {
        defaults.removeObject(forKey: kUserRole)
        defaults.removeObject(forKey: kUserSessionName)
        defaults.removeObject(forKey: kUserSessionID)
        defaults.removeObject(forKey: kUserToken)
        defaults.removeObject(forKey: kUserID)
        defaults.removeObject(forKey: kDoximityID)
        defaults.removeObject(forKey: kProfile)

        self.currentUser = nil
    }
    
    func retrieveUserPassword() -> String? {
        guard let defaultsPassword = defaults.object(forKey: kUserPassword) as? Data else { return nil }
        
        do {
            let decryptPassword = try RNCryptor.decrypt(data: defaultsPassword, withPassword: encryptionPassword)
            
            if let password = String(data: decryptPassword, encoding: .utf8) {
                return password
            }
            
            return nil
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func updateUserPassword(_ password: String) {
        let dataPassword = password.data(using: .utf8)
        let encryptPassword = RNCryptor.encrypt(data: dataPassword!, withPassword: encryptionPassword)
        defaults.set(encryptPassword, forKey: kUserPassword)
    }
    
    func saveDoximityUserInfo(_ user: DoximityUser) {
        self.doximityUser = user
        
        defaults.set(user.accessToken, forKey: kDoximityUserAccessToken)
    }
    
    func saveProfile(_ profile: Profile) {
        self.profile = profile
        
        let encodedProfle = NSKeyedArchiver.archivedData(withRootObject: profile)
        defaults.set(encodedProfle, forKey: kProfile)
    }
    
    func retriveProfile() -> Profile? {
        guard let profileData = defaults.data(forKey: kProfile) else { return nil }
        let profile = NSKeyedUnarchiver.unarchiveObject(with: profileData) as? Profile
        self.profile = profile
        
        return profile
    }
    
    func updateHostDomain(withHostname hostname: Hostname) {
        self.hostname = hostname
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: hostname)
        defaults.set(encodedData, forKey: kUserHostLink)
    }
    
    func saveTouchIDInfo(for email: String, password: String) {
        
        if let dataPassword = password.data(using: .utf8) {
            let encryptPassword = RNCryptor.encrypt(data: dataPassword, withPassword: encryptionPassword)
            defaults.set(encryptPassword, forKey: kUserPassword)
        }

        if let dataEmail = email.data(using: .utf8) {
            let encryptEmail = RNCryptor.encrypt(data: dataEmail, withPassword: encryptionPassword)
            defaults.set(encryptEmail, forKey: kEmail)
        }
    }
    
    func touchIDInfo() -> (email: String, password: String)? {
        
        guard let requiredPassword = self.retrieveUserPassword(),
              let emailData = defaults.object(forKey: kEmail) as? Data,
              let decryptEmail = try? RNCryptor.decrypt(data: emailData, withPassword: encryptionPassword),
              let requiredEmail = String(data: decryptEmail, encoding: .utf8)
         else { return nil }
        
        return (email: requiredEmail, 
             password: requiredPassword)
    }

}

// MARK: -
// MARK: PublicUserProtocol
extension UserManager : PublicUserProtocol {
    func isCurrentUserAuthorized() -> Bool {
        self.currentUser = self.retriveUserInfo()
        self.doximityUser = self.retrieveDoximityUserInfo()
        
        if (currentUser != nil) {
            return true
        }
        
        return false
    }
}
