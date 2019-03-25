//
//  ViewController.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import UIKit

class CaseSelectionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    private let EstimatedRowHeight: CGFloat = 71.0

    var router: AuthorizationRouterProtocol?
    var peripherals = [BluetoothPeripheral]()
    var viewModelPeripherals = [CaseViewModel]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib.init(nibName: "CaseTableViewCell", bundle: nil), forCellReuseIdentifier: "CaseTableViewCell")
        tableView.estimatedRowHeight = EstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bluetoothManager?.startScan()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func buttonCloseTapped(_ sender: Any) {
        bluetoothManager?.stopScan()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showBluetoothPopUpView() {
        if popUpView == nil {
            let popUpHeight: CGFloat = BluetoothPopUpView.viewHeight()
            let yPosition = self.view.bounds.height - popUpHeight
            let bluetoothPopUp = BluetoothPopUpView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: popUpHeight))
            
            bluetoothPopUp.buttonDoneTapCallback = {
                self.popUpView?.hideView(fromView: self.view)
            }
            
            self.popUpView = bluetoothPopUp
        }
        
        popUpView?.show(fromView: self.view)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCase = viewModelPeripherals[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CaseTableViewCell") as! CaseTableViewCell
        cell.configureCell(with: currentCase)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelPeripherals.count
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let currentPeripheral = peripherals[index]
        let viewModel = viewModelPeripherals[index]
        viewModel.connecting = true
        
        tableView.reloadData()

        bluetoothManager?.connectToPeripheral(currentPeripheral)
    }
    
    // MARK: BluetoothManagerDelegate
    
    func didDiscoverPeripherals(_ peripherals: [String : BluetoothPeripheral]) {
        self.peripherals.removeAll()
        self.viewModelPeripherals.removeAll()
        
        for (_, value) in peripherals {
            if value.isUartAdvertised() {
                self.peripherals.append(value)
                let connected = bluetoothManager?.checkConnected(value)
                self.viewModelPeripherals.append(convertToCaseViewModel(value, connecting: false, connected: connected!))
            }
        }
        
        self.tableView.reloadData()
    }
    
    func convertToCaseViewModel(_ peripheral: BluetoothPeripheral, connecting: Bool, connected: Bool) -> CaseViewModel {
        let caseViewModel = CaseViewModel()
        caseViewModel.title = peripheral.name
        caseViewModel.connected = connected
        caseViewModel.connecting = connecting
        
        return caseViewModel
    }
    
    func didConnectPeripheral(_ peripheral: BluetoothPeripheral) {
        let index = peripherals.index(of: peripheral)
        let viewModel = viewModelPeripherals[index!]
        viewModel.connected = true
        viewModel.connecting = false
        
        tableView.reloadData()
        self.view.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.bluetoothManager?.stopScan()
            self.dismiss(animated: true, completion: nil)
        })

        print("Connect")
        self.sendCaseConnectedRequest()
    }
    
    func didDisconnectPeripheral(_ peripheral: BluetoothPeripheral) {
        let index = peripherals.index(of: peripheral)
        let notConnected = convertToCaseViewModel(peripheral, connecting: false, connected: false)
        
        if index != nil {
             viewModelPeripherals[index!] = notConnected
        }
        
        tableView.reloadData()
    }

    override func failureConnection() {
        
        if popUpView?.superview != self.view {
            self.showBluetoothPopUpView()
        }

        self.headerBar?.secureButtonUserInteractionEnabled = true
        self.headerBar?.secureButtonImage = UIImage(named: ("lockOpen"))

        self.logUnsuccessfulConnection()
    }
    
    override func successConnection() {
        super.successConnection()
        
        if let popUp = popUpView {
            if popUp.superview != nil {
                popUp.hideView(fromView: self.view)
            }
        }
    }
    
    // MARK: Private
    
    func sendCaseConnectedRequest() {
        self.networkCaseConnectionManager?.caseConnected({ (response) -> (Void) in
            print("Case connected response = \(response)")
        }, failureBlock: { (error) -> (Void) in
            print("Case connected error = \(error.message)")
        })
    }
    
    func logUnsuccessfulConnection() {
        
        guard let requiredCaseLogsCoordinator = self.caseLogsCoordinator else { return }
            
        let caseLog = CaseLog(with: CaseLog.Action.connectionUnsuccessful,
                   actionTimestamp: Date().timeIntervalSince1970.description,
                       geolocation: LocationService().currentLocationDescription())
            
        requiredCaseLogsCoordinator.upload(caselog: caseLog)
    }
}

