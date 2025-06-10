//
//  Var.swift
//  sat-chart
//
struct Var: Identifiable {
    let id: Int
    let occRate: Double
    let occurences: (Int, Int) 
    let relations: [Int: Int] = [:]
}
