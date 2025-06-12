//
//  sat_chartDocument.swift
//  sat-chart
//
//  Created by 楢崎修二 on 6/8/25.
//

import Parsing
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

/// Collect primary vars and clauses
private nonisolated func collectPrimaries(
    numVars nv: Int,
    clauses: [Clause],
    limit: (Int) -> Int = { 4 * Int(sqrt(Double($0))) }
) -> ([Var], [[Int]]) {
    var occSum = 0
    var varOcc: [Int] = Array(repeating: 0, count: nv + 1)
    var litOcc: [Int] = Array(repeating: 0, count: 2 * (nv + 1))
    for c in clauses {
        for l in c.literals {
            varOcc[abs(l)] += 1
            litOcc[2 * abs(l) + (0 < l ? 1 : 0)] += 1
        }
        occSum += c.literals.count
    }
    let ol = varOcc.enumerated().dropFirst().sorted { $0.1 > $1.1 }
    let limit = 4 * Int(sqrt(Double(nv)))
    let targets = ol.dropLast(nv - limit)
    let varset = Set(targets.map { $0.0 })
    let cc = clauses.map { $0.literals.filter { varset.contains(abs($0)) } }.filter { !$0.isEmpty }
    let vars = targets.map {
        Var(
            id: $0.0,
            occRate: Double($0.1) / Double(occSum),
            occurences: (litOcc[2 * $0.0], litOcc[2 * $0.0 + 1])
        )
    }
    return (vars, cc)
}

nonisolated func parseCNF(_ str: Substring) throws -> (Int, [Clause]) {
    let clause_parser: some Parser<Substring, [Int]> = Parse {
        Many {
            Int.parser()
        } separator: {
            " "
        }
    }.map { literals in literals.dropLast() }
    let cnf_parser: some Parser<Substring, (Int, [Clause])> = Parse {
        Many {
            "c "
            Prefix { $0 != "\n" }
            "\n"
        }
        "p cnf "
        Int.parser()
        " "
        Int.parser()
        "\n"
        Many {
            clause_parser
        } separator: {
            "\n"
        }
    }.map { _, n, m, c in (n, c.enumerated().map { i, l in Clause(id: i, literals: l) }) }
    return try cnf_parser.parse(str)
}

public nonisolated struct CNF: FileDocument {
    var numberOfVariables: Int = -2
    var numberOfClauses: Int = -2
    var numberOfSmallClauses: Int = -2
    var primaryVars: [Var] = []
    var primaryClauses: [[Int]] = []
    init(text: String) {
        do {
            let (nv, clauses) = try parseCNF(text[...])
            self.numberOfVariables = nv
            self.numberOfClauses = clauses.count
            self.numberOfSmallClauses = clauses.filter { $0.literals.count <= 5 }.count
            let (o, c) = collectPrimaries(numVars: nv, clauses: clauses)
            self.primaryVars = o
            self.primaryClauses = c
        }
        catch {
            fatalError()
        }
    }
    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
            let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let (nv, clauses) = try parseCNF(string[...])
        self.numberOfVariables = nv
        self.numberOfClauses = clauses.count
        self.numberOfSmallClauses = clauses.filter { $0.literals.count <= 5 }.count
        let (o, c) = collectPrimaries(numVars: nv, clauses: clauses)
        self.primaryVars = o
        self.primaryClauses = c
    }
    public static var readableContentTypes: [UTType] { [.init(filenameExtension: "cnf")!] }
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = "".data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
