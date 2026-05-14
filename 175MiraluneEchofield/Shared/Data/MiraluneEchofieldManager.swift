//
//  MiraluneEchofieldManager.swift
//  175MiraluneEchofield
//
//  Created by iMac on 14/05/2026.
//

import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class MiraluneEchofieldUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("MiraluneEchofieldUpdateManagerInitial") var MiraluneEchofieldUpdateManagerInitial: String?
    @AppStorage("MiraluneEchofieldUpdateManagerStatus")  var MiraluneEchofieldUpdateManagerStatus: Bool = false
    @AppStorage("MiraluneEchofieldUpdateManagerFinal")   var MiraluneEchofieldUpdateManagerFinal: String?
    
    @MainActor public static let shared = MiraluneEchofieldUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var MiraluneEchofieldUpdateManagerWindow: UIWindow?
    
    internal var MiraluneEchofieldUpdateManagerSessionStarted = false
    internal var MiraluneEchofieldUpdateManagerTokenHex = ""
    internal var MiraluneEchofieldUpdateManagerSession: Session
    internal var MiraluneEchofieldUpdateManagerCollector = Set<AnyCancellable>()
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("MiraluneEchofieldUpdateManager init -> \(debugRand)")
        self.MiraluneEchofieldUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        MiraluneEchofieldUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://oieotinujq.lol/privacy"
        paramRef = "data"
        
        
        MiraluneEchofieldUpdateManagerWindow = window
        
        MiraluneEchofieldUpdateManagerSetupAppsFlyer(appID: "6768638072", devKey: "4iPeRNs4AkBBNjGHZFi3Ng")
        
        completion(.success("Initialization completed successfully"))
    }
    
    }
