//
//  Var.swift
//  sat-chart
//
//  Created by 楢崎修二 on 6/8/25.
//

struct Var: Identifiable {
    let id: Int
    let occrences: (Int, Int)
    let relations: [Int: Int]
}
