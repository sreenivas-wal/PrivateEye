//
//  WebViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/15/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import WebKit

//TODO: Uncomment the below code before app release
#if LIVE
    private let doximityUrl = "https://auth.doximity.com/oauth/authorize?client_id=04076e26bc386b7eb7ca88f8273d13448bf8828685ce228b76103303edcda6f3&response_type=code&redirect_uri=https://mymobileerhealthcare.stlouisintegration.com/doximity/redirect&scope=email%20basic%20colleagues&type=login&&state=DoximityStateUniqueValue"
#else
    private let doximityUrl = "https://auth.doximity.com/sessions/login?client_id=2dba1beec41070b89f1ffefea618d2c9c23b23cb2cafe4c8527ceaaec8537dbb&redirect_to=https%3a%2f%2fauth.doximity.com%2foauth%2fauthorize%3fclient_id%3d2dba1beec41070b89f1ffefea618d2c9c23b23cb2cafe4c8527ceaaec8537dbb%26redirect_uri%3dhttp%253A%252F%252Fdev.mymobileerhealthcare.stlouisintegration.com%252Fdoximity%252Fredirect%26response_type%3dcode%26scope%3dbasic%2bcolleagues%2bemail%26state%3d690adeb44dfa66365f687da928e38b14"
#endif


protocol WebViewControllerDelegate: class {
    
    func webViewController(_ sender: WebViewController, didRedirectFromDoximityWithCode code: String)
    func webViewController(_ sender: WebViewController, doneButtonTapped button: UIButton)
}

class WebViewController: UIViewController, WKNavigationDelegate {
    
    weak var delegate: WebViewControllerDelegate?

    fileprivate var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWebView()
        self.setupNavigationBarButton()
        
        self.clearCache(completion: { [weak self] in
            self?.loadDoximityLoginRequest()
        })
        
        UIApplication.shared.statusBarStyle = .default
    }

    // MARK: -
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }
        
        print(url.path)
        if url.path == "/doximity/redirect" {
            let code = doximityAuthorizationCode(fromUrl: url)
            self.delegate?.webViewController(self, didRedirectFromDoximityWithCode: code)
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func doneButtonTapped(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
        self.delegate?.webViewController(self, doneButtonTapped: button)
    }

    // MARK: -
    // MARK: Private
    fileprivate func doximityAuthorizationCode(fromUrl url: URL) -> String {

        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
        guard let code = queryItems?.filter({$0.name == "code"}).first?.value else { return "" }
        
        return code
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

    fileprivate func setupWebView() {
        let wkwebView = WKWebView(frame: .zero)
        self.webView = wkwebView
        self.webView.navigationDelegate = self
        self.webView.backgroundColor = .white
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        
        self.view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webView]-0-|",
                                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                                          metrics: nil,
                                                                            views: ["webView" : webView]))
        
        view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webView]-0-|",
                                                                     options: NSLayoutFormatOptions(rawValue: 0),
                                                                     metrics: nil,
                                                                       views: ["webView" : webView]))
    }
    
    fileprivate func setupNavigationBarButton() {
        let leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    fileprivate func loadDoximityLoginRequest() {
        let url = URL(string: doximityUrl)!
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

