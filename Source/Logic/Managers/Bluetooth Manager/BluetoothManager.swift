//
//  BluetoothManager.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation
import CoreBluetooth

enum CaseResponseStatus: String {
    case connected = "phone detected"
    case disconnected = "phone not detected"

    static let allValues: [CaseResponseStatus] = [.connected, .disconnected]
}

@objc protocol BluetoothManagerDelegate: class {
    @objc optional func didDiscoverPeripherals(_ peripherals: [String : BluetoothPeripheral])
    @objc optional func didConnectPeripheral(_ peripheral: BluetoothPeripheral)
    @objc optional func didDisconnectPeripheral(_ peripheral: BluetoothPeripheral)
    @objc optional func successConnection()
    @objc optional func failureConnection()
    @objc optional func unsecureConnection()
}

class BluetoothManager: NSObject, BluetoothManagerProtocol, UartServiceDelegate, CBCentralManagerDelegate {
    
    private let connectionTimeOut: TimeInterval = 60
    private let pingTimeInterval: TimeInterval = 2

    enum Signals: String {
        case on = "On"
        case off = "Off"
        case ping = "Check"
    }
    
    var centralManager: CBCentralManager?
    weak var delegate: BluetoothManagerDelegate?

    var peripherals = [String : BluetoothPeripheral]()
    var connectedPeripheral: BluetoothPeripheral? {
        didSet {
            if let peripheral = connectedPeripheral {
                self.uartService = UartService(bluetoothPeripheral: peripheral, delegate: self)
            }
        }
    }
    
    private var pingTimer: Timer?
    private var connectionTimer: Timer?
    private var successBlock: (() -> ())?
    private var failureBlock: (() -> ())?
    private var uartService: UartService?
    private var connectingPeripheral: BluetoothPeripheral?
    private var responseData: Data?

    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - BluetoothManagerProtocol
    
    func startScan() {
        guard centralManager?.state != .poweredOff && centralManager?.state != .unauthorized && centralManager?.state != .unsupported else {
            self.delegate?.failureConnection?()
            
            return
        }
        
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager?.stopScan()

        if connectionTimer != nil {
            stopConnectionTimer()
            
            if connectingPeripheral != nil {
                centralManager?.cancelPeripheralConnection(connectingPeripheral!.peripheral)
                connectingPeripheral = nil
            }
        }
    }

    func disconnectIfNeeded() {
        if connectedPeripheral != nil {
            centralManager?.cancelPeripheralConnection(connectedPeripheral!.peripheral)
        }
    }
    
    // MARK: Connection to peripheral
    
    func connectToPeripheral(_ peripheral: BluetoothPeripheral) {
        stopScan()
        
        if centralManager?.state == .poweredOn {
            centralManager?.connect(peripheral.peripheral, options: nil)
            
            if connectingPeripheral != nil {
                centralManager?.cancelPeripheralConnection(connectingPeripheral!.peripheral)
                
                if peripheral.peripheral.identifier != connectingPeripheral?.peripheral.identifier {
                    delegate?.didDisconnectPeripheral?(connectingPeripheral!)
                }
            }
            
            startConnectionTimer()
            connectingPeripheral = peripheral
        } else {
            self.delegate?.failureConnection?()
            self.delegate?.didDisconnectPeripheral?(peripheral)
        }
    }
    
    func startConnectionTimer() {
        connectionTimer = Timer.scheduledTimer(timeInterval: connectionTimeOut,
                                               target: self,
                                               selector: #selector(handleConnectionTimer(_:)), userInfo: nil, repeats: false)
    }
    
    func stopConnectionTimer() {
        connectionTimer?.invalidate()
        connectionTimer = nil
    }
    
    func handleConnectionTimer(_ timer: Timer) {
        if let currentPeripheral = connectingPeripheral {
            self.centralManager?.cancelPeripheralConnection(currentPeripheral.peripheral)
            self.delegate?.didDisconnectPeripheral?(currentPeripheral)
            self.delegate?.failureConnection?()
            connectingPeripheral = nil
        }
        
        stopConnectionTimer()
    }
    
    func disconnectFromPeripheral(_ peripheral: BluetoothPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral.peripheral)
    }
    
    // MARK: Shutter signals
    
    func sendSignalOpen() {
        let on = Signals.on
        sendSignal(on.rawValue)
    }

