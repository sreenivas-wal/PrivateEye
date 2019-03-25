//
//  DummyBluetoothManager.swift
//  MyMobileED
//
//  Created by Created by Admin on 22.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class DummyBluetoothManager: BluetoothManagerProtocol {
    
    weak var delegate: BluetoothManagerDelegate?
    
    func startScan() {}
    func stopScan() {}
    
    func connectToPeripheral(_ peripheral: BluetoothPeripheral) {}
    func sendSignalOpen() {}
    func sendSignalClose() {}
    func isConnected() -> Bool { return true }
    func checkConnected(_ peripheral: BluetoothPeripheral) -> Bool { return true }
    func disconnectIfNeeded() {}
}
