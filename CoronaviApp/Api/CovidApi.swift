//
//  CovidApi.swift
//  CoronaApp
//
//  Created by 三澤俊裕 on 2023/01/14.
//

import UIKit

struct CovidAPI {
    static func getPrefecture(completion: @escaping (CovidInfo.Prefecture?, Error?) -> Void) {

        let url = URL(string: "https://opendata.corona.go.jp/api/Covid19JapanAll")
        let request = URLRequest(url: url!, timeoutInterval: 40)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("error: \(error!.localizedDescription)")
                completion(nil, error)
            }
            if let data = data {
                let result = try! JSONDecoder().decode(CovidInfo.Prefecture.self, from: data)
                completion(result, nil)
            }
        }.resume()
    }
}
