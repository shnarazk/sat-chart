import Charts
//
//  ContentView.swift
//  sat-chart
//
import SwiftUI

struct ContentView: View {
    @Binding var cnf: CNF

    var body: some View {
        Text(String("# of variables: \(cnf.number_of_variables)"))
            .padding(.bottom, 5)
        Text(String("# of clauses: \(cnf.number_of_clauses)"))
            .padding(.bottom, 5)
        Chart {
            ForEach(cnf.occrs) { v in
                SectorMark(
                    angle: .value("Value", v.occRate),
                    innerRadius: .ratio(0.5),
                    // angularInset: 1.0 // Optional: Adjust spacing between segments
                )
                .foregroundStyle(by: .value("Var", v.occRate))
            }
            SectorMark(
                angle: .value("Value", 1.0 - cnf.occrs.reduce(0) { $0 + $1 .occRate }),
                innerRadius: .ratio(0.5),
            )
            .foregroundStyle(by: .value("Var", 0))
        }
        .chartLegend(position: .trailing)
        .padding()
    }
}

#Preview {
    ContentView(cnf: .constant(CNF(text: "p cnf 0 0\n")))
}
