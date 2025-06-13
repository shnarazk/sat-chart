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
    @State private var viewPage: Int = 0
    private let pages = [
        (id: 0, label: "Basic properties", icon: "list.bullet"),
        (id: 1, label: "Dominant Vars", icon: "chart.pie.fill"),
        (id: 2, label: "Var phases", icon: "link"),
    ]
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 16) {
                List(pages, id: \.id, selection: $viewPage) { g in
                    HStack {
                        Image(systemName: g.icon)
                        Text(g.label)
                    }
                }
            }
        } detail: {
            switch viewPage {
            case 1:
                Chart {
                    ForEach(cnf.primaryVars) { v in
                        SectorMark(
                            angle: .value("Value", v.occRate),
                            innerRadius: .ratio(0.5),
                            // angularInset: 1.0 // Optional: Adjust spacing between segments
                        )
                        .foregroundStyle(by: .value("Var", v.occRate))
                    }
                    SectorMark(
                        angle: .value("Value", 1.0 - cnf.primaryVars.reduce(0) { $0 + $1.occRate }),
                        innerRadius: .ratio(0.5),
                    )
                    .foregroundStyle(by: .value("Var", 0))
                }
                .chartLegend(position: .trailing)
                .padding()
                .backgroundExtensionEffect()
            case 2:
                Chart {
                    ForEach(cnf.primaryVars) { v in
                        PointMark(
                            x: .value("var occurency", v.occRate),
                            y: .value("phase", phase(v.occurences)),
                        )
                    }
                }
                .chartXAxisLabel("Occurrence Rate")
                .chartYAxisLabel("Phase")
                .chartYScale(domain: -1.0...1.0)
                .chartLegend(position: .trailing)
                .padding()
                .backgroundExtensionEffect()
            default:
                List {
                    Section(header: Text("All")) {
                        Text(String("# of variables: \(cnf.numberOfVariables)"))
                            .padding(.bottom, 5)
                        Text(String("# of clauses: \(cnf.numberOfClauses)"))
                            .padding(.bottom, 5)
                    }
                    Section(header: Text("Primary core")) {
                        Text(String("# of primary vars: \(cnf.primaryVars.count)"))
                            .padding(.bottom, 5)
                        Text(String("# of primary clauses: \(cnf.primaryClauses.count)"))
                            .padding(.bottom, 5)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(cnf: .constant(CNF(text: "p cnf 0 0\n")))
}
