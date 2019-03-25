//
//  ApplicationAssemblyProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

protocol ApplicationAssemblyProtocol: class {
    var scenesAssembly: ScenesAssembly { get set }
    var servicesAssembly: ServicesAssembly { get set }
}
