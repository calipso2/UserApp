import Foundation

enum Gender: Int, CaseIterable, Codable {
    case none = 0
    case male
    case female
    
    var title: String {
        switch self {
        case .none:
            return "Не указан"
        case .male:
            return "Мужской"
        case .female:
            return "Женский"
        }
    }
}

struct Profile: Codable, Equatable {
    var secondName: String = ""
    var name: String = ""
    var thirdName: String? = ""
    var dateOfBirth: Date?
    var genderType: Gender = .none
    
    enum FieldType: Int, CaseIterable {
        case secondName = 0
        case name
        case thirdName
        case dateOfBirth
        case genderType
        
        var title: String {
            switch self{
            case .secondName:
                return "Фамилия"
            case .name:
                return "Имя"
            case .thirdName:
                return "Отчество"
            case .dateOfBirth:
                return "Дата рождения"
            case .genderType:
                return "Пол"
            }
        }
        
        init?(_ indexPath: IndexPath) {
              self.init(rawValue: indexPath.row)
          }
    }
}

// MARK: - Profile extension UserDefaults + JSONEncoder
extension Profile{
    private static let profileKey = "profile"
    
    func save() {
        if let jsonData = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(jsonData, forKey: Profile.profileKey)
        } else {
            print("Failed to encode profile.")
        }
    }
    
    static func load() -> Profile? {
        guard let jsonData = UserDefaults.standard.data(forKey: profileKey) else {
            return Profile()
        }
        do {
            return try JSONDecoder().decode(Profile.self, from: jsonData)
        } catch {
            print("Failed to decode profile: \(error)")
            return nil
        }
    }}

extension Profile {
    func validate() -> Bool {
        return !secondName.isEmpty && !name.isEmpty && genderType != .none
    }
}

// MARK: - Subscript
extension Profile {
    subscript<T>(field: FieldType) -> T? {
        get {
            switch field {
            case .secondName:
                return secondName as? T
            case .name:
                return name as? T
            case .thirdName:
                return thirdName as? T
            case .dateOfBirth:
                return dateOfBirth as? T
            case .genderType:
                return genderType as? T
            }
        }
        set {
            switch field {
            case .secondName:
                guard let newValue = newValue as? String else { return }
                secondName = newValue
            case .name:
                guard let newValue = newValue as? String else { return }
                name = newValue
            case .thirdName:
                guard let newValue = newValue as? String? else { return }
                thirdName = newValue
            case .dateOfBirth:
                guard let newValue = newValue as? Date? else { return }
                dateOfBirth = newValue
            case .genderType:
                guard let newValue = newValue as? Gender else { return }
                genderType = newValue
            }
        }
    }
}
