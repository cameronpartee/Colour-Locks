//  Helpers.swift
//  Color Lock

import Foundation
import UIKit


var queueArray: [Int] = []

func generateRandomNumbers(quantity: Int) -> [CGFloat] {
    var randomNumberArray = [CGFloat]()
    for _ in 1...quantity {
        let randomNumber = CFloat(arc4random_uniform(255))
        randomNumberArray.append(CGFloat(randomNumber))
    }
    return randomNumberArray
}


func addToQueueArray() -> [Int] {
    queueArray.append(Int(arc4random_uniform(4)))
    return queueArray
}
