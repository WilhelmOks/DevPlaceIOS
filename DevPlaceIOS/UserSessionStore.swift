import Foundation
import DevPlaceSwiftSDK
import Observation
import SwiftKeychainWrapper

@Observable
final class UserSessionStore {
    static let shared = UserSessionStore()
    private init() {}
    
    private let keychainWrapper = KeychainWrapper(serviceName: "DevPlace")
    
    private let emailKey: KeychainWrapper.Key = "email"
    private let passwordKey: KeychainWrapper.Key = "password"
    
    var email: String? {
        get {
            return keychainWrapper.decode(forKey: emailKey.rawValue)
        }
        set {
            if let newValue {
                let success = keychainWrapper.encodeAndSet(
                    newValue,
                    forKey: emailKey.rawValue,
                    withAccessibility: .whenUnlockedThisDeviceOnly
                )
                if !success {
                    dlog("Error: failed to store \(emailKey.rawValue) in keychain")
                }
            } else {
                keychainWrapper.remove(forKey: emailKey)
            }
        }
    }
    
    var password: String? {
        get {
            return keychainWrapper.decode(forKey: passwordKey.rawValue)
        }
        set {
            if let newValue {
                let success = keychainWrapper.encodeAndSet(
                    newValue,
                    forKey: passwordKey.rawValue,
                    withAccessibility: .whenUnlockedThisDeviceOnly
                )
                if !success {
                    dlog("Error: failed to store \(passwordKey.rawValue) in keychain")
                }
            } else {
                keychainWrapper.remove(forKey: passwordKey)
            }
        }
    }
}

private extension KeychainWrapper {
    func decode<T: Decodable>(forKey key: String) -> T? {
        if let object = data(forKey: key) {
            let decoder = JSONDecoder()
            
            if let decodedObject = try? decoder.decode(T.self, from: object) {
                return decodedObject
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func encodeAndSet<T: Encodable>(_ value: T, forKey key: String, withAccessibility accessibility: KeychainItemAccessibility?, isSynchronizable: Bool = false) -> Bool {
        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(value) {
            return set(encoded, forKey: key, withAccessibility: accessibility, isSynchronizable: isSynchronizable)
        } else {
            return false
        }
    }
}
