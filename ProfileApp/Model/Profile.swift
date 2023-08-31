import Foundation
import UIKit

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
    var photo: String?
    var lastName: String = ""
    var firstName: String = ""
    var middleName: String?
    var dateOfBirth: Date?
    var gender: Gender = .none
    
    enum Constants {
        static let PhotoPath = "photo.jpg"
        static let PhotoTmpPath = "photoTmp.jpg"
    }
}

extension Profile {
    enum FieldType: Int, CaseIterable {
        case photo = 0
        case lastName
        case firstName
        case middleName
        case dateOfBirth
        case gender
        
        var title: String {
            switch self{
            case .lastName:
                return "Фамилия"
            case .firstName:
                return "Имя"
            case .middleName:
                return "Отчество"
            case .dateOfBirth:
                return "Дата рождения"
            case .gender:
                return "Пол"
            case .photo:
                return "Аватар"
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
    
    @discardableResult
    func save() -> Result<Void, Error> {
        if let jsonData = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(jsonData, forKey: Profile.profileKey)
            return .success(())
        } else {
            let encodingError = NSError(domain: "Profile Encoding Error", code: 0, userInfo: nil)
            return .failure(encodingError)
        }
    }
    
    static func load() -> Profile? {
        guard let jsonData = UserDefaults.standard.data(forKey: profileKey) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(Profile.self, from: jsonData)
        } catch {
            print("Failed to decode profile: \(error)")
            return nil
        }
    }
}

extension Profile {
    func validate() -> Bool {
        return !lastName.isEmpty && !firstName.isEmpty && gender != .none
    }
}

// MARK: - Subscript
extension Profile {
    subscript<T>(field: FieldType) -> T? {
        get {
            switch field {
            case .photo:
                return photo as? T
            case .lastName:
                return lastName as? T
            case .firstName:
                return firstName as? T
            case .middleName:
                return middleName as? T
            case .dateOfBirth:
                return dateOfBirth as? T
            case .gender:
                return gender as? T
            }
        }
        set {
            switch field {
            case .photo:
                if let newValue = newValue as? String, !newValue.isEmpty {
                    photo = newValue
                } else {
                    photo = nil
                }
                
            case .lastName:
                guard let newValue = newValue as? String else { return }
                lastName = newValue
                
            case .firstName:
                guard let newValue = newValue as? String else { return }
                firstName = newValue
                
            case .middleName:
                if let newValue = newValue as? String, !newValue.isEmpty {
                    middleName = newValue
                } else {
                    middleName = nil
                    
                }
            case .dateOfBirth:
                if let newValue = newValue as? Date, !newValue.description.isEmpty {
                    dateOfBirth = newValue
                } else {
                    dateOfBirth = nil
                }
                
            case .gender:
                guard let newValue = newValue as? Gender else { return }
                gender = newValue
            }
        }
        
    }
}
