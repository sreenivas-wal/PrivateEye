//
//  UartService.swift
//  MyMobileED
//
//  Created by Admin on 1/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol UartServiceDelegate: class {
    func uartServiceDidDiscoverCharacterictics(_ sender: UartService)
    func uartServiceFailDiscoverCharacterictics(_ sender: UartService)
    func uartService(_ sender: UartService, didUpdate data: Data, for characterictics: CBCharacteristic)
}

class UartService: NSObject, CBPeripheralDelegate {
    
    private static let kUartServiceUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    private static let kTxCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    private static let kRxCharacteristicUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
    private static let MaxCharacters = 20
    
    weak var delegate: UartServiceDelegate?
    var bluetoothPeripheral: BluetoothPeripheral? {
        didSet {
            if bluetoothPeripheral?.peripheral.identifier != oldValue?.peripheral.identifier {
                resetService()
                
                if let peripheral = bluetoothPeripheral {
                    peripheral.peripheral.discoverServices([CBUUID(string: UartService.kUartServiceUUID)])
                }
            }
        }
    }
    
    private var uartService: CBService?
    private var rxCharacteristic: CBCharacteristic?
    private var txCharacteristic: CBCharacteristic?
    private var txWriteType = CBCharacteristicWriteType.withResponse
    var responseData: Data?
    
    init(bluetoothPeripheral: BluetoothPeripheral, delegate: UartServiceDelegate) {
        super.init()
        
        self.delegate = delegate
        self.bluetoothPeripheral = bluetoothPeripheral
        bluetoothPeripheral.peripheral.discoverServices([CBUUID(string: UartService.kUartServiceUUID)])
    }
    
    private func resetService() {
        uartService = nil
        rxCharacteristic = nil
        txCharacteristic = nil
    }
    
    func sendData(_ sendData: Data) {
        let data: NSData = sendData as NSData
        
        if let txCharacteristic = txCharacteristic, let peripheral = bluetoothPeripheral {
            var offset = 0
            
            repeat {
                let chunkSize = min(data.length-offset, UartService.MaxCharacters)
                let chunk = NSData(bytesNoCopy: UnsafeMutableRawPointer(mutating: data.bytes), length: UartService.MaxCharacters, freeWhenDone:false)
                peripheral.peripheral.writeValue(chunk as Data, for: txCharacteristic, type: txWriteType)
                offset += chunkSize
            } while(offset < data.length)
        }
    }
    
    // MARK: CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {

        resetService()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        guard bluetoothPeripheral != nil else {
            return
        }
        
        if uartService == nil {
            if let services = peripheral.services {
                for service in services {
                    if (service.uuid.uuidString.caseInsensitiveCompare(UartService.kUartServiceUUID) == .orderedSame) {
                        self.uartService = service
                        peripheral.discoverCharacteristics([CBUUID(string: UartService.kRxCharacteristicUUID),
                                                            CBUUID(string: UartService.kTxCharacteristicUUID)], for: service)
                        break
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        guard bluetoothPeripheral != nil else {
            return
        }
    
        if let uartService = uartService, rxCharacteristic == nil || txCharacteristic == nil {
            if rxCharacteristic == nil || txCharacteristic == nil {
                if let characteristics = uartService.characteristics {
                    var found = false
                    var index = 0

                    while !found && index < characteristics.count {
                        let characteristic = characteristics[index]
                        
                        if characteristic.uuid.uuidString.caseInsensitiveCompare(UartService.kRxCharacteristicUUID) == .orderedSame {
                            rxCharacteristic = characteristic
                        } else if characteristic.uuid.uuidString.caseInsensitiveCompare(UartService.kTxCharacteristicUUID) == .orderedSame {
                            txCharacteristic = characteristic
                            txWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse
                        }

                        found = rxCharacteristic != nil && txCharacteristic != nil
                        index += 1
                    }
                }
            }
            
            if (rxCharacteristic != nil && txCharacteristic != nil) {
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                delegate?.uartServiceDidDiscoverCharacterictics(self)
            } else {
                delegate?.uartServiceFailDiscoverCharacterictics(self)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard
            bluetoothPeripheral != nil,
            characteristic == rxCharacteristic && characteristic.service == uartService,
            let characteristicDataValue = characteristic.value else {
                return
            }

        responseData = characteristicDataValue
        delegate?.uartService(self, didUpdate: characteristicDataValue, for: characteristic)
    }
}
