import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as? T ?? T()
    }
    
    func register<T: UITableViewCell>(_ cell: T.Type) {
            register(cell, forCellReuseIdentifier: cell.reuseId)
    }
}
