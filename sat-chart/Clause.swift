//
//  Clause.swift
//  sat-chart
//
import Foundation

public struct Clause: Identifiable {
    public let id: Int
    public let literals: [Int]
    init(id: Int, literals: [Int]) {
        self.id = id
        self.literals = literals
    }
}
