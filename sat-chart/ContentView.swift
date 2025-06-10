import Charts
//
//  ContentView.swift
//  sat-chart
//
import SwiftUI

private func phase(_ occ: (Int, Int)) -> Double {
    Double(occ.0 - occ.1) / Double(occ.0 + occ.1)
}

struct ContentView: View {
    @Binding var cnf: CNF

    var body: some View {
        Text(String("# of variables: \(cnf.number_of_variables)"))
            .padding(.bottom, 5)
        Text(String("# of clauses: \(cnf.number_of_clauses)"))
            .padding(.bottom, 5)
        Text(String("# of var picked: \(cnf.occrs.count)"))
            .padding(.bottom, 5)
        HStack {
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
                    angle: .value("Value", 1.0 - cnf.occrs.reduce(0) { $0 + $1.occRate }),
                    innerRadius: .ratio(0.5),
                )
                .foregroundStyle(by: .value("Var", 0))
            }
            .chartLegend(position: .trailing)
            .padding()
            Chart {
                ForEach(cnf.occrs) { v in
                    PointMark(
                        x: .value("var occurency", v.occRate),
                        y: .value("phase", phase(v.occurences)),
                    )
                }
            }
            .chartXAxisLabel("Occurrence Rate") // X-axis label
            .chartYAxisLabel("Phase")           // Y-axis label
            .chartLegend(position: .trailing)
            .padding()
        }
        .padding(.bottom)
    }
}

#Preview {
    ContentView(cnf: .constant(CNF(text: "p cnf 0 0\n")))
}
