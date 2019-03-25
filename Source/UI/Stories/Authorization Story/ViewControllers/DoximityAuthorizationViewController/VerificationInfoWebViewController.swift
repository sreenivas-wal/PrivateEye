//
//  VerificationInfoWebViewController.swift
//  MyMobileED_Fabric
//
//  Created by Manisha Reddy Narayan on 24/08/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import WebKit
//TODO: Uncomment the below code before app release
//#if LIVE
    private let verificationUrl = "https://mymobileerhealthcare.stlouisintegration.com/verify"
//#else
//private let verificationUrl = "https://dev.mymobileerhealthcare.stlouisintegration.com/verify"
//#endif

protocol VerificationInfoWebViewControllerDelegate: class {
    
    func verificationInfoWebViewController(_ sender: VerificationInfoWebViewController, doneButtonTapped button: UIButton)
    func verificationInfoWebViewController(_ sender: VerificationInfoWebViewController, didRedirectFromVerificationFormWithmessage message: String)
    
}

class VerificationInfoWebViewController: UIViewController, WKNavigationDelegate,WKScriptMessageHandler {
    
    var contentController = WKUserContentController()
    
    weak var delegate: VerificationInfoWebViewControllerDelegate?
    var alertManager : AlertsManagerProtocol?
    var userManager:UserManager?
    fileprivate var webView: WKWebView!
    var message :String?
    
    let cookieStorage = HTTPCookieStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBarButton()
        self.clearCache(completion: { [weak self] in
            self?.loadUserVerificationInfoRequest()
        })
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message)
        self.message = message.body as? String
        if message.body as? String == "Submit for Verification" {
            self.dismiss(animated: true) {
                self.delegate?.verificationInfoWebViewController(self, didRedirectFromVerificationFormWithmessage: message.name)
            }
        }
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(self.webView!.url?.absoluteString)
        print(userManager?.currentUser!.sessionName)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(self.webView!.url?.absoluteString)
        print(userManager?.currentUser!.sessionName)
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("------ didCommitNavigation - content arriving?")
        print(userManager?.currentUser!.sessionName)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("----- didFinish")
        print(self.webView!.url?.absoluteString)
        print(userManager?.currentUser!.sessionName)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(self.webView!.url?.absoluteString)
        print("didFail")
        print(userManager?.currentUser!.sessionName)

    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("----- didFailProvisionalNavigation")
        print(self.webView!.url?.absoluteString)
        print(userManager?.currentUser!.sessionName)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(self.webView!.url?.absoluteString)
        print(userManager?.currentUser!.sessionName)
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    fileprivate func loadUserVerificationInfoRequest() {
        let url = URL(string: verificationUrl)!
        var request = URLRequest(url: url)
        if userManager?.currentUser!.sessionName! == nil || userManager?.currentUser?.sessionID! == nil {
            alertManager?.showAlert(forViewController: self, withTitle: "Error", message: "No token available, please login to continue.")
            return
        }
        let currentCookie = userManager?.currentUser!.sessionName!.appendingFormat("=%@", (userManager?.currentUser?.sessionID)!)
//        #if LIVE
            let cookieStr = currentCookie!+"; path=/ ;domain=mymobileerhealthcare.stlouisintegration.com"
//        #else
//            let cookieStr = currentCookie!+"; path=/ ;domain=dev.mymobileerhealthcare.stlouisintegration.com"
//        #endif
        

        request.setValue(cookieStr, forHTTPHeaderField: "cookie")
        
        contentController.add(
            self,
            name: "verification"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(
            frame: self.view.bounds,
            configuration: config
        )
        self.webView.navigationDelegate = self
//        #if LIVE
        let domain = "mymobileerhealthcare.stlouisintegration.com"
//        #else
//        let domain = "dev.mymobileerhealthcare.stlouisintegration.com"
//        #endif
        let cookie = HTTPCookie(properties: [
            .domain: domain,
            .path: "/",
            .name: userManager?.currentUser!.sessionName!,
            .value: userManager?.currentUser?.sessionID!,
            .secure: "TRUE",
            .version: 1
            ])!
        
        print("-----------------")
        print(cookie.isHTTPOnly)
        if #available(iOS 11.0, *) {
            print("QWERTYUIOIUYTREWASDFGHJKBVCXXCVBNLKWERTYUIHG")
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        } else {
            // Fallback on earlier versions
            //TODO: Make the changes if we support iOS 10 and below
        }
        webView.load(request)
        self.view = self.webView!
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping
        (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func doneButtonTapped(_ button: UIButton) {
        if message == "SAVE" {
            dismiss(animated: true, completion: nil)
        } else {
            alertManager?.showUnSavedChangesAlertController(forViewController: self, withYesCallback: { () -> (Void) in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.verificationInfoWebViewController(self, doneButtonTapped: button)

            }, withNoCallback: { () -> (Void) in
                
            })
        }
    }
    
    
    fileprivate func clearCache(completion: @escaping VoidBlock) {
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeCookies])
        let date = Date(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler: completion)
    }
    
    
    fileprivate func setupNavigationBarButton() {
        let leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
}
