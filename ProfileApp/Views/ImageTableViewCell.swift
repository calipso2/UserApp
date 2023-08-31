import UIKit

final class ImageTableViewCell: UITableViewCell {
    
    private lazy var vImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        contentView.addSubview(vImage)
        vImage.layer.cornerRadius = 75
        vImage.layer.masksToBounds = true
    }
}

//MARK: - setConstraints
extension ImageTableViewCell {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            vImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            vImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            vImage.heightAnchor.constraint(equalToConstant: 150),
            vImage.widthAnchor.constraint(equalToConstant: 150),
            vImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
}

//MARK: - FillableCellProtocol
extension ImageTableViewCell: FillableCellProtocol {
    func fill(title: String?, value: Any?, isScrollEnabled: Bool) {
        if let image = value as? UIImage {
            vImage.image = image
        }
    }
}

