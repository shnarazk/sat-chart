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

public struct CNF: FileDocument {
    var text: String
    var number_of_variables: Int = -2
    var clauses: [Clause] = []

    init(text: String) {
        self.text = text
        do {
            let (n, clauses) = try cnf_parser.parse(text)
            self.number_of_variables = n
            self.clauses = clauses
        } catch {
            print(error)
            self.number_of_variables = -1
            self.clauses = [Clause(literals: [1, 2])]
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
        clauses = c
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}

public let clause_parser: some Parser<Substring, Clause> = Parse {
    Many {
        Int.parser()
        // Prefix { $0.isWhitespace }
    } separator: {
        " "
    }
}.map { literals in Clause(literals: literals.dropLast()) }

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
}.map { _, n, m, c in (n, c) }
