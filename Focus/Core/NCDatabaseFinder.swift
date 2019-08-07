//
//  NCDatabaseFinder.swift
//  FocusFlakes
//
//  Created by Karthikeya Udupa on 02/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation

/// A singleton to manage database path for notification center database in the tmp folder.
/// TODO: Should have a notifier in-case there is a refresh needed.
public class NCDatabaseFinder {
    
    static let shared = NCDatabaseFinder()
    private var currentDatabaseFolderPath: String? = nil
    
    init() {
        let _ = self.refresh()
    }
    enum FilePaths: String {
        case notificationCenterTempFolder = "com.apple.notificationcenter/db2"
        case systemTempFolder = "/private/var/folders/"
        case databaseFileName = "/db"
    }
    
    func refresh() -> Bool {
        self.currentDatabaseFolderPath = getFolderPathWithinFolder(stackBasePath: FilePaths.systemTempFolder.rawValue, needleFolderPath: FilePaths.notificationCenterTempFolder.rawValue)
        print(self.currentDatabaseFolderPath)
        return self.isDatabaseAvailable()
    }
    
    func DatabaseFilePath() -> URL? {
        guard let basePath = self.currentDatabaseFolderPath else {
            return nil
        }
        return URL(string: basePath)!.appendingPathComponent(FilePaths.databaseFileName.rawValue)
    }
    
    func isDatabaseAvailable() -> Bool {
        return DatabaseFilePath() != nil
    }
    
    func locate() -> Bool {
        return self.refresh()
    }
    
    /// Use the base folder and traverse recursively to find the folder or path component provided.
    /// We are only looking for folders within folder.
    private func getFolderPathWithinFolder(stackBasePath: String, needleFolderPath: String) -> String? {
        
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            let enumerator = FileManager.default.enumerator(at: URL.init(string: stackBasePath)!,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles, .skipsPackageDescendants])!
            for case let fileURL as URL in enumerator {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isDirectory! == true  && fileURL.path.hasSuffix(needleFolderPath) {
                    return fileURL.path
                }
            }
            return nil
        } catch {
            print(error)
            return nil
        }
    }
}

