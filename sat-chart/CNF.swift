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

private func varOccEffectives(nv: Int, clauses: [Clause]) -> [Var] {
    var occSum = 0
    var occ: [Int] = Array(repeating: 0, count: nv + 1)
    for c in clauses {
        for l in c.literals {
            occ[abs(l)] += 1
        }
        occSum += c.literals.count
    }
    var ol = Array(occ.enumerated().dropFirst())
    ol.sort { $0.1 > $1.1 }
    let limit = Int(log2(Double(nv)))
    return ol.dropLast(nv - limit).map { Var(id: $0.0, occRate: Double($0.1) / Double(occSum))}
}

public struct CNF: FileDocument {
    var text: String
    var number_of_variables: Int = -2
    var number_of_clauses: Int = -2
    // var var_occurrences: [Int: Int] = [:]
    // var clauses: [Clause] = []
    var occrs: [Var]

    init(text: String) {
        self.text = text
        do {
            let (n, clauses) = try cnf_parser.parse(text)
            self.number_of_variables = n
            self.number_of_clauses = clauses.count
            // self.clauses = clauses
            self.occrs = varOccEffectives(nv: n, clauses: clauses)
        } catch {
            print(error)
            self.number_of_variables = -1
            self.number_of_clauses = -1
            // self.clauses = []
            self.occrs = []
        }
    }

    public static var readableContentTypes: [UTType] { [.init(filenameExtension: "cnf")!] }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
            let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
        let (n, c) = try cnf_parser.parse(text)
        number_of_variables = n
        number_of_clauses = c.count
        // clauses = c
        occrs = varOccEffectives(nv: n, clauses: c)
            }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}

public let clause_parser: some Parser<Substring, [Int]> = Parse {
    Many {
        Int.parser()
        // Prefix { $0.isWhitespace }
    } separator: {
        " "
    }
}.map { literals in literals.dropLast() }

public let cnf_parser: some Parser<Substring, (Int, [Clause])> = Parse {
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
    }
    separator: { "\n" }
}.map { _, n, m, c in (n, c.enumerated().map { i, l in Clause(id: i, literals: l) }) }
