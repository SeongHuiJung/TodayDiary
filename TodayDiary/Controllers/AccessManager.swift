//
//  AccessManager.swift
//  TodayDiary
//
//  Created by 정성희 on 4/2/25.
//
import UIKit
import CloudKit
import AuthenticationServices
class AccessManager {
    static let shared = AccessManager()
    private init() {}
    
    // iCloud 설정 되어 있는지 확인
    func checkICloudAccountStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { accountStatus, error in
            if accountStatus == .available {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Keychain에서 userID 가져오기
    func loadUserIDFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "AppleUserID",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            if let data = item as? Data {
                //print("Keychain User ID 불러오기 성공")
                return String(data: data, encoding: .utf8)
            }
        } else {
            //print("User ID 불러오기 실패, 상태: \(status)")
        }
        return nil
    }
}
