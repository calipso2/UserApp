import UIKit

final class PreviewViewController: UITableViewController {
    private lazy var formatter = DateFormatter.shortFormat()
    private var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async {
            guard let image = self.loadImage() else { return }
            
            DispatchQueue.main.async {
                let indexPath = IndexPath(.photo)
                guard let cell = self.tableView.cellForRow(at: indexPath) as? ImageTableViewCell else { return }
                cell.fill(title: nil, value: image)
            }
        }
    }
    
    private func loadProfile() {
        DispatchQueue.global().async {
            guard let profile = Profile.load() else {
                print("Error to load profile")
                return
            }
            self.profile = profile
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupTableView() {
        title = "Просмотр"
        tableView.register(PreviewTableViewCell.self)
        tableView.register(ImageTableViewCell.self)
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Редактировать", style: .plain, target: self, action: #selector(btnEdit_touchUpInside))
    }
    
    private func loadImage() -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let imageFileName = profile?.photo,
              let imageData = try? Data(contentsOf: documentsDirectory.appendingPathComponent(imageFileName)),
              let image = UIImage(data: imageData) else {
            return UIImage(named: "imgDefault") ?? UIImage()
        }
        return image
    }
    
    private func saveProfile(_ profile: Profile) {
        self.profile = profile
        self.profile?.save()
        tableView.reloadData()
    }
    
    @objc private func btnEdit_touchUpInside(_ sender: UIButton) {
        let vc = EditViewController(profile ?? Profile())
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - EditViewControllerDelegate
extension PreviewViewController: EditViewControllerDelegate {
    func editViewController(_ vc: EditViewController, willSave profileUpdate: Profile) {
        saveProfile(profileUpdate)
    }
    
    func editViewController(_ vc: EditViewController, isChanged profileUpdate: Profile) -> Bool {
        let isNotNil = profileUpdate.lastName != "" || profileUpdate.firstName != "" || profileUpdate.gender != .none || profileUpdate.photo != nil || profileUpdate.middleName != nil
        
        return profile == nil && isNotNil || profile != nil && profile != profileUpdate
    }
}

// MARK: - UITableView
extension PreviewViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Profile.FieldType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = Profile.FieldType(indexPath)
        else {
            return UITableViewCell()
        }
        
        var resultCell: UITableViewCell?
        
        switch field {
        case  .lastName, .firstName, .middleName:
            let cell: PreviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let value: String? = profile?[field]
            
            cell.fill(value: value, with: field.title)
            resultCell = cell
            
        case .dateOfBirth:
            let cell: PreviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            if let value: Date = profile?[field] {
                cell.fill(value: formatter.string(from: value), with: field.title)
            } else {
                cell.fill(value: formatter.string(from: Date()), with: field.title)
                self.profile?[.dateOfBirth] = Date()
            }
            
            resultCell = cell
            
        case .gender:
            let cell: PreviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let value: Gender? = profile?[field]
            
            cell.fill(value: value?.title, with: field.title)
            resultCell = cell
            
        case .photo:
            let cell: ImageTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            resultCell = cell
        }
        return resultCell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let field = Profile.FieldType(indexPath) else { return 0 }
        return field == .lastName || field == .photo ? UITableView.automaticDimension : 40
    }
}
