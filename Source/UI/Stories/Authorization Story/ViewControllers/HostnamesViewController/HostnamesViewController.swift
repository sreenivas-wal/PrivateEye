//
//  HostnamesViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/16/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol HostnamesViewControllerDelegate: class {
    func hostnamesViewController(_ sender: HostnamesViewController, didSelectHostname hostname: Hostname)
}

class HostnamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    private let tableViewRowHeight: CGFloat = 60.0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDomainView: EmptyDomainsView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var networkManager: AuthorizationNetworkProtocol?
    var router: AuthorizationRouterProtocol?
    var delegate: HostnamesViewControllerDelegate?
    
    private var searchRequest: NetworkRequest?
    private var hostnames: [Hostname] = [Hostname.defaultHostname()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.init(nibName: "HostnameTableViewCell", bundle: nil), forCellReuseIdentifier: "HostnameTableViewCell")
        tableView.tableFooterView = UIView()
        
        subscribeToKeyboardNotifications()
        searchHostname(by: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.becomeFirstResponder()
    }

    deinit {
        print(String(describing: self))
    }
    
    // MARK: - Private
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(PhotosViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PhotosViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        tableViewBottomConstraint.constant = keyboardFrame.height
    }
    
    func keyboardWillHide(_ notification: Notification) {
        tableViewBottomConstraint.constant = 0
    }
    
    private func cancelSearchRequestIfNeeded() {
        if searchRequest != nil {
            searchRequest?.dataRequest?.cancel()
        }
    }

    private func searchHostname(by keywords: String) {
        cancelSearchRequestIfNeeded()
        
        searchRequest = networkManager?.searchHostnames(withSearchFilter: keywords, successBlock: { [weak self] (response) -> (Void) in
            guard let strongSelf = self else { return }
            let hostnames = response.object as! [Hostname]
            strongSelf.hostnames = strongSelf.sortedHostnames(hostnames)
            strongSelf.searchRequest = nil
            
            DispatchQueue.main.async {
                let isNonEmpty = (hostnames.count > 0)
                strongSelf.configureEmptyViewVisibility(isHidden: isNonEmpty, withText: "Domain name not found")
                strongSelf.tableView.reloadData()
            }
        }, failureBlock: { [weak self] (error) -> (Void) in
            guard let strongSelf = self else { return }
            strongSelf.searchRequest = nil

            if error.message.lowercased() == "cancelled" { return }
            
            DispatchQueue.main.async {
                strongSelf.hostnames = [Hostname.defaultHostname()]
                strongSelf.configureEmptyViewVisibility(isHidden: false, withText: "Unable to load institution list. Check connection")
                strongSelf.tableView.reloadData()
            }
        })
    }
    
    private func sortedHostnames(_ hostnames: [Hostname]) -> [Hostname] {
        let defaultHostTitle = Hostname.defaultHostname().title
        var resultHostnames = [Hostname]()
        var mutableHostnames = hostnames
        
        if let index = hostnames.index(where: { $0.title?.lowercased() == defaultHostTitle!.lowercased() }) {
            let defaultHostname = hostnames[index]
            mutableHostnames.remove(at: index)
            resultHostnames.append(defaultHostname)
        }

        let sortedHostnames = mutableHostnames.sorted { (hostname1, hostname2) -> Bool in
            return (hostname1.title! < hostname2.title!)
        }

        resultHostnames.append(contentsOf: sortedHostnames)
        
        return resultHostnames
    }

    private func configureEmptyViewVisibility(isHidden: Bool, withText text: String) {
        emptyDomainView.isHidden = isHidden
        emptyDomainView.titleLabel.text = text
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostnameTableViewCell") as! HostnameTableViewCell
        cell.hostnameLabel.text = hostnames[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostnames.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHostname = hostnames[indexPath.row]
        delegate?.hostnamesViewController(self, didSelectHostname: selectedHostname)
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearchRequestIfNeeded()
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchHostname(by: searchText)
    }

}
