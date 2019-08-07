//
//  SensorCell.swift
//  KIWI
//
//  Created by Karthik on 10/12/2016.
//  Copyright © 2016 Karthik. All rights reserved.
//

import Cocoa
import Foundation


/// Tableview cell to show information about the sensor.
class NotificationCell: NSTableCellView {
    static var identifier = "NotificationCellIdentifier"
    static var height = 55
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var taglineLabel: NSTextField!
    @IBOutlet weak var thumbnailImageView: NSImageView!

    private var notification: NotificationRecord?

    class func view(tableView: NSTableView,
                    owner: AnyObject?,
                    subject: AnyObject?) -> NSView? {
        if let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: NotificationCell.identifier), owner: owner) as? NotificationCell {
            if let notification = subject as? NotificationRecord {
                view.setCurrentNotification(notification: notification)
            }
            return view
        }
        return nil
    }

    private func setCurrentNotification(notification: NotificationRecord) {
        self.notification = notification
        updateUI()
    }
    
    var inDarkMode: Bool {
        let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
        return mode == "Dark"
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        taglineLabel.textColor = NSColor.gray
        titleLabel.textColor = NSColor.black
    }

    func updateUI() {
        if inDarkMode {
            titleLabel.textColor = .white
            taglineLabel.textColor = .lightGray
        }
        else {
            titleLabel.textColor = .black
            taglineLabel.textColor = .darkGray
        }
        if let title = notification?.title {
         titleLabel.stringValue = title
        }
        if let subtitle = notification?.subtitle {
            taglineLabel.stringValue = subtitle
        } else if let body = notification?.body {
            taglineLabel.stringValue = body
        } else {
            taglineLabel.stringValue = (notification?.appBundleName)!
        }
       
        if let bundle = notification? .appBundleName {
             let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundle)
            thumbnailImageView.image = NSWorkspace.shared.icon(forFile: path!)
            
        }
    }
}
