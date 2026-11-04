//
//  File.swift
//  P3
//
//  Created by Hubert  Greszta on 04/11/2026.
//

import Foundation
import SwiftUI

@main struct DisplayP3PreviewApp: App {
    var body: some Scene {
        WindowGroup {
            P3View()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
