//
//  NotificationService.swift
//  MMEDPushExtension
//
//  Created by Vlad Yalovenko on 28/03/2018.
//  Copyright © 2018 Company. All rights reserved.
//

import UserNotifications
import Reachability

class NotificationService: UNNotificationServiceExtension {

  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard let bestAttemptContent = bestAttemptContent else {
      return
    }
    guard let attachmentUrlString = request.content.userInfo["media-url"] as? String else {
      return
    }
    guard let url = URL(string: attachmentUrlString) else {
      return
    }

    URLSession.shared.downloadTask(with: url, completionHandler: { (optLocation: URL?, optResponse: URLResponse?, error: Error?) -> Void in
      if error != nil {
        print("Download file error: \(String(describing: error))")
        return
      }
      guard let location = optLocation else {
        return
      }
      guard let response = optResponse else {
        return
      }

      do {
        let lastPathComponent = response.url?.lastPathComponent ?? ""
        var attachmentID = UUID.init().uuidString + lastPathComponent

        if response.suggestedFilename != nil {
          attachmentID = UUID.init().uuidString + response.suggestedFilename!
        }

        let tempDict = NSTemporaryDirectory()
        let tempFilePath = tempDict + attachmentID

        try FileManager.default.moveItem(atPath: location.path, toPath: tempFilePath)
        let attachment = try UNNotificationAttachment.init(identifier: attachmentID, url: URL.init(fileURLWithPath: tempFilePath))

        bestAttemptContent.attachments.append(attachment)
      }
      catch {
        print("Download file error: \(String(describing: error))")
      }

      OperationQueue.main.addOperation({() -> Void in
        self.contentHandler?(bestAttemptContent);
      })
    }).resume()
  }

  override func serviceExtensionTimeWillExpire() {
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

}
