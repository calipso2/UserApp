import UIKit

final class PreviewTableViewCell: UITableViewCell {
    private lazy var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var lblDescription: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .right
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(value: String?, with title: String?) {
        lblTitle.text = title
        lblDescription.text = value
    }
    
    private func setupView() {
        selectionStyle = .none
        addSubview(lblTitle)
        addSubview(lblDescription)
    }
}

//MARK: - setConstraints
extension PreviewTableViewCell {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            lblTitle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            lblDescription.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            lblDescription.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            lblDescription.leadingAnchor.constraint(equalTo: lblTitle.trailingAnchor, constant: 5),
            lblDescription.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7)
            
        ])
    }
}
