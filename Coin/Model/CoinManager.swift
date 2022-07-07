//
//  CoinManager.swift
//  Coin
//
//  Created by Abhinay Pratap on 07/07/22.
//

import UIKit

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, value: String)
    func didFailWithError(error: Error)
}
struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let APIKey = "2C357AF2-E8C5-4491-9002-48EFFD6DF2D2"
    let currencyArray = [
        "AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY",
        "MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"
    ]
    
    func fetchCoinPrice(for currency: String) {
        let url = "\(baseURL)\(currency)?apikey=\(APIKey)"
        performRequest(with: url)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let data = data {
                    if let accurateValue = self.parseJSON(data) {
                        let value = String(format: "%.2f", accurateValue)
                        self.delegate?.didUpdatePrice(self, value: value)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let value = decodedData.rate
            return value
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
