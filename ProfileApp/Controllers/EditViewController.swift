import UIKit

protocol EditViewControllerDelegate: AnyObject {
    func editViewController(_ vc: EditViewController, willSave profileUpdate: Profile)
    func editViewController(_ vc: EditViewController, isChanged profileUpdate: Profile) -> Bool
}

final class EditViewController: UIViewController {
    weak var delegate: EditViewControllerDelegate?
    private var profile: Profile
    
    private lazy var tblProfile: UITableView = {
        let tbl = UITableView()
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.register(TextViewTableViewCell.self)
        tbl.register(DatePickerTableViewCell.self)
        tbl.register(GenderPickerTableViewCell.self)
        tbl.register(ImageTableViewCell.self)
        tbl.isScrollEnabled = false
        tbl.dataSource = self
        tbl.delegate = self
        return tbl
    }()
    
    private lazy var pickImage: UIImagePickerController = {
        let pickImage = UIImagePickerController()
        pickImage.allowsEditing = true
        pickImage.mediaTypes = ["public.image"]
        pickImage.delegate = self
        return pickImage
    }()
    
    init(_ profile: Profile) {
        self.profile = profile
        print(self.profile)
        super.init(nibName: nil, bundle: nil)
        title = "Редактирование"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(btnSave_touchUpInside))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(btnBack_touchUpInside))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async { [weak self] in
            guard let self, let image = loadImage() else { return }
            
            DispatchQueue.main.async {
                let indexPath = IndexPath(.photo)
                if let cell = self.tblProfile.cellForRow(at: indexPath) as? ImageTableViewCell {
                    cell.fill(title: nil, value: image)
                }
            }
        }
    }
    
    private func setupView() {
        let rcgEdgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(rcgEdgeSwipe_swipeBack))
        rcgEdgeSwipe.edges = .left
        view.addGestureRecognizer(rcgEdgeSwipe)
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
    
    private func loadImage() -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let imageFileName = profile.photo,
              let imageData = try? Data(contentsOf: documentsDirectory.appendingPathComponent(imageFileName)),
              let image = UIImage(data: imageData)
        else {
            return UIImage(named: "imgDefault") ?? UIImage()
        }
        return image
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
                
                if profile.photo == Profile.Constants.PhotoTmpPath {
                    renameFile(file: Profile.Constants.PhotoPath, fileUpdated: Profile.Constants.PhotoTmpPath)
                    profile[.photo] = Profile.Constants.PhotoPath
                }
                
                delegate?.editViewController(self, willSave: profile)
                navigationController?.popViewController(animated: true)
            }, skipCompletion: { [weak self] in
                guard let self else { return }
                
                let updatedImage = Profile.Constants.PhotoTmpPath
                if profile.photo == updatedImage {
                    removeFile(at: updatedImage)
                    profile[.photo] = Profile.Constants.PhotoPath
                }
                navigationController?.popViewController(animated: true)
            }
        )
    }
    
    private func saveToFile(_ data: Data) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask)
            let fileURL = documentsDirectory.appendingPathComponent(profile.photo ?? UUID().uuidString)
            
            try data.write(to: fileURL)
        } catch {
            print("Failed to save to file: \(error)")
        }
    }
    
    private func renameFile(file: String, fileUpdated: String) {
        let fileManager = FileManager.default
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        
        let fileToRename = documentsDirectory.appendingPathComponent(fileUpdated)
        let file = documentsDirectory.appendingPathComponent(file)
        
        do {
            if fileManager.fileExists(atPath: file.path) {
                try fileManager.removeItem(at: file)
            }
            
            try fileManager.moveItem(at: fileToRename, to: file)
            
        } catch {
            print("failed to rename \(fileUpdated)")
        }
    }
    
    private func removeFile(at file: String) {
        let fileManager = FileManager.default
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        
        let file = documentsDirectory.appendingPathComponent(file)
        
        do {
            try fileManager.removeItem(at: file)
            
        } catch {
            print("failed to remove \(file)")
        }
    }
    
    @objc private func btnSave_touchUpInside(_ sender: UIButton) {
        guard profile.validate() else {
            showValidationErrorAlert()
            return
        }
        
        let updatedPhoto = Profile.Constants.PhotoTmpPath
        
        if profile.photo == updatedPhoto {
            let photo = Profile.Constants.PhotoPath
            renameFile(file: photo, fileUpdated: updatedPhoto)
            profile[.photo] = Profile.Constants.PhotoPath
        }
        
        delegate?.editViewController(self, willSave: profile)
    }
    
    @objc private func btnBack_touchUpInside(_ sender: UIButton) {
        willBack()
    }
    
    @objc private func rcgEdgeSwipe_swipeBack(_ sender: UIScreenEdgePanGestureRecognizer) {
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
        case .lastName:
            let cell: TextViewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field], isScrollEnabled: false)
            resultCell = cell
            
        case .firstName, .middleName:
            let cell: TextViewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field])
            resultCell = cell
            
        case .dateOfBirth:
            let cell: DatePickerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field])
            resultCell = cell
            
        case .gender:
            let cell: GenderPickerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            cell.delegate = self
            cell.fill(title: field.title, value: profile[field])
            resultCell = cell
            
        case .photo:
            let cell: ImageTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            resultCell = cell
        }
        
        return resultCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let field = Profile.FieldType(indexPath) else { return 0 }
        return field == .lastName || field == .photo ? UITableView.automaticDimension : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let field = Profile.FieldType(indexPath) else { return }
        if field == .photo {
            present(pickImage, animated: true)
        }
    }
}

// MARK: - EditTableViewCellDelegate
extension EditViewController: EditTableViewCellDelegate {
    func editTableViewCellShouldUpdateSize(_ cell: UITableViewCell) {
        tblProfile.beginUpdates()
        tblProfile.endUpdates()
    }
    
    func editTableViewCell(_ cell: UITableViewCell, didChange value: Any?) {
        guard let indexPath = tblProfile.indexPath(for: cell),
              let field = Profile.FieldType(indexPath)
        else {
            return
        }
        profile[field] = value
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8)
        else {
            return
        }
        
        profile[.photo] = Profile.Constants.PhotoTmpPath
        saveToFile(imageData)
        
        let indexPath = IndexPath(.photo)
        let cell = tblProfile.cellForRow(at: indexPath) as? ImageTableViewCell
        cell?.fill(title: nil, value: image)
        
        do {
            let fileManager = FileManager.default
            let tmpDirectory = FileManager.default.temporaryDirectory
            try fileManager.contentsOfDirectory(at: tmpDirectory).forEach {
                try fileManager.removeItem(at: $0)
            }
        } catch {
            print("Error: \(error)")
        }
        
        picker.dismiss(animated: true)
        
    }
}
