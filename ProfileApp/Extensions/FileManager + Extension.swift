import UIKit

extension FileManager {
    func contentsOfDirectory(at url: URL) throws -> [URL] {
        return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
    }
    
    func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask) throws -> URL {
        return try url(for: directory, in: domain, appropriateFor: nil, create: false)
    }
}
