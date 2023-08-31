import UIKit

final class DatePickerTableViewCell: UITableViewCell {
    weak var delegate: EditTableViewCellDelegate?
    
    private lazy var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var pickDate: UIDatePicker = {
        let pickDate = UIDatePicker()
        pickDate.translatesAutoresizingMaskIntoConstraints = false
        pickDate.locale = Locale(identifier: "ru_RU")
        pickDate.maximumDate = Date()
        pickDate.datePickerMode = .date
        return pickDate
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        selectionStyle = .none
        addSubview(lblTitle)
        contentView.addSubview(pickDate)
        pickDate.addTarget(self, action: #selector(pickDate_valueChanged), for: .valueChanged)
    }
    
    @objc private func pickDate_valueChanged(_ sender: UIDatePicker) {
        delegate?.editTableViewCell(self, didChange: sender.date)
    }
}

//MARK: - setupConstraints
extension DatePickerTableViewCell{
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            lblTitle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            
            pickDate.centerYAnchor.constraint(equalTo: centerYAnchor),
            pickDate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9)
        ])
    }
}

// MARK: - FillableCellProtocol
extension DatePickerTableViewCell: FillableCellProtocol {
    func fill(title: String?, value: Any?, isScrollEnabled: Bool) {
        lblTitle.text = title
        pickDate.date = (value as? Date) ?? Date()
    }
}
