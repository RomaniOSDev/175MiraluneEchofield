//
//  MiraluneEchofieldMainView.swift
//  175MiraluneEchofield
//
//  Created by iMac on 14/05/2026.
//

import SwiftUI
import Network

struct MiraluneEchofieldMainView: View {
    @State private var requestNotifications = true
    @State private var somethingWentWrong = false
    @State private var supportMessage = ""

    var body: some View {
        Group {
            if requestNotifications {
                MiraluneEchofieldLoadingView()
            } else {
                if somethingWentWrong {
                    Text("")
                    MiraluneEchofieldUpdateManager.MiraluneEchofieldUpdateManagerUI(MiraluneEchofieldUpdateManagerInfo: supportMessage)
                        .ignoresSafeArea()
                } else {
                    ContentView()
                }
            }
        }
        .onAppear {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                if path.status != .satisfied {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue.global(qos: .utility))

            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("RemMess"),
                object: nil,
                queue: .main
            ) { notification in
                if let info = notification.userInfo as? [String: String],
                   let data = info["notificationMessage"] {
                    Task { @MainActor in
                        if data == "Error occurred" {
                            self.somethingWentWrong = false
                        } else {
                            self.supportMessage = data
                            self.somethingWentWrong = true
                        }
                        self.requestNotifications = false
                    }
                } else {
                    Task { @MainActor in
                        self.somethingWentWrong = false
                        self.requestNotifications = false
                    }
                }
            }
        }
    }
}
