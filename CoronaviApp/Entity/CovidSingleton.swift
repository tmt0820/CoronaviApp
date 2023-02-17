//
//  CovidSingleton.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/01/14.
//

import Foundation

class CovidSingleton {
    
    private init() {}
        static let shared = CovidSingleton()
    var prefecture: CovidInfo.Prefecture!
}
