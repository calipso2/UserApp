import UIKit

protocol EditTableViewCellDelegate: AnyObject {
    func tableViewCell(_ cell: UITableViewCell, didChange value: Any?)
}

protocol FillableCellProtocol {
    func fill(title: String?, value: Any?)
}

final class TextViewTableViewCell: UITableViewCell {
    weak var delegate: EditTableViewCellDelegate?
    
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
    
    private func setupView(){
        selectionStyle = .none
        addSubview(lblTitle)
        contentView.addSubview(txtInput)
        txtInput.delegate = self
        
    }
    
    func fill(title: String?, value: String?, isScrollEnabled: Bool = true){
        lblTitle.text = title
        txtInput.text = value
        txtInput.isScrollEnabled = isScrollEnabled
    }
    
}

//MARK: - setupConstraints
extension TextViewTableViewCell{
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
extension TextViewTableViewCell: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        contentView.heightAnchor.constraint(equalTo: txtInput.heightAnchor, multiplier: 1).isActive = true
        delegate?.tableViewCell(self, didChange: textView.text ?? "")
    }
}
