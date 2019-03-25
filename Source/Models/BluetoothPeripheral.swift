//
//  BluetoothPeripheral.swift
//  MyMobileED
//
//  Created by Admin on 1/16/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothPeripheral: NSObject {

    private static let kUARTServiceUUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    
    var peripheral: CBPeripheral!
    var advertisementData: [String: Any]
    var RSSI: Int
    var name: String {
        get {
            guard peripheral.name != nil else {
                return ""
            }
            
            return peripheral.name!
        }
    }
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], RSSI: Int) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.RSSI = RSSI
    }
    
    func isUartAdvertised() -> Bool {
        var isUartAdvertised = false
        
        if let serviceUUIds = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            isUartAdvertised = serviceUUIds.contains(CBUUID(string: BluetoothPeripheral.kUARTServiceUUID))
        }
        
        return isUartAdvertised
    }
    
    func hasUART() -> Bool {
        var hasUART = false

        if let services = peripheral.services {
            hasUART = services.contains(where: { (service : CBService) -> Bool in
                service.uuid.isEqual(CBUUID(string: BluetoothPeripheral.kUARTServiceUUID))
            })
        }
        
        return hasUART
    }
}