    func sendSignalClose() {
        let off = Signals.off
        sendSignal(off.rawValue)
    }
    
    // MARK: Check connection
    
    func checkConnected(_ peripheral: BluetoothPeripheral) -> Bool {
        if peripheral.peripheral.identifier == connectedPeripheral?.peripheral.identifier {
            return true
        }
        
        return false
    }
    
    func isConnected() -> Bool {
        return (connectedPeripheral?.peripheral.state == .connected)
    }
    
    // MARK: Ping case 
    
    func startPingDevice() {
        sendPingSignal()
        startPingTimer()
    }
    
    func stopPingDevice() {
        stopPingTimer()
    }
    
    private func startPingTimer() {
        pingTimer = Timer.scheduledTimer(timeInterval: pingTimeInterval, target: self, selector: #selector(handlePingTimer(_:)), userInfo: nil, repeats: true)
    }
    
    func handlePingTimer(_ timer: Timer) {
        if let response = responseData, let responseString = String(data: response, encoding: .utf8) {
            CaseResponseStatus.allValues.forEach {
                if responseString.lowercased().contains($0.rawValue) {
                    switch $0 {
                    case .connected: sendPingSignal()
                    case .disconnected: disconnectCurrentPeripheral()
                    }
                }
            }
        } else {
            disconnectCurrentPeripheral()
        }

        responseData = nil
    }

    private func disconnectCurrentPeripheral() {
        if let peripheral = connectedPeripheral?.peripheral {
            self.centralManager?.cancelPeripheralConnection(peripheral)
        }

        stopPingTimer()
        self.delegate?.unsecureConnection?()
        print("Failure timer response")
    }

    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func sendPingSignal() {
        responseData = nil
        uartService?.responseData = nil

        let ping = Signals.ping
        sendSignal(ping.rawValue)
    }
    
    // MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Centra manager state = \(central.state.rawValue)")

        if (central.state == .poweredOn) {
            self.delegate?.successConnection?()
            startScan()
        } else {
            self.stopPingTimer()
            self.delegate?.failureConnection?()
            
            if let peripheral = connectedPeripheral {
                delegate?.didDisconnectPeripheral?(peripheral)
                connectedPeripheral?.peripheral.delegate = nil
                connectedPeripheral = nil
                disconnectFromPeripheral(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        stopPingTimer()
        stopConnectionTimer()
        connectingPeripheral = nil
        
        if let connected = self.connectedPeripheral {
            delegate?.didDisconnectPeripheral?(connected)
        }

        let identifier = peripheral.identifier.uuidString
        connectedPeripheral = self.peripherals[identifier]
        connectedPeripheral?.peripheral.delegate = self.uartService
        delegate?.didConnectPeripheral?(connectedPeripheral!)

        print("Did connect periperal = \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheral.delegate = nil
        stopPingTimer()

        if peripheral.identifier == connectedPeripheral?.peripheral.identifier {
            delegate?.didDisconnectPeripheral?(connectedPeripheral!)
            connectedPeripheral?.peripheral.delegate = nil
            connectedPeripheral = nil
        }
        
        print("Did disconnect peripheral = \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let uuidString = peripheral.identifier.uuidString
        
        if let existPeripheral = self.peripherals[uuidString] {
            existPeripheral.RSSI = RSSI.intValue
            
            for (key, value) in advertisementData {
                existPeripheral.advertisementData.updateValue(value, forKey: key)
            }
            
            self.peripherals[uuidString] = existPeripheral
        } else {
            let newPeripheral = BluetoothPeripheral(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI.intValue)
            self.peripherals[uuidString] = newPeripheral
        }

        self.delegate?.didDiscoverPeripherals?(peripherals)
    }
    
    // MARK: UartServiceDelegate
    
    func uartServiceDidDiscoverCharacterictics(_ sender: UartService) {
        startPingDevice()
    }

    func uartServiceFailDiscoverCharacterictics(_ sender: UartService) {
        stopPingTimer()
        delegate?.unsecureConnection?()
    }

    func uartService(_ sender: UartService, didUpdate data: Data, for characterictics: CBCharacteristic) {
        if var responseData = responseData {
            responseData.append(data)
            self.responseData = responseData
        } else {
            responseData = data
        }
    }
    
    // MARK: Signals 

    func sendSignal(_ signal: String) {
        guard let data = signal.data(using: .utf8) else { return }
        uartService?.sendData(data)
    }
}
