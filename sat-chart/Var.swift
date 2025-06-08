//
//  Var.swift
//  sat-chart
//
struct Var: Identifiable {
    let id: Int
    let occRate: Double
    let occrences: (Int, Int) = (0, 0)
    let relations: [Int: Int] = [:]
}
