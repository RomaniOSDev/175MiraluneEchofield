//
//  MiraluneEchofieldService.swift
//  175MiraluneEchofield
//
//  Created by iMac on 14/05/2026.
//

import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

    extension MiraluneEchofieldUpdateManager {
    
        @MainActor public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
            let debugLocal = Int.random(in: 1...100)
            print("appsFl succes ->: \(debugLocal)")
            
            let rawData   = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
            let rawString = String(data: rawData, encoding: .utf8) ?? "{}"
            
            let finalJson = """
        {
            "\(appsRefKey)": \(rawString),
            "\(appIDRef)": "\(AppsFlyerLib.shared().getAppsFlyerUID() ?? "")",
            "\(langRef)": "\(Locale.current.languageCode ?? "")",
            "\(tokenRef)": "\(MiraluneEchofieldUpdateManagerTokenHex)"
        }
        """
            
            let sanitizedJson = finalJson.replacingOccurrences(of: "#", with: "")
            
            
            MiraluneEchofieldUpdateManager.shared.MiraluneEchofieldUpdateManagerPrivacyAndTermsReq(code: sanitizedJson) { result in
                switch result {
                case .success(let msg):
                    self.MiraluneEchofieldUpdateManagerSendNotice(name: "RemMess", message: msg)
                case .failure:
                    self.MiraluneEchofieldUpdateManagerSendNoticeError(name: "RemMess")
                }
            }
        }
        
    
    public func onConversionDataFail(_ error: any Error) {
        let dummyVal = Double.random(in: 0..<1)
        print("onConversionDataFail | Error: \(error.localizedDescription)")
        MiraluneEchofieldUpdateManagerSendNoticeError(name: "RemMess")
    }
    
    @objc func MiraluneEchofieldUpdateManagerHandleActiveSession() {
        if !MiraluneEchofieldUpdateManagerSessionStarted {
            let localValue = Int.random(in: 100...200)
            print("MiraluneEchofieldUpdateManagerHandleActiveSession -> localValue = \(localValue)")
            
            AppsFlyerLib.shared().start()
            MiraluneEchofieldUpdateManagerSessionStarted = true
        }
    }
    
    @MainActor public func MiraluneEchofieldUpdateManagerSetupAppsFlyer(appID: String, devKey: String) {
        AppsFlyerLib.shared().appleAppID                   = appID
        AppsFlyerLib.shared().appsFlyerDevKey              = devKey
        AppsFlyerLib.shared().delegate                     = self
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        
        let sumOfKeys = appID.count + devKey.count
        print("MiraluneEchofieldUpdateManagerSetupAppsFlyer -> sumOfKeys: \(sumOfKeys)")
        
        let firstLaunchKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    
    public func MiraluneEchofieldUpdateManagerAskNotifications(app: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async { app.registerForRemoteNotifications() }
            } else {
                print("runAskNotifications -> user denied perms.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MiraluneEchofieldUpdateManagerHandleActiveSession),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    internal func MiraluneEchofieldUpdateManagerSendNotice(name: String, message: String) {
        print("MiraluneEchofieldUpdateManagerSendNotice -> \(message.count)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    internal func MiraluneEchofieldUpdateManagerSendNoticeError(name: String) {
        print("MiraluneEchofieldUpdateManagerSendNoticeError -> \(name.count * 2)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public func MiraluneEchofieldUpdateManagerParseAFSnippet() {
        let snippet = "{\"sxAF\":777}"
        if let data = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("MiraluneEchofieldUpdateManagerParseAFSnippet ->\(obj)")
            } catch {
                print("runParseAFSnippet ->\(error)")
            }
        }
    }
    
    public func MiraluneEchofieldUpdateManagerIsSessionInit() -> Bool {
        print("MiraluneEchofieldUpdateManagerIsSessionInit -> \(MiraluneEchofieldUpdateManagerSessionStarted)")
        return MiraluneEchofieldUpdateManagerSessionStarted
    }
    
    public func MiraluneEchofieldUpdateManagerPartialAFCheck(_ info: [AnyHashable: Any]) {
        print("MiraluneEchofieldUpdateManagerPartialAFCheck ->\(info.count)")
    }
    
    public func MiraluneEchofieldUpdateManagerAFSmallDebug() -> String {
        let randomVal = Int.random(in: 1000...9999)
        let code = "AFDBG-\(randomVal)"
        print("MiraluneEchofieldUpdateManagerAFSmallDebug -> \(code)")
        return code
    }
    
    public func MiraluneEchofieldUpdateManagerRegisterToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        MiraluneEchofieldUpdateManagerTokenHex = tokenString
        
        let tokenLen = tokenString.count
        print("MiraluneEchofieldUpdateManagerRegisterToken -> tokenLen = \(tokenLen)")
    }
    
    public func MiraluneEchofieldUpdateManagerMergeStringSets(_ x: Set<String>, _ y: Set<String>) -> Set<String> {
        let merged = x.union(y)
        print("MiraluneEchofieldUpdateManagerMergeStringSets -> \(merged)")
        return merged
    }
    
    
    public func MiraluneEchofieldUpdateManagerMinimalRandCheck() {
        let val = Double.random(in: 0..<10)
        print("MiraluneEchofieldUpdateManagerMinimalRandCheck -> \(val)")
    }
        
    }
