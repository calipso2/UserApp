import UIKit

final class PreviewViewController: UITableViewController {
    private lazy var formatter = DateFormatter.shortFormat()
    private var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        setupTableView()
    }
    
    private func loadProfile() {
        DispatchQueue.global().async {
            self.profile = Profile.load()
            guard self.profile != nil else {
                print("Error to load profile")
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupTableView() {
        title = "Просмотр"
        tableView.register(PreviewTableViewCell.self)
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Редактировать", style: .plain, target: self, action: #selector(btnEdit_touchUpInside))
    }
    
    private func saveProfile(_ profile: Profile) {
        self.profile = profile
        self.profile?.save()
        tableView.reloadData()
    }
    
    @objc private func btnEdit_touchUpInside(_ sender: UIButton) {
        guard let profile else {return}
        let vc = EditViewController(profile)
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
        return profile != profileUpdate
    }
}

// MARK: - UITableView
extension PreviewViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Profile.FieldType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = Profile.FieldType(indexPath),
              let profile
        else {
            return UITableViewCell()
        }
        
        let cell: PreviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        switch field{
        case  .secondName, .name, .thirdName:
            let value: String? = profile[field]
            cell.fill(value: value, with: field.title)
            
        case .dateOfBirth:
            if let value: Date = profile[field] {
                cell.fill(value: formatter.string(from: value), with: field.title)
            } else {
                cell.fill(value: nil, with: field.title)
            }
            
        case .genderType:
            let value: Gender? = profile[field]
            cell.fill(value: value?.title, with: field.title)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? UITableView.automaticDimension : 40
    }
}
