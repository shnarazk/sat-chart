//
//  ContentView.swift
//  sat-chart
//
//  Created by 楢崎修二 on 6/8/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var cnf: CNF

    var body: some View {
        Text(String("# of variables: \(cnf.number_of_variables)"))
            .padding(.bottom, 5)
        Text(String("# of clauses: \(cnf.clauses.count)"))
            .padding(.bottom, 5)
//        List {
//            ForEach(cnf.clauses) { clause in
//                Text(String("\(clause)"))
//            }
//        }
    }
}

#Preview {
    ContentView(cnf: .constant(CNF(text: "p cnf 0 0\n")))
}
