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

private func varOccEffectives(nv: Int, clauses: [Clause]) -> ([Var], Int) {
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
    var ol = Array(varOcc.enumerated().dropFirst())
    ol.sort { $0.1 > $1.1 }
    let limit = 4 * Int(sqrt(Double(nv)))
    let targets = ol.dropLast(nv - limit)
    let varset = Set(targets.map { $0.0 })
    let cc = clauses.filter { $0.literals.allSatisfy { !varset.contains(abs($0)) }}.count
    let vars = targets.map {
        Var(
            id: $0.0,
            occRate: Double($0.1) / Double(occSum),
            occurences: (litOcc[2 * $0.0], litOcc[2 * $0.0 + 1])
            // chain:
        )
    }
    return (vars, cc)
}

func parse(_ str: Substring) throws -> (Int, [Clause]) {
    let clause_parser: some Parser<Substring, [Int]> = Parse {
        Many {
            Int.parser()
            // Prefix { $0.isWhitespace }
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

public struct CNF: FileDocument {
    // var text: String
    var number_of_variables: Int = -2
    var number_of_clauses: Int = -2
    var number_of_small_clauses: Int = -2
    // var var_occurrences: [Int: Int] = [:]
    // var clauses: [Clause] = []
    var occrs: [Var]
    var number_of_clauses_link_to_occrs: Int = -2

    init(text: String) {
        // self.text = text
        do {
            let (n, clauses) = try parse(text[...])
            self.number_of_variables = n
            self.number_of_clauses = clauses.count
            self.number_of_small_clauses = clauses.filter { $0.literals.count <= 5 }.count
            // self.clauses = clauses
            let (o, c) = varOccEffectives(nv: n, clauses: clauses)
            self.occrs = o
            self.number_of_clauses_link_to_occrs = c
        } catch {
            print(error)
            self.number_of_variables = -1
            self.number_of_clauses = -1
            self.number_of_small_clauses = 0
            // self.clauses = []
            self.occrs = []
        }
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
            let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        // text = string
        do {
            let (n, clauses) = try parse(string[...])
            self.number_of_variables = n
            self.number_of_clauses = clauses.count
            self.number_of_small_clauses = clauses.filter { $0.literals.count <= 5 }.count
            // clauses = c
            let (o, c) = varOccEffectives(nv: n, clauses: clauses)
            self.occrs = o
            self.number_of_clauses_link_to_occrs = c
        } catch {
            print(error)
            self.number_of_variables = -1
            self.number_of_clauses = -1
            self.number_of_small_clauses = 0
            // self.clauses = []
            self.occrs = []
        }
    }

    public static var readableContentTypes: [UTType] { [.init(filenameExtension: "cnf")!] }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = "".data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
