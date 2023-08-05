import UIKit
// MARK: - TextViewTableViewCellDelegate
// - setSize(): используется в textViewDidChange для следующего пункта: "поле фамилии может быть многострочным - предусмотреть соответствующий многострочный вывод и опционально: ввод с растущим полем ввода; остальные поля будут при вводе прокручиваться, а при выводе – обрезаться троеточием"
protocol TextViewTableViewCellDelegate: AnyObject {
    func textViewCell(_ cell: TextViewTableViewCell, didChangeValue newValue: String?)
}

final class TextViewTableViewCell: UITableViewCell {
    weak var delegate: TextViewTableViewCellDelegate?
    
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
        setConstraints()
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
    
    func fill(title: String?, defaultText: String?, isScrollEnabled : Bool){
        lblTitle.text = title
        txtInput.text = defaultText
        txtInput.isScrollEnabled = isScrollEnabled
    }
    
}

//MARK: - setConstraints
extension TextViewTableViewCell{
    private func setConstraints(){
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
extension TextViewTableViewCell : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        contentView.heightAnchor.constraint(equalTo: txtInput.heightAnchor, multiplier: 1).isActive = true
        delegate?.textViewCell(self, didChangeValue: textView.text)
    }
}
