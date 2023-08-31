import UIKit

final class GenderPickerTableViewCell: UITableViewCell {
    weak var delegate: EditTableViewCellDelegate?
    
    private lazy var genders: [String] = {
        return Gender.allCases.map { $0.title }
    }()
    
    private let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var txtGender: UITextField = {
        let txt = UITextField()
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.textAlignment = .right
        txt.font = UIFont.systemFont(ofSize: 18.0)
        txt.tintColor = .clear
        return txt
    }()
    
    private lazy var pickGender: UIPickerView = {
        let pick = UIPickerView()
        pick.translatesAutoresizingMaskIntoConstraints = false
        return pick
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
        pickGender.delegate = self
        pickGender.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        addSubview(lblTitle)
        contentView.addSubview(txtGender)
        txtGender.inputView = pickGender
    }
}

//MARK: - setupConstraints
extension GenderPickerTableViewCell {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            lblTitle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            
            txtGender.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            txtGender.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9),
            txtGender.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor, constant: 5)
        ])
    }
}

// MARK: - UIPickerViewDataSource
extension GenderPickerTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.allCases.count
    }
}

// MARK: - UIPickerViewDelegate
extension GenderPickerTableViewCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtGender.text = genders[row]
        delegate?.editTableViewCell(self, didChange: Gender.allCases[row])
        txtGender.resignFirstResponder()
    }
}

// MARK: - FillableCellProtocol
extension GenderPickerTableViewCell: FillableCellProtocol {
    func fill(title: String?, value: Any?, isScrollEnabled: Bool) {
        lblTitle.text = title
        txtGender.text = (value as? Gender)?.title
    }
}
