//
//  ViewController.swift
//  FocusFlakes
//
//  Created by Karthikeya Udupa on 02/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import SQLite


/// Default dimensions for the view.
///
/// - width: Default width.
/// - maxHeight: Maximum possible widdth.
/// - height: Default height.
/// - bottomSectionHeight: Height of the bottom bar for settings/refresh.
public enum DefaultDimensions: Int {
    case width = 335
    case height = 250
    case maxHeight = 350
    case bottomSectionHeight = 30
}


/// A enum to store all the notification and to generate to required type.
///
/// - heightChange: Whenever the height of view has to be altered.
/// - dismiss: Dismiss the view.
public enum PopoverBehaviorNotification: String {
    case heightChange = "PopOverHeightChange"
    case dismiss = "PopOverDismiss"
    
    func name() -> Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}


class NotificationListViewController: NSViewController {
    
    @IBOutlet weak var notificationTableView: NSTableView!
    
    /// List of sensors presently available, reload the tableview everytime the sensor list if changed.
    var notifications = [NotificationRecord]() {
        didSet {
            self.notificationTableView.reloadData()
        }
    }
    
    /// Preferred height for the view based on the current state and restrictings.
    var preferredViewHeight: Int {
        get {
            // && self.loadingView.isHidden
            if self.notifications.count > 0 {
                let requiredHeight = DefaultDimensions.bottomSectionHeight.rawValue + (self.notifications.count * NotificationCell.height)
                return requiredHeight > DefaultDimensions.maxHeight.rawValue ? DefaultDimensions.maxHeight.rawValue : requiredHeight
            }
            return 250
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        fetchNotifications()
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func fetchNotifications() {
        guard let  databasePath = NCDatabaseFinder.shared.DatabaseFilePath() else {
            // TODO: Failure UI
            return
        }
        
        do {
            let notificationDatabase = try NCDatabaseService.init(databaseURL: databasePath, isDebugMode: true)
            notificationDatabase.fetchNotifications { (records, error) in
                if let _ = error {
                    print("Error Occured!")
                    return
                }
                self.notifications = records!
            }
        } catch {
            
        }
    }
}

// MARK: - TableView Delegates and Datasource Methods.
extension NotificationListViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        return NotificationCell.view(tableView: tableView, owner: self, subject: notifications[row] as AnyObject)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat.init(NotificationCell.height)
    }
}
