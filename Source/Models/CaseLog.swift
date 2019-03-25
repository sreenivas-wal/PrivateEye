//
//  CaseLog.swift
//  MyMobileED
//
//  Created by Created by Admin on 18.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

func ==(lhs: CaseLog, rhs: CaseLog) -> Bool {
    
    let actionTimestampsAreEqual = lhs.actionTimestamp == rhs.actionTimestamp
    let actionTypesAreEqual = lhs.actionType.toString == rhs.actionType.toString

    var geolocationsAreEqual = false
    if let requiredLhsUID = lhs.geolocation,
       let requiredRhsUID = rhs.geolocation {
        
        geolocationsAreEqual = requiredLhsUID == requiredRhsUID
    }
    else if lhs.geolocation == nil && rhs.geolocation == nil {
        geolocationsAreEqual = true
    }
    
    return actionTimestampsAreEqual && actionTypesAreEqual && geolocationsAreEqual
}

class CaseLog: NSObject, NSCoding {
    
    enum Action {
        case screenShot
        case connectionUnsuccessful
        case connectionUnsecure
        case caseNotConnected
        
        
        var toString: String {
            
            switch self {
            case .screenShot:               return "CaseLog.screenShot"
            case .connectionUnsuccessful:   return "CaseLog.connectionUnsuccessful"
            case .connectionUnsecure:       return "CaseLog.connectionUnsecure"
            case .caseNotConnected:         return "CaseLog.caseNotConnected"
            }
        }
        
        static func from(string: String) -> Action? {
            
            switch string {
            case "CaseLog.screenShot":              return .screenShot
            case "CaseLog.connectionUnsuccessful":  return .connectionUnsuccessful
            case "CaseLog.connectionUnsecure":      return .connectionUnsecure
            case "CaseLog.caseNotConnected":        return .caseNotConnected
            default: return nil
            }
        }
    }

    let geolocation: String?
    let actionTimestamp: String
    let actionType: CaseLog.Action
    
    init(with actionType: Action, actionTimestamp: String, geolocation: String?) {

        self.actionType = actionType
        self.actionTimestamp = actionTimestamp
        self.geolocation = geolocation
    }
    
    // MARK: -
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
    
        let dictionary = NSMutableDictionary(dictionary: [       "actionType" : self.actionType.toString,
                                                            "actionTimestamp" : self.actionTimestamp      ])

        if let requiredGeolocation = self.geolocation {
            dictionary["geolocation"] = requiredGeolocation
        }

        aCoder.encode(dictionary, forKey: NSStringFromClass(CaseLog.self))
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
    
        guard let requiredObjectDictionary = aDecoder.decodeObject(forKey: NSStringFromClass(CaseLog.self)) as? [String : Any],
              let requiredActionTimestamp = requiredObjectDictionary["actionTimestamp"] as? String,
              let requiredActionString = requiredObjectDictionary["actionType"] as? String,
              let requiredAction = Action.from(string: requiredActionString)
        else { return nil }

        var geolocation: String? = nil
        if let requiredGeolocation = requiredObjectDictionary["geolocation"] as? String {
            geolocation = requiredGeolocation
        }

        self.init(with: requiredAction, actionTimestamp: requiredActionTimestamp, geolocation: geolocation)
    }
}
