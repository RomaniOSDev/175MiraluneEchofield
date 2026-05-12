//
//  AppExternalLink.swift
//  175MiraluneEchofield
//

import Foundation

enum AppExternalLink: String {
    /// Placeholder — replace with your live privacy URL.
    case privacyPolicy = "https://miralune175echofield.site/privacy/180"
    /// Placeholder — replace with your live terms URL.
    case termsOfUse = "https://miralune175echofield.site/terms/180"

    var url: URL? {
        URL(string: rawValue)
    }
}
