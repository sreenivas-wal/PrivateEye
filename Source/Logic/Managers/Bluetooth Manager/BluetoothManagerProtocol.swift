//
//  BluetoothManagerProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

protocol BluetoothManagerProtocol: class {
    
    var delegate: BluetoothManagerDelegate? { get set }
    func startScan()
    func stopScan()
    func connectToPeripheral(_ peripheral: BluetoothPeripheral)
    func sendSignalOpen()
    func sendSignalClose()
    func isConnected() -> Bool
    func checkConnected(_ peripheral: BluetoothPeripheral) -> Bool
    func disconnectIfNeeded()
}
