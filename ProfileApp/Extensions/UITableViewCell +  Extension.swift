import UIKit

extension UITableViewCell {
    static var reuseId: String {
        let className = String(describing: self)
        return className + "Id"
    }
}
