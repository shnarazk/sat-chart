//
//  sat_chartTests.swift
//  sat-chartTests
//

import Testing
@testable import sat_chart

struct sat_chartTests {

    @Test func cnf_header() async throws {
        let p1 = try cnf_parser.parse("p cnf 1 3\n")
        #expect(p1.0 == 1)
    }

    @Test func cnf_comment() async throws {
        let p1 = try cnf_parser.parse("c comment\np cnf 1 3\n")
        #expect(p1.0 == 1)
    }

    @Test func clause_clause() async throws {
        let c1 = try clause_parser.parse("3 4 0")
        #expect(c1.literals.count == 2)
    }
    
    @Test func cnf_clause() async throws {
        let p1 = try cnf_parser.parse("c comment\np cnf 1 3\n3 4 0\n")
        #expect(p1.0 == 1)
        #expect(p1.1.count == 2)
    }
}
