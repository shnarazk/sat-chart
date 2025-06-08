//
//  Clause.swift
//  sat-chart
//
//  Created by 楢崎修二 on 6/8/25.
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
