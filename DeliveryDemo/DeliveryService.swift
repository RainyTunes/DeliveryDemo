import Foundation

class DeliveryService {
    static let shared = DeliveryService()
    private let baseURL = "https://6285f87796bccbf32d6c0e6a.mockapi.io"
    private let cacheKey = "cachedDeliveries"

    func fetchDeliveries(offset: Int, completion: @escaping (Result<[Delivery], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/deliveries")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(offset)", forHTTPHeaderField: "offset")

        print("Request URL: \(url)")
        print("HTTP Method: \(request.httpMethod ?? "N/A")")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request Error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                var deliveries = try decoder.decode([Delivery].self, from: data)
                deliveries = deliveries.filter { $0.isValid }.map { var delivery = $0; delivery.offset = offset; return delivery }

                if offset == 0 {
                    self.cacheDeliveries(deliveries)
                }
                
                completion(.success(deliveries))
            } catch {
                do {
                    let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                    let validDeliveries = jsonArray?.compactMap { dict -> Delivery? in
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []),
                              var delivery = try? JSONDecoder().decode(Delivery.self, from: jsonData),
                              delivery.isValid else {
                            return nil
                        }
                        delivery.offset = offset
                        return delivery
                    }
                    if let validDeliveries = validDeliveries {
                        if offset == 0 {
                            self.cacheDeliveries(validDeliveries)
                        }
                        completion(.success(validDeliveries))
                    } else {
                        completion(.failure(error))
                    }
                } catch {
                    print("JSON Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    private func cacheDeliveries(_ deliveries: [Delivery]) {
        do {
            let data = try JSONEncoder().encode(deliveries)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("Failed to cache deliveries: \(error)")
        }
    }

    func loadCachedDeliveries() -> [Delivery]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        do {
            let deliveries = try JSONDecoder().decode([Delivery].self, from: data)
            return deliveries
        } catch {
            print("Failed to load cached deliveries: \(error)")
            return nil
        }
    }
}
