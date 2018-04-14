//
//  Car.swift
//  Carangas
//
//  Created by Usuário Convidado on 14/04/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

class Car : Codable {
    
    var _id: String?
    var name: String = ""
    var price: Double = 0.0
    var gasType: Int = 0
    var brand: String = ""
    
    
    var gas: String {
        switch gasType {
        case 0:
            return "Flex"
        case 1:
            return "Alcool"
        case 2:
            return "Gasolina"
        default:
            return "NAO RECONHECIDO"
        }
    }
}
