//
//  Hostname.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/16/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

//TODO: Uncomment the below code before app release
#if LIVE
    private let defaultDomainLink = "mymobileerhealthcare.stlouisintegration.com"
#else
    private let defaultDomainLink = "dev.mymobileerhealthcare.stlouisintegration.com"
#endif

private let defaultProtocol = "https"
private let defaultHostnameTitle = "St. Louis Integration"

class Hostname: NSObject, NSCoding {
    
    private let kEncodingDomainLink = "domainLink"
    private let kEcodingProtocolName = "protocolName"
    private let kEncodingTitle = "title"
    
    var domainLink: String?
    var protocolName: String?
    var title: String?
    
    init(domainLink: String, protocolName: String, title: String) {
        self.domainLink = domainLink
        self.protocolName = protocolName
        self.title = title
    }
    
    init?(json: JSON) {
        guard let domainLink = json["hostname"].string else { return }
        guard let title = json["title"].string else { return }
        guard let protocolName = json["protocol"].string else { return }
        self.domainLink = domainLink
        self.protocolName = protocolName
        self.title = title
    }
    
    // MARK: - NSCoding
    
    required init(coder decoder: NSCoder) {
        self.domainLink = decoder.decodeObject(forKey: kEncodingDomainLink) as? String
        self.protocolName = decoder.decodeObject(forKey: kEcodingProtocolName) as? String
        self.title = decoder.decodeObject(forKey: kEncodingTitle) as? String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(domainLink, forKey: kEncodingDomainLink)
        coder.encode(protocolName, forKey: kEcodingProtocolName)
        coder.encode(title, forKey: kEncodingTitle)
    }
    
    // MARK: - Class methods
    
    class func defaultHostname() -> Hostname {
        return Hostname(domainLink: defaultDomainLink, protocolName: defaultProtocol, title: defaultHostnameTitle)
    }
    
    // MARK: - Other
    
    func fullHostDomainLink() -> String {
        return String(format: "%@://%@", protocolName!, domainLink!)
    }
    
    func subdomainName() -> String {
        let baseDomain = "mymobileerhealthcare."
        guard let subdomain = domainLink?.replacingOccurrences(of: baseDomain, with: "") else { return domainLink! }
        
        return subdomain
    }
}
