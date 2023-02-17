//
//  CovidEntity.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/01/14.
//

struct CovidInfo: Codable {
    
    struct Prefecture: Codable {
        let itemList: [Item]
        
        struct Item: Codable {
            var date: String
            var name_jp: String
            var npatients: String
        }
    }
}
