import Foundation

enum StandardWiseAuthMode: String {
    case local
    case staging

    static var current: StandardWiseAuthMode {
        let value = ProcessInfo.processInfo.environment["STANDARDWISE_AUTH_MODE"]?.lowercased()
        return StandardWiseAuthMode(rawValue: value ?? "") ?? .staging
    }
}
