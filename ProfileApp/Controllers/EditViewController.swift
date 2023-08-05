import UIKit

protocol EditViewControllerDelegate: AnyObject {
    func editViewController(_ vc: EditViewController, willSave profileUpdate: Profile)
    func editViewController(_ vc: EditViewController, isChanged profileUpdate: Profile) -> Bool
}

final class EditViewController: UIViewController {
    private var profile : Profile
    weak var delegate: EditViewControllerDelegate?
    
    private lazy var tblProfile: UITableView = {
        let tbl = UITableView()
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.register(TextViewTableViewCell.self)
        tbl.register(DatePickerTableViewCell.self)
        tbl.register(GenderPickerTableViewCell.self)
        tbl.isScrollEnabled = false
        tbl.dataSource = self
        tbl.delegate = self
        return tbl
    }()
    
    private lazy var btnBack: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setTitle("Назад", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.tintColor = .systemBlue
        btn.addTarget(self, action: #selector(btnBack_touchUpInside), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    init(_ profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        title = "Редактирование"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(btnSave_touchUpInside))
        navigationItem.leftBarButtonItem = btnBack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let swipeEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(back_swipeRight))
        swipeEdgeGesture.edges = .left
        view.addGestureRecognizer(swipeEdgeGesture)
        view.addSubview(tblProfile)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tblProfile.topAnchor.constraint(equalTo:view.topAnchor, constant: 0),
            tblProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tblProfile.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tblProfile.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func showValidationErrorAlert() {
        let alert = UIAlertController(title: "Ошибка",
                                      message: "Не все обязательные поля заполнены!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Хорошо", style: .default))
        present(alert, animated: true)
    }
    
    private func showCompareAlertIfNeeded(saveCompletion: @escaping () -> (), skipCompletion: @escaping () -> ()) {
        guard delegate?.editViewController(self, isChanged: profile) == true else {
            skipCompletion()
            return
        }
        
        let alert = UIAlertController(title: "Данные были изменены",
                                      message: "Вы желаете сохранить изменения? В противном случае внесенные правки будут отменены",
                                      preferredStyle: .alert)
        
        let skipAction = UIAlertAction(title: "Пропустить", style: .default) { [weak self] _ in
            guard self != nil else { return }
            skipCompletion()
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style:  .default) { [weak self] _ in
            guard let self else { return }
            guard profile.validate() else {
                showValidationErrorAlert()
                return
            }
            saveCompletion()
        }
        alert.addAction(skipAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    private func willBack() {
        showCompareAlertIfNeeded(
            saveCompletion: { [weak self] in
            guard let self else { return }
            delegate?.editViewController(self, willSave: profile)
            navigationController?.popViewController(animated: true)
            
        }, skipCompletion: {[weak self] in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
        })
    }
    
    @objc private func btnSave_touchUpInside(_ sender: UIButton) {
        guard profile.validate() else {
            showValidationErrorAlert()
            return
        }
        delegate?.editViewController(self, willSave: profile)
    }
    
    @objc private func btnBack_touchUpInside(_ sender: UIButton) {
        willBack()
    }
    
    @objc private func back_swipeRight(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .recognized {
            willBack()
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension EditViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Profile.FieldType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = Profile.FieldType(indexPath)
        else {
            return UITableViewCell()
        }
        
        var resultCell: UITableViewCell?
        
        switch field {
        case .secondName:
            let cell: TextViewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field], isScrollEnabled: false)
            resultCell = cell
            
        case .name, .thirdName:
            let cell: TextViewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field])
            resultCell = cell
            
        case .dateOfBirth:
            let cell: DatePickerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field])
            resultCell = cell
            
        case .genderType:
            let cell: GenderPickerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field])
            resultCell = cell
        }
        
        return resultCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? UITableView.automaticDimension : 40
    }
}

// MARK: - ProfileTableViewCellDelegate
extension EditViewController: EditTableViewCellDelegate {
    func tableViewCell(_ cell: UITableViewCell, didChange value: Any?) {
        guard let indexPath = tblProfile.indexPath(for: cell),
              let field = Profile.FieldType(indexPath)
        else {
            return
        }
        profile[field] = value
        
        if cell as? TextViewTableViewCell != nil && indexPath.row == 0 {
            tblProfile.beginUpdates()
            tblProfile.endUpdates()
        }
    }
}
