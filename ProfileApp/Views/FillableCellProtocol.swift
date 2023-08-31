import UIKit

protocol FillableCellProtocol: UITableViewCell {
    func fill(title: String?, value: Any?)
    func fill(title: String?, value: Any?, isScrollEnabled: Bool)
}

extension FillableCellProtocol {
    func fill(title: String?, value: Any?) {
        fill(title: title, value: value, isScrollEnabled: true)
    }
}
