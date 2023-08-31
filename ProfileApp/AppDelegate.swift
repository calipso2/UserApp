import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController:  PreviewViewController())
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let fileManager = FileManager.default
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        
        let image = documentsDirectory.appendingPathComponent(Profile.Constants.PhotoTmpPath)
        if fileManager.fileExists(atPath: image.path) {
            do {
                try fileManager.removeItem(at: image)
            } catch {
                print("failed to remove \(Profile.Constants.PhotoTmpPath)")
            }
        }
    }
}
