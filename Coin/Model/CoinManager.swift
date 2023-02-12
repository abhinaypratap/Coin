import UIKit

protocol CoinManagerDelegate: AnyObject {
    func didUpdatePrice(_ coinManager: CoinManager, value: String)
    func didFailWithError(error: Error)
}
struct CoinManager {

    var delegate: CoinManagerDelegate?

    let currencyArray = [
        "AUD", "BRL", "CAD", "CNY", "EUR", "GBP", "HKD", "IDR", "ILS", "INR",
        "JPY", "MXN", "NOK", "NZD", "PLN", "RON", "RUB", "SEK", "SGD", "USD", "ZAR"
    ]

    func fetchCoinPrice(for currency: String) {
        let url = "\(Constant.baseURL)\(currency)?apikey=\(Constant.APIKey)"
        performRequest(with: url)
    }

    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, _, error) in
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
