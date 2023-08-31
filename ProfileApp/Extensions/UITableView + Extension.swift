import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseId, for: indexPath) as? T ?? T()
    }
    
    func register(_ cellType: UITableViewCell.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseId)
    }
}
