import UIKit

final class TextViewTableViewCell: UITableViewCell {
    weak var delegate: EditTableViewCellDelegate?
    
    private var isScrollEnabled: Bool = true
    
    private lazy var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var txtInput : UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .right
        view.font = UIFont.systemFont(ofSize: 18.0)
        return view
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
        addSubview(lblTitle)
        contentView.addSubview(txtInput)
        txtInput.delegate = self
        
    }
}

//MARK: - setupConstraints
extension TextViewTableViewCell {
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            lblTitle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            
            txtInput.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            txtInput.leadingAnchor.constraint(equalTo: lblTitle.trailingAnchor, constant: 5),
            txtInput.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9),
            txtInput.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
}

//MARK: - UITextViewDelegate
extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.editTableViewCell(self, didChange: textView.text ?? "")
        
        guard isScrollEnabled else { return }
        delegate?.editTableViewCellShouldUpdateSize(self)
    }
}

//MARK: - FillableCellProtocol
extension TextViewTableViewCell: FillableCellProtocol {
    func fill(title: String?, value: Any?, isScrollEnabled: Bool = true) {
        lblTitle.text = title
        txtInput.text = value as? String
        txtInput.isScrollEnabled = isScrollEnabled
        self.isScrollEnabled = !isScrollEnabled
    }
}
