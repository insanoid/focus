//
//  NCDatabaseService.swift
//  FocusFlakes
//
//  Created by Karthikeya Udupa on 02/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import SQLite


struct NCDatabaseService {
    
    let databaseURL: URL
    let db: Connection?
    
    init(databaseURL: URL, isDebugMode: Bool = false) throws {
        self.databaseURL = databaseURL
        self.db = try Connection(self.databaseURL.absoluteString)
        if isDebugMode {
            self.db!.trace { print($0) }
        }
    }
    
    enum DBError: Error {
        case dbConnectionError
        case dataAccessError(error: Error)
        case contentDecodingError(error: Error)
    }
    
    struct ColumnInformation {
        var type: Expression<Any>
        var name: String
        
    }
    
    struct ColumnValues {
        let appId = Expression<Int64>("app_id")
        let identifider =  Expression<String?>("identifier")
    }
    
    enum DBTable {
        case notifications, applications
        func name() -> String {
            switch self {
            case .applications:
                return "app"
            case .notifications:
                return "record"
            }
        }
    }
    
    // TODO: Implement with generics and Results
    func records(table: DBTable, completionHandler: @escaping ([Row]?, Error?) -> Void) {
        guard db != nil else {
            completionHandler(nil, DBError.dbConnectionError)
            return
        }
        
        let presented = Expression<Int?>("presented")
        var tableInstance = Table(table.name()).filter(presented == 1).order(Expression<Double?>("delivered_date").desc).limit(10)
        var allRecords: [Row] = []
        do {
            for record in try self.db!.prepare(tableInstance) {
                allRecords.append(record)
            }
        } catch {
            completionHandler(nil, DBError.dataAccessError(error: error))
        }
        completionHandler(allRecords, nil)
    }
    
}

extension NCDatabaseService {
    
    func fetchNotifications(completionHandler: @escaping ([NotificationRecord]?, Error?) -> Void) {
        self.records(table: .notifications) { (rows, error) in
            if error != nil || rows == nil {
                completionHandler(nil, error)
                return
            }
            var notifications: [NotificationRecord] = []
            for row in rows! {
                
                notifications.append(NotificationRecord.init(databaseRow: row))
            }
            completionHandler(notifications, nil)
        }
    }
}


struct NotificationRecord: Codable {
    let appId:Int64
    let requestDate:Double?
    private let requestBody:NotificationRequest?
    init(databaseRow: Row) {
        self.appId = databaseRow[Expression<Int64>("app_id")]
        self.requestDate = databaseRow[Expression<Double?>("request_last_date")]
        let notificationBody = databaseRow[Expression<Data?>("data")]
        if notificationBody != nil {
            self.requestBody = NotificationRequest.init(data: notificationBody!)
        } else {
            self.requestBody = nil
        }
    }
    
    var body: String? {
        get {
        return self.requestBody?.body
        }
    }
    
    var title: String? {
        get {
            return self.requestBody?.title
        }
    }
    
    var subtitle: String? {
        get {
            return self.requestBody?.subtitle
        }
    }
    
    var appBundleName: String? {
        get {
            return self.requestBody?.appBundleName
        }
    }

    func description() -> String {
        return "\(self.appBundleName ?? "None") \(self.title ?? "None") \(self.subtitle ?? "None") \(self.body ?? "None")"
    }
    
}

struct NotificationRequest: Codable {
    var body: String?
    var title: String?
    var subtitle: String?
    var appBundleName: String?
    
    init(data: Data) {
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:] //Our data
        do {//convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: data,
                                                                   options: .mutableContainersAndLeaves,
                                                                   format: &propertyListFormat) as! [String:AnyObject]
            self.appBundleName = plistData["app"] as? String
            let request: [String: AnyObject] = plistData["req"]! as! [String : AnyObject]
            print(request)
            self.title = request["titl"] as? String
            self.subtitle = request["subt"] as? String
            self.body = request["body"] as? String
            
        } catch {
            body = nil
            title = nil
            subtitle = nil
            appBundleName = nil
            print("Error reading plist: \(error), format: \(propertyListFormat)")
        }
    }
}
