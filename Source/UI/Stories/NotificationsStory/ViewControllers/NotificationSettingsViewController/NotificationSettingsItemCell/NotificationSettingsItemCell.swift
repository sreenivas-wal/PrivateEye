//
//  NotificationSettingsItemCell.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

struct NotificationSettingsItemViewModel {
    
    let title: String
    let isOn: Bool
    let messageName:String
    init?(json: JSON) {
        guard let messageID = json["id"].string,
            let subscribed = json["subscribed"].rawString(),
            let description = json["description"].string,
            let messagename = json["name"].string
        
            else {
                return nil
        }
        self.title = description
        self.messageName = messagename
        if subscribed == "true" {
             self.isOn = true
        }else {
            self.isOn = false
        }
    } 
}

protocol NotificationSettingsItemCellDelegate: class {
    
    func notificationSettingsItemCell(_ cell: NotificationSettingsItemCell, didSwitchValueToOn: UISwitch)
    func notificationSettingsItemCell(_ cell: NotificationSettingsItemCell, didSwitchValueToOff: UISwitch)
}

class NotificationSettingsItemCell: UITableViewCell {
    
    var delegate: NotificationSettingsItemCellDelegate?
    
    @IBOutlet fileprivate var switcher: UISwitch!
    @IBOutlet fileprivate var titleLabel: UILabel!
    var notificationsNetworkManager: NotificationsNetworkProtocol!
    var model:NotificationSettingsItemViewModel? = nil
    
    class var cell: NotificationSettingsItemCell {
        
        return Bundle.main.loadNibNamed(NotificationSettingsItemCell.cellIdentifier, owner: self, options: nil)?[0] as! NotificationSettingsItemCell
    }
    
    class var cellNib: UINib {
        
        return UINib(nibName: "NotificationSettingsItemCell", bundle: nil)
    }
    
    class var cellIdentifier: String {
        
        return "NotificationSettingsItemCell"
    }
    
    func configure(with viewModel: NotificationSettingsItemViewModel) {
        model = viewModel
        self.switcher.setOn(viewModel.isOn, animated: false)
        self.titleLabel.text = viewModel.title
    }
    
    @IBAction func optionChangeValue(_ sender: UISwitch) {
            notificationsNetworkManager.postNotificationSettingType(with: (model?.messageName)!, subscribed: (sender.isOn), successBlock: { (response) -> (Void) in
            print(response)
        }) { (error) -> (Void) in
            print(error)
        }
        sender.isOn ? switcher.setOn(true, animated: true) : switcher.setOn(false, animated: true)
    }
}
