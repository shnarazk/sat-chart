//
//  sat_chartApp.swift
//  sat-chart
//

import SwiftUI

@main
struct sat_chartApp: App {
    var body: some Scene {
        DocumentGroup(viewing: CNF.self) { file in
            ContentView(cnf: file.$document)
        }
    }
}
