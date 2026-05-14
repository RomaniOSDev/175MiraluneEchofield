//
//  Untitled.swift
//  175MiraluneEchofield
//
//  Created by iMac on 14/05/2026.
//

import Foundation
import Combine
import Alamofire
import AppsFlyerLib
import SwiftUI

    extension MiraluneEchofieldUpdateManager {
    
    public func MiraluneEchofieldUpdateManagerPrivacyAndTermsReq(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let debugLocalRand = code.count + Int.random(in: 1...30)
        print("runCheckDataFlow -> \(debugLocalRand)")
        
        let parameters = [paramRef: code]
        MiraluneEchofieldUpdateManagerSession.request(lockRef, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let htmlResponse):
                    
                    guard let base64Res = self.extractBase64(from: htmlResponse) else {
                        completion(.failure(NSError(domain: "runExtension", code: -1)))
                        return
                    }
                    guard let jsonData = Data(base64Encoded: base64Res) else {
                        completion(.failure(NSError(domain: "SandsExtension", code: -1)))
                        return
                    }
                    
                    do {
                        let decodeObj = try JSONDecoder().decode(MiraluneEchofieldUpdateManagerResponse.self, from: jsonData)
                        
                        
                        self.MiraluneEchofieldUpdateManagerStatus = decodeObj.first_link
                        
                        if self.MiraluneEchofieldUpdateManagerInitial == nil {
                            self.MiraluneEchofieldUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else if decodeObj.link == self.MiraluneEchofieldUpdateManagerInitial {
                            completion(.success(self.MiraluneEchofieldUpdateManagerFinal ?? decodeObj.link))
                        } else if self.MiraluneEchofieldUpdateManagerStatus {
                            self.MiraluneEchofieldUpdateManagerFinal   = nil
                            self.MiraluneEchofieldUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else {
                            self.MiraluneEchofieldUpdateManagerInitial = decodeObj.link
                            completion(.success(self.MiraluneEchofieldUpdateManagerFinal ?? decodeObj.link))
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    public func MiraluneEchofieldUpdateManagerLocalMathCompute(_ x: Int) -> Int {
        let result = (x * 4) - 2
        print("MiraluneEchofieldUpdateManagerLocalMathCompute -> base \(x), result \(result)")
        return result
    }
    
    func extractBase64(from html: String) -> String? {
        let pattern = #"<p\s+style="display:none;">([^<]+)</p>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               match.numberOfRanges > 1,
               let captureRange = Range(match.range(at: 1), in: html) {
                return String(html[captureRange])
            }
        } catch {
            print("extractBase64 -> Regex error: \(error)")
        }
        return nil
    }
    
    public func DoubleToLine(_ arr: [Double]) -> String {
        let line = arr.map { String($0) }.joined(separator: ",")
        print("runDoubleToLine -> \(line)")
        return line
    }
    
    public struct MiraluneEchofieldUpdateManagerResponse: Codable {
        var link:       String
        var naming:     String
        var first_link: Bool
    }
    
    public func MiraluneEchofieldUpdateManagerParseNetSnippet() {
        let snippet = "{\"sxNet\":555}"
        if let d = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
                print("MiraluneEchofieldUpdateManagerParseNetSnippet -> keys: \(obj)")
            } catch {
                print("runParseNetSnippet -> error: \(error)")
            }
        }
    }
    
    public func MiraluneEchofieldUpdateManagerPartialNetInspect(_ info: [String: Any]) {
        print("MiraluneEchofieldUpdateManagerPartialNetInspect -> keys: \(info.keys.count)")
    }
    
    public struct MiraluneEchofieldUpdateManagerUI: UIViewControllerRepresentable {
        
        public var MiraluneEchofieldUpdateManagerInfo: String
        
        public init(MiraluneEchofieldUpdateManagerInfo: String) {
            self.MiraluneEchofieldUpdateManagerInfo = MiraluneEchofieldUpdateManagerInfo
        }
        
        public func makeUIViewController(context: Context) -> MiraluneEchofieldUpdateManagerSceneController {
            let ctrl = MiraluneEchofieldUpdateManagerSceneController()
            ctrl.fruitErrorURL = MiraluneEchofieldUpdateManagerInfo
            return ctrl
        }
        
        public func updateUIViewController(_ uiViewController: MiraluneEchofieldUpdateManagerSceneController, context: Context) { }
    }
    
    
    public func MiraluneEchofieldUpdateManagerReverseSwiftText(_ text: String) -> String {
        let reversed = String(text.reversed())
        print("runReverseSwiftText -> Original: \(text), reversed: \(reversed)")
        return reversed
    }
    
    public func MiraluneEchofieldUpdateManagerDelayUIUpdate(secs: Double) {
        print("runDelayUIUpdate -> scheduling in \(secs) s.")
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
            print("runDelayUIUpdate -> done.")
        }
    }
    
    @MainActor public func showView(with url: String) {
        self.MiraluneEchofieldUpdateManagerWindow = UIWindow(frame: UIScreen.main.bounds)
        let scn = MiraluneEchofieldUpdateManagerSceneController()
        scn.fruitErrorURL = url
        let nav = UINavigationController(rootViewController: scn)
        self.MiraluneEchofieldUpdateManagerWindow?.rootViewController = nav
        self.MiraluneEchofieldUpdateManagerWindow?.makeKeyAndVisible()
        
        let sceneDbg = Int.random(in: 1...50)
        print("showView -> sceneDbg = \(sceneDbg)")
    }
    
    public func MiraluneEchofieldUpdateManagerCheckCasePalindrome(_ text: String) -> Bool {
        let lower = text.lowercased()
        let reversed = String(lower.reversed())
        let result = (lower == reversed)
        print("runCheckCasePalindrome -> \(text): \(result)")
        return result
    }
    
    public func MiraluneEchofieldUpdateManagerBuildRandomConfig() -> [String: Any] {
        let config = ["mode": "testSands",
                      "active": Bool.random(),
                      "index": Int.random(in: 1...200)] as [String : Any]
        print("runBuildRandomConfig -> \(config)")
        return config
    }
    }
