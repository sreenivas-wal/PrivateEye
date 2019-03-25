//
//  ApplicationAssembly.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

class ApplicationAssembly: NSObject, ApplicationAssemblyProtocol {
    
    lazy var servicesAssembly: ServicesAssembly = {
        return ServicesAssembly()
    }()
    
    lazy var scenesAssembly: ScenesAssembly = {
        return ScenesAssembly(servicesAssembly: self.servicesAssembly)
    }()
}
