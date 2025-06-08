//
//  Clause.swift
//  sat-chart
//
import Foundation

public struct Clause: Identifiable {
    public let id: UUID
    public let literals: [Int]
    init(literals: [Int]) {
        self.literals = literals
        self.id = UUID()
    }
}
