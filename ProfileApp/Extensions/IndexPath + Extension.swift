import UIKit

extension IndexPath {
    init(_ fieldType: Profile.FieldType) {
        self.init(row: fieldType.rawValue, section: 0)
    }
}
