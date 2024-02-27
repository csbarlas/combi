//
//  ColorSchemeManager.swift
//  Combi
//
//  Created by Christopher Barlas on 2/27/24.
//

import SwiftUI

// Reference: https://mia-e.medium.com/swiftui-how-to-allow-users-to-select-light-dark-mode-easily-using-preferredcolorscheme-18515f4db2df
class ColorSchemeManager: ObservableObject {
    static let shared = ColorSchemeManager()
    @AppStorage("appearance") var appearance: String = "system"
    
    func getPreferredColorScheme() -> ColorScheme? {
        switch appearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}
