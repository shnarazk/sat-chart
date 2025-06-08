//
//  sat_chartApp.swift
//  sat-chart
//
//  Created by 楢崎修二 on 6/8/25.
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
