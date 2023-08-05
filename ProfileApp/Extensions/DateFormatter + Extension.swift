import Foundation

extension DateFormatter {
    static func shortFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
}
