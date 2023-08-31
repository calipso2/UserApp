import UIKit

protocol EditTableViewCellDelegate: AnyObject {
    func editTableViewCell(_ cell: UITableViewCell, didChange value: Any?)
    func editTableViewCellShouldUpdateSize(_ cell: UITableViewCell)
}
