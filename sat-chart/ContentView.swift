//
//  ContentView.swift
//  sat-chart
//
import SwiftUI
import Charts

struct ContentView: View {
    @Binding var cnf: CNF

    var body: some View {
        Text(String("# of variables: \(cnf.number_of_variables)"))
            .padding(.bottom, 5)
        Text(String("# of clauses: \(cnf.clauses.count)"))
            .padding(.bottom, 5)
        Chart {
            ForEach(cnf.vars.sorted(by: { $0.occRate > $1.occRate })) { v in
                SectorMark(
                    angle: .value("Value", v.occRate),
                    innerRadius: .ratio(0.5),
                    // angularInset: 1.0 // Optional: Adjust spacing between segments
                )
                .foregroundStyle(by: .value("Var", v.occRate))
            }
        }
        .chartLegend(position: .trailing)
        .padding()
    }
}

#Preview {
    ContentView(cnf: .constant(CNF(text: "p cnf 0 0\n")))
}
